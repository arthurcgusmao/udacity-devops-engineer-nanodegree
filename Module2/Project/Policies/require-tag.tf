provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_policy_definition" "tagging" {
  name         = "tagging-policy"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Tagging Policy"
  description  = "Requires existence of a tag for resources."

  policy_rule = <<POLICY_RULE
    {
      "if": {
        "field": "tags",
        "exists": "false"
      },
      "then": {
        "effect": "deny"
      }
    }
  POLICY_RULE
}

resource "azurerm_subscription_policy_assignment" "tagging" {
  name                 = "tagging-policy-assignment"
  policy_definition_id = azurerm_policy_definition.tagging.id
  subscription_id      = data.azurerm_subscription.current.id
}
