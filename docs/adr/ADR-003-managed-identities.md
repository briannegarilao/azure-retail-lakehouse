# ADR-003: Use Managed Identities for Azure Service Authentication

## Status

Accepted

## Context

Azure Data Factory and Azure Databricks require access to the project's ADLS
Gen2 storage account.

Storing access keys, passwords, or long-lived credentials in application
configuration would increase secret-management risk.

## Decision

Use Azure managed identities for Azure service-to-service authentication.

Azure Data Factory uses its system-assigned managed identity.

Azure Databricks accesses storage through a Unity Catalog storage credential
backed by an Azure Databricks Access Connector with a system-assigned managed
identity.

Both workload identities receive Storage Blob Data Contributor at the storage
account scope.

## Consequences

Benefits:

- No embedded storage-account keys
- Reduced secret-management burden
- Azure-native credential lifecycle
- RBAC-controlled access
- Clear separation between authentication and authorization

Trade-offs:

- Identity and RBAC configuration add infrastructure complexity
- Permission propagation can introduce short delays
- Troubleshooting requires understanding both identity and authorization layers