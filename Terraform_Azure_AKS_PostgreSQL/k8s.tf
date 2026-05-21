resource "kubernetes_service_account" "app" {
  metadata {
    name      = "app-sa"
    namespace = "default"
    annotations = {
      "azure.workload.identity/client-id" = module.identity.client_id
    }
  }
}

# Λέει στο CSI driver ποιο secret να πάρει από το Key Vault
# και να το συγχρονίσει σε Kubernetes Secret
resource "kubernetes_manifest" "secret_provider_class" {
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"
    metadata = {
      name      = "kv-secrets"
      namespace = "default"
    }
    spec = {
      provider = "azure"
      parameters = {
        usePodIdentity = "false"
        clientID       = module.identity.client_id
        keyvaultName   = module.keyvault.key_vault_name
        tenantId       = data.azurerm_client_config.current.tenant_id
        objects        = "array:\n  - |\n    objectName: my-secret\n    objectType: secret\n"
      }
      secretObjects = [
        {
          secretName = "kv-synced-secret"
          type       = "Opaque"
          data = [
            {
              objectName = "my-secret"
              key        = "MY_SECRET"
            }
          ]
        }
      ]
    }
  }
}

# Pod που τρέχει πάντα με το secret ως env var
resource "kubernetes_pod" "app" {
  metadata {
    name      = "app"
    namespace = "default"
    labels = {
      "azure.workload.identity/use" = "true"
    }
  }

  spec {
    service_account_name = kubernetes_service_account.app.metadata[0].name

    container {
      name    = "app"
      image   = "busybox:latest"
      command = ["sleep", "infinity"]

      env {
        name = "MY_SECRET"
        value_from {
          secret_key_ref {
            name = "kv-synced-secret"
            key  = "MY_SECRET"
          }
        }
      }

      volume_mount {
        name       = "secrets-store"
        mount_path = "/mnt/secrets"
        read_only  = true
      }
    }

    volume {
      name = "secrets-store"
      csi {
        driver    = "secrets-store.csi.k8s.io"
        read_only = true
        volume_attributes = {
          secretProviderClass = "kv-secrets"
        }
      }
    }
  }

  depends_on = [kubernetes_manifest.secret_provider_class]
}
