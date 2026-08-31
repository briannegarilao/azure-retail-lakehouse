# Azure Retail Analytics Lakehouse Platform

## Project Overview

The Azure Retail Analytics Lakehouse Platform is a cloud-based Data Engineering project that simulates how a retail or e-commerce organization can ingest, store, transform, model, test, and operate analytical data on Microsoft Azure.

The platform receives data from batch files, REST APIs, and operational data sources. Azure Data Factory is used for cloud-native ingestion and orchestration, Azure Data Lake Storage Gen2 provides durable cloud storage, and Azure Databricks with PySpark processes the data into trusted Delta Lake tables.

The platform follows a medallion architecture:

- Landing for preserving source deliveries
- Bronze for source-aligned ingested records
- Silver for cleaned, typed, validated, and deduplicated data
- Gold for business-ready analytical models

dbt is used for SQL-based analytical transformations, testing, documentation, and lineage where appropriate.

Supporting engineering practices include Git, GitHub Actions, Terraform, secure configuration, monitoring, data-quality validation, incremental processing, idempotent reruns, and production-style documentation.

## Business Problem

A retail organization receives data from multiple systems, including daily files, APIs, customer systems, order systems, product data, and inventory sources.

A local pipeline can process this data, but as the platform grows it becomes necessary to separate storage, ingestion, compute, orchestration, security, monitoring, and deployment responsibilities.

The organization needs a cloud analytics platform that can:

- Preserve original source data
- Reliably ingest data from multiple sources
- Clean and validate records
- Handle duplicate and late-arriving data
- Support incremental processing and safe reruns
- Create trusted analytical models
- Provide data-quality checks
- Coordinate dependent pipeline tasks
- Protect credentials and access
- Monitor pipeline execution and failures
- Recreate infrastructure consistently
- Control cloud costs

## Project Objective

Build and operate a production-style Azure lakehouse platform that demonstrates the complete Data Engineering lifecycle from source ingestion to analytics-ready datasets.

The project will extend the engineering principles learned in Project 1 into a managed cloud environment while preserving the same core principles:

- Define the grain of every important dataset
- Separate source capture from trusted transformations
- Preserve raw data for replay and recovery
- Make incremental processing safe
- Design reruns to be idempotent
- Validate data independently from job success
- Make failures observable and recoverable
- Keep infrastructure and configuration reproducible
- Protect secrets and credentials
- Understand and control cloud cost

## High-Level Architecture

```text
SOURCE SYSTEMS
      |
      v
Azure Data Factory
      |
      v
Azure Data Lake Storage Gen2
      |
      v
Azure Databricks / PySpark
      |
      v
Delta Lake
      |
      +--> Bronze
      |
      +--> Silver
      |
      v
     dbt
      |
      v
Gold / Analytics Marts
      |
      v
Databricks SQL / Optional BI
```

Supporting engineering:

```text
Git / GitHub
GitHub Actions
Terraform
Azure Key Vault
Identity and Access Control
Testing
Monitoring
Cost Management
Documentation
```

## In Scope

This project includes:

- Microsoft Azure fundamentals
- Azure Data Lake Storage Gen2
- Azure Data Factory
- Azure Databricks
- Apache Spark fundamentals
- PySpark
- Delta Lake
- Medallion architecture
- Landing, Bronze, Silver, and Gold data layers
- Batch file ingestion
- REST API ingestion
- Explicit schemas and validation
- Deduplication
- Incremental processing
- Late-arriving data handling
- Delta MERGE operations
- Idempotent pipeline design
- Dimensional modeling
- dbt transformations
- dbt tests and documentation
- Data-quality validation
- Azure-native orchestration
- Focused Apache Airflow orchestration lab
- Git and GitHub
- GitHub Actions
- Terraform
- Azure Key Vault
- Managed identity and service-principal concepts
- Monitoring and operational logging
- Cost awareness and cleanup procedures
- Production-style documentation
- Failure and recovery exercises

## Out of Scope

The project intentionally does not attempt to build or specialize in:

- AWS
- Google Cloud Platform
- BigQuery
- Snowflake
- Oracle
- Kubernetes
- Kafka
- Apache Flink
- Apache Iceberg
- Trino
- A complete Microsoft Fabric implementation
- A complete Azure Synapse Analytics implementation
- Large-scale real-time streaming
- Enterprise-scale networking architecture
- Enterprise-scale production workloads
- A large Power BI or dashboard project

These technologies may be discussed conceptually when useful, but they are not part of the core Project 2 implementation.

## Project Philosophy

This project focuses on understanding the engineering responsibilities behind cloud services rather than memorizing portal clicks.

The general working principle is:

```text
Understand the engineering problem
        |
        v
Learn the service or concept that solves it
        |
        v
Implement it
        |
        v
Inspect the data and system state
        |
        v
Introduce or encounter failures
        |
        v
Debug and recover
        |
        v
Test
        |
        v
Automate
        |
        v
Document the design and trade-offs
```

Terminal and code are preferred where reproducibility matters.

Azure Portal, Azure Data Factory Studio, and the Databricks GUI are used when they provide useful visibility into managed cloud resources.

Important infrastructure should eventually become reproducible through code, CLI commands, Terraform, or documented deployment procedures.

## Cost Safety

This project uses an Azure for Students subscription with limited cloud credit.

Cloud resources must therefore be created deliberately.

Important rules include:

- Use the smallest practical development resources
- Keep datasets small during learning
- Enable Databricks auto-termination where available
- Terminate compute after exercises
- Do not leave cloud compute running unnecessarily
- Monitor Azure costs regularly
- Use budget alerts
- Delete resources that are no longer required
- Record cleanup procedures
- Avoid deploying duplicate platforms merely for comparison
- Understand what creates cost before deploying a resource

Detailed cost controls are documented in:

`docs/cost-safety.md`

## Current Status

```text
Project: Azure Retail Analytics Lakehouse Platform
Level: Intermediate
Current Module: Module 0 - Project Kickoff + Architecture + Cost Safety
Status: In Progress
```
