# Tagging policy

### Introduction

This Terraform module contains a policy for requiring a tag before allowing resources to be created.

### Dependencies

Please refer to the dependencies listed [here](../README.md).

### Instructions

This module does not provide variables, due to its conciseness. Run the command below to apply the policy definition and assignment to your Azure subscription:
```console
terraform apply

# Or

terraform plan -out policies.plan
terraform apply policies.plan
```

### Output

Below you find the output of `az policty definition list` after the policy definition was created:
```json
{
    "description": "Requires existence of a tag for resources.",
    "displayName": "tagging-policy",
    "id": "/subscriptions/0662842a-dcd9-4ef6-9862-b0f975d96bcf/providers/Microsoft.Authorization/policyDefinitions/tagging-policy",
    "metadata": {
        "createdBy": "d01e3bac-5990-4983-bba0-574e22a47d55",
        "createdOn": "2021-08-03T14:40:29.2230606Z",
        "updatedBy": null,
        "updatedOn": null
    },
    "mode": "Indexed",
    "name": "tagging-policy",
    "parameters": null,
    "policyRule": {
        "if": {
            "exists": "false",
            "field": "tags"
        },
        "then": {
            "effect": "deny"
        }
    },
    "policyType": "Custom",
    "type": "Microsoft.Authorization/policyDefinitions"
}
```

And below is the output of `az policy assignment list` after the policy assignment was created:
```json
{
    "description": null,
    "displayName": "",
    "enforcementMode": "Default",
    "id": "/subscriptions/0662842a-dcd9-4ef6-9862-b0f975d96bcf/providers/Microsoft.Authorization/policyAssignments/tagging-policy-assignment",
    "identity": null,
    "location": null,
    "metadata": {
        "createdBy": "d01e3bac-5990-4983-bba0-574e22a47d55",
        "createdOn": "2021-08-03T14:42:00.2230231Z",
        "updatedBy": null,
        "updatedOn": null
    },
    "name": "tagging-policy-assignment",
    "nonComplianceMessages": null,
    "notScopes": null,
    "parameters": null,
    "policyDefinitionId": "/subscriptions/0662842a-dcd9-4ef6-9862-b0f975d96bcf/providers/Microsoft.Authorization/policyDefinitions/tagging-policy",
    "scope": "/subscriptions/0662842a-dcd9-4ef6-9862-b0f975d96bcf",
    "type": "Microsoft.Authorization/policyAssignments"
}
```
