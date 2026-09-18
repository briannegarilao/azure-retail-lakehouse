# Security and Identity Model

## Overview

The Azure Retail Analytics Lakehouse uses Azure-managed identities and RBAC
instead of embedded storage credentials wherever possible.

## Azure Data Factory

Azure Data Factory uses a system-assigned managed identity.

The identity is granted:

- Storage Blob Data Contributor

Scope:

- ADLS Gen2 storage account `stretaildeveas001`

This allows ADF to ingest and write source data without storing storage-account
keys inside linked services.

## Azure Databricks

Databricks accesses ADLS through Unity Catalog.

The authentication chain is:

Databricks
→ Unity Catalog Storage Credential
→ Azure Databricks Access Connector
→ System-Assigned Managed Identity
→ ADLS Gen2

The Access Connector identity is granted:

- Storage Blob Data Contributor

Scope:

- ADLS Gen2 storage account `stretaildeveas001`

## Storage Security

The storage account uses:

- HTTPS-only traffic
- TLS 1.2 minimum
- Hierarchical Namespace
- Public blob access disabled
- Azure RBAC for workload identities

## Authentication vs Authorization

Authentication identifies a workload or user.

Examples:

- ADF managed identity
- Databricks Access Connector managed identity
- developer Azure identity

Authorization determines what that identity can do.

Azure RBAC provides this authorization.

## Current Network Posture

The development environment currently allows public network access at selected
Azure service boundaries to keep the student environment operational and
cost-effective.

This is acceptable for the development lab but is not the final recommended
production posture.

## Production Hardening

A production implementation should evaluate:

- Azure Private Endpoints
- storage firewall restrictions
- Databricks private networking
- Key Vault for application secrets
- service principals or workload identity for CI/CD
- least-privilege RBAC
- centralized audit logging
- credential rotation policies