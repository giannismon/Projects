data "azurerm_client_config" "current" {}

locals {
  # Η πολιτική του deployer παράγεται εδώ γιατί το object_id του έρχεται από data source.
  deployer_policy = var.grant_deployer_access ? {
    deployer = {
      object_id               = data.azurerm_client_config.current.object_id
      secret_permissions      = ["Get", "Set", "Delete", "List", "Purge"]
      certificate_permissions = ["Get", "Create", "List", "Delete", "Purge"]
      key_permissions         = []
    }
  } : {}

  access_policies = merge(local.deployer_policy, var.access_policies)
}

resource "azurerm_key_vault" "kv" {
  name                = var.kv_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.sku_name
  tags                = var.tags

  dynamic "access_policy" {
    for_each = local.access_policies

    content {
      tenant_id = data.azurerm_client_config.current.tenant_id
      object_id = access_policy.value.object_id

      secret_permissions      = access_policy.value.secret_permissions
      certificate_permissions = access_policy.value.certificate_permissions
      key_permissions         = access_policy.value.key_permissions
    }
  }
}

resource "azurerm_key_vault_secret" "secret" {
  for_each = var.secrets

  name = each.key
  # sensitive(): κρύβει την τιμή στο plan ακόμα κι αν ο caller την περάσει χωρίς mark.
  # Η variable ΔΕΝ είναι declared sensitive γιατί τότε ολόκληρη η map γίνεται
  # sensitive και το for_each τη ρίχνει (Invalid for_each argument). Sensitive
  # τιμή ΜΕΣΑ στη map είναι εντάξει — το mark είναι στην τιμή, όχι στα keys.
  value        = sensitive(each.value.value)
  content_type = each.value.content_type
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_certificate" "cert" {
  for_each = var.certificates

  name         = each.key
  key_vault_id = azurerm_key_vault.kv.id

  certificate_policy {
    issuer_parameters {
      name = each.value.issuer
    }

    key_properties {
      exportable = true
      key_size   = each.value.key_size
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }
      trigger {
        days_before_expiry = each.value.days_before_expiry
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      extended_key_usage = each.value.extended_key_usage
      key_usage          = each.value.key_usage
      subject            = each.value.subject
      validity_in_months = each.value.validity_in_months

      dynamic "subject_alternative_names" {
        for_each = length(each.value.dns_names) > 0 ? [1] : []

        content {
          dns_names = each.value.dns_names
        }
      }
    }
  }
}
