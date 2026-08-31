# Architecture v1

## Overview

The Azure Retail Analytics Lakehouse Platform is designed as a cloud-based batch analytics platform for retail and e-commerce data.

The platform separates ingestion, storage, compute, transformation, orchestration, security, monitoring, and deployment responsibilities instead of placing everything inside a single database or local environment.

The primary data flow is:

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
Azure Databricks
      |
      v
Apache Spark / PySpark
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

Supporting engineering capabilities include:

```text
Git / GitHub
GitHub Actions
Terraform
Azure Key Vault
Azure Identity and Access Control
Data Quality Tests
Monitoring
Cost Management
Documentation
```

## Source Systems

The platform will simulate a retail organization receiving data from multiple operational sources.

Possible sources include:

- Daily CSV files
- JSON files
- REST APIs
- Customer data
- Product/reference data
- Order and transaction data
- Inventory data

The source system remains responsible for producing the original data.

The platform must not assume that source data is already clean, unique, complete, or correctly typed.

## Azure Data Factory

Azure Data Factory is the primary Azure-native ingestion and orchestration service.

Its main responsibilities in this architecture are:

- Connecting to source systems
- Moving data into cloud storage
- Running scheduled pipelines
- Managing dependencies
- Applying retry policies
- Passing parameters between activities
- Triggering downstream processing
- Providing pipeline monitoring

ADF is primarily responsible for data movement and orchestration.

Complex transformation logic should generally remain in Databricks/PySpark or dbt instead of being spread across many ADF transformation activities.

## Azure Data Lake Storage Gen2

ADLS Gen2 is the durable cloud storage layer.

Its responsibilities include:

- Preserving incoming source data
- Storing lakehouse data
- Supporting hierarchical paths
- Separating data layers
- Allowing historical replay
- Decoupling storage from compute

The data lake initially contains logical areas such as:

```text
landing/
bronze/
silver/
gold/
```

The exact physical layout may evolve as the project is implemented.

Storage must remain available independently of Databricks compute.

## Landing Layer

The Landing layer represents the source delivery area.

Its primary question is:

> What exactly did the source deliver?

Examples:

```text
landing/orders/2026/08/31/orders.csv
landing/products/2026/08/31/products.csv
landing/api/customers/2026/08/31/
```

Landing data should receive minimal transformation.

Its purpose is to preserve source deliveries so the pipeline can replay or investigate previous batches.

A duplicate delivery may intentionally exist in Landing because Landing records what physically arrived.

## Azure Databricks

Azure Databricks provides the managed data processing environment.

Its responsibilities include:

- Providing Spark compute
- Running PySpark transformations
- Reading data from ADLS
- Writing Delta Lake tables
- Supporting jobs and workflows
- Providing execution logs and operational visibility

Databricks is the platform.

Apache Spark is the distributed processing engine running within that environment.

PySpark is the Python API used to instruct Spark.

## Apache Spark / PySpark

Spark is used for distributed transformation and processing.

Project 2 will use PySpark to implement operations such as:

- Explicit schema application
- Type conversion
- Deduplication
- Null handling
- Standardization
- Joins
- Window functions
- Validation
- Incremental processing
- Delta MERGE operations

Spark should not be treated as simply a replacement syntax for pandas.

The project will consider concepts including:

- Driver
- Executors
- Partitions
- Lazy evaluation
- Transformations
- Actions
- Shuffles
- Distributed execution

## Delta Lake

Delta Lake provides reliable table semantics on top of data stored in the lake.

A simplified mental model is:

```text
Delta Table
=
Parquet data files
+
Delta transaction log
```

Delta Lake supports capabilities such as:

- ACID transactions
- Schema enforcement
- Schema evolution
- MERGE
- UPDATE
- DELETE
- Version history
- Time travel concepts

Delta Lake is used for Bronze, Silver, and Gold lakehouse tables where appropriate.

## Bronze Layer

Bronze is the source-aligned lakehouse layer.

Its main question is:

> What records did the platform ingest?

Bronze data should remain close to the original source structure.

Possible metadata may include:

- `ingested_at`
- `source_file`
- `source_system`
- `batch_id`

One possible grain for an orders Bronze table is:

> One source order record from one ingestion batch.

Bronze may preserve duplicate records if the same source delivery is ingested more than once.

This allows downstream layers to distinguish source history from trusted business state.

## Silver Layer

Silver is the trusted data layer.

Its primary question is:

> What records can downstream systems trust?

Silver transformations may include:

- Explicit type casting
- Standardized values
- Null handling
- Deduplication
- Business validation
- Referential validation
- Invalid-record handling
- Incremental processing
- Late-arriving-data handling

One possible grain for a Silver orders table is:

> One trusted order at its accepted analytical state.

Silver is generally where duplicated source deliveries should stop affecting downstream analytics.

## Gold Layer

Gold contains business-ready analytical models.

Its primary question is:

> What representation does the business need to analyze?

Possible Gold models include:

```text
dim_customer
dim_product
dim_date
fact_orders
fact_order_items
daily_sales
customer_lifetime_value
```

Every Gold model must define its grain before implementation.

Examples:

```text
fact_order_items
One row = one product line within one order

dim_customer
One row = one analytical customer

daily_sales
One row = one business date × selected business dimension
```

Gold should contain trusted, documented business logic.

## dbt

dbt manages SQL-centric analytical transformations.

The planned responsibility boundary is:

```text
PySpark
Bronze -> Silver

dbt
Silver -> Gold / Analytics Marts
```

dbt responsibilities include:

- SQL models
- Dependency management with `ref()`
- Testing
- Documentation
- Lineage
- Incremental model concepts
- Reusable transformation patterns

This boundary may change if the implemented workloads provide a strong engineering reason.

Any major change should be documented through an Architecture Decision Record.

## Orchestration

Azure Data Factory is currently planned as the primary production orchestrator.

ADF will coordinate operations such as:

```text
ingestion
    |
    v
Databricks processing
    |
    v
dbt transformations
    |
    v
data-quality validation
```

Apache Airflow will also be studied through a focused orchestration lab.

Airflow will not initially duplicate the entire ADF implementation.

The purpose is to understand code-first concepts including:

- DAGs
- Task dependencies
- Scheduling
- Retries
- Backfills
- Task state
- Idempotent orchestration

The final orchestration decision will be documented later.

## Data Flow vs Deployment Flow

The project has two different flows.

### Data Flow

```text
Sources
  |
  v
ADF
  |
  v
ADLS
  |
  v
Databricks / PySpark
  |
  v
Delta Bronze
  |
  v
Delta Silver
  |
  v
dbt
  |
  v
Gold
```

This describes how business data moves.

### Engineering / Deployment Flow

```text
Engineer
   |
   v
Git
   |
   v
GitHub
   |
   v
GitHub Actions
   |
   +--> Tests
   |
   +--> Terraform validation
   |
   +--> Deployment workflow
              |
              v
             Azure
```

This describes how engineering changes reach the platform.

These flows should not be confused.

## Infrastructure as Code

Terraform will eventually define important Azure infrastructure.

The project progression is:

```text
Create and inspect resources manually
        |
        v
Understand what each resource owns
        |
        v
Represent important infrastructure in Terraform
```

Terraform will be used to improve:

- Reproducibility
- Reviewability
- Repeatable deployment
- Environment recreation
- Cleanup

Terraform must not become a copied template containing resources the project does not understand.

## Security and Identity

Credentials must not be embedded directly in source code.

The project will introduce:

- Azure Key Vault
- Managed identities
- Service principals
- GitHub secrets
- Least privilege
- Environment-based configuration

Rules include:

```text
No secrets in Git
No hard-coded credentials
No credentials stored inside notebooks
Separate configuration from code
```

## Monitoring and Operations

The platform must provide enough information to answer:

```text
Did the pipeline run?
Did it succeed?
Did the data arrive?
Is the data correct?
Is the data fresh?
What failed?
Can the failed part be rerun?
What does the rerun affect?
```

Monitoring will include appropriate combinations of:

- ADF run monitoring
- Databricks job logs
- Structured logs
- Row counts
- Data-quality results
- Pipeline run metadata
- Cost monitoring

## Cost Model

Cloud resources have different cost behavior.

### Storage-driven

Examples:

```text
ADLS Gen2
```

Cost is primarily associated with stored data, operations, and related storage usage.

### Usage-driven

Examples:

```text
Azure Data Factory
```

Cost depends on pipeline and activity execution.

### Compute-driven

Examples:

```text
Azure Databricks
```

Active compute can accumulate cost while running.

Databricks compute therefore requires stronger operational controls such as:

- Smallest practical development compute
- Auto-termination
- Manual termination after exercises
- Regular cost inspection

## Control Plane vs Data Plane

The project distinguishes infrastructure management from data access.

### Control Plane

Examples:

```text
Create storage account
Delete Databricks workspace
Configure a resource
Assign permissions
```

### Data Plane

Examples:

```text
Upload a file
Read a Delta table
Write Parquet data
List storage paths
```

A user or service may have permission to manage a resource without automatically having permission to access the data inside it.

## Architecture Principles

The platform follows these principles:

1. Start from the business problem, not the cloud service.
2. Define grain before designing important datasets.
3. Preserve source deliveries.
4. Separate storage from compute.
5. Separate ingestion from transformation where practical.
6. Separate source-aligned data from trusted data.
7. Design incremental processing intentionally.
8. Make reruns safe.
9. Validate data independently from job success.
10. Protect credentials.
11. Make infrastructure reproducible.
12. Keep failures observable.
13. Control cloud cost.
14. Avoid unnecessary technologies.

## Architecture Version

```text
Version: 1
Status: Initial Project 2 Architecture
Module: Module 0 - Project Kickoff + Architecture + Cost Safety
```

This architecture may evolve during implementation.

Major architectural changes must document:

- What changed
- Why it changed
- What problem the previous design created
- What trade-offs the new design introduces
