resource "kubernetes_service_account" "app" {
  metadata {
    name      = "app-sa"
    namespace = "default"
    annotations = {
      "azure.workload.identity/client-id" = azurerm_user_assigned_identity.app.client_id
    }
  }
}

resource "kubernetes_job" "test_secret" {
  metadata {
    name      = "test-secret"
    namespace = "default"
  }

  spec {
    template {
      metadata {
        labels = {
          "azure.workload.identity/use" = "true"
        }
      }
      spec {
        service_account_name = kubernetes_service_account.app.metadata[0].name
        container {
          name  = "test"
          image = "mcr.microsoft.com/azure-cli:latest"
          command = [
            "/bin/sh", "-c",
            "az login --federated-token \"$(cat $AZURE_FEDERATED_TOKEN_FILE)\" --service-principal -u $AZURE_CLIENT_ID -t $AZURE_TENANT_ID --output none && echo SECRET=$(az keyvault secret show --vault-name ${azurerm_key_vault.main.name} --name my-secret --query value -o tsv)"
          ]
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 2
  }

  wait_for_completion = false
}
