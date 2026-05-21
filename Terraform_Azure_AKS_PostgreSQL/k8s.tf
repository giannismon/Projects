resource "kubernetes_service_account" "app" {
  metadata {
    name      = "app-sa"
    namespace = "default"
    annotations = {
      "azure.workload.identity/client-id" = module.identity.client_id
    }
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = "app"
    namespace = "default"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "app"
      }
    }

    template {
      metadata {
        labels = {
          app                          = "app"
          "azure.workload.identity/use" = "true"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.app.metadata[0].name

        container {
          name  = "app"
          image = "mcr.microsoft.com/azure-cli:latest"
          command = [
            "/bin/sh", "-c",
            "az login --federated-token \"$(cat $AZURE_FEDERATED_TOKEN_FILE)\" --service-principal -u $AZURE_CLIENT_ID -t $AZURE_TENANT_ID --allow-no-subscriptions --output none && export MY_SECRET=$(az keyvault secret show --vault-name ${module.keyvault.key_vault_name} --name my-secret --query value -o tsv) && echo MY_SECRET=$MY_SECRET && sleep infinity"
          ]
        }
      }
    }
  }
}
