# Azure Retail Analytics Lakehouse Platform

An end-to-end Azure data engineering project that ingests file and REST API data, stores source deliveries in Azure Data Lake Storage Gen2, transforms data with Azure Databricks and PySpark, models trusted Delta Lake tables using a Medallion architecture, and delivers tested analytics models with dbt.

The project also demonstrates infrastructure-as-code, CI validation, identity-based security, orchestration, observability, failure recovery, and production-oriented documentation.

---

## Project Status

**Status: Core engineering build complete**

```text
Sources
   │
   ▼
Azure Data Factory
   │
   ▼
ADLS Gen2 Landing
   │
   ▼
Azure Databricks / PySpark
   │
   ▼
Delta Lake
   │
   ├── Bronze
   ├── Silver
   └── Gold / dbt Analytics Models
```

Supporting engineering capabilities:

```text
Unity Catalog
Managed Identities
Azure RBAC
Delta MERGE
dbt
Apache Airflow
GitHub Actions
Terraform
Data Quality Testing
Observability
Failure Runbooks
Cost Controls
```

### Implemented

- Azure Data Lake Storage Gen2
- Azure Data Factory file ingestion
- Azure Data Factory REST API ingestion
- parameterized ingestion pipelines
- API pagination
- Azure Databricks
- Apache Spark / PySpark
- Delta Lake
- Bronze, Silver, and Gold layers
- incremental Delta `MERGE`
- idempotent reruns
- dimensional modeling
- dbt transformations
- dbt data-quality tests
- dbt lineage and documentation
- Apache Airflow orchestration lab
- GitHub Actions CI
- Terraform infrastructure-as-code
- managed identities
- Azure RBAC
- Unity Catalog storage access
- Delta transaction history
- monitoring and failure runbooks
- production-readiness documentation
- Azure cost-safety controls

---

# Business Problem

A retail organization receives analytical data from several source systems:

- customer files
- product files
- order files
- REST APIs
- inventory-like operational feeds

The organization needs a cloud data platform that can:

- reliably ingest multiple source types
- preserve source deliveries
- create trusted datasets
- safely process incremental changes
- tolerate reruns
- validate data quality
- expose analytics-ready models
- secure cloud access without embedded credentials
- detect infrastructure drift
- provide operational visibility
- support repeatable deployment practices

---

# Project Objective

The project demonstrates the full data engineering lifecycle:

```text
source contracts
        ↓
ingestion
        ↓
durable storage
        ↓
distributed transformation
        ↓
trusted datasets
        ↓
incremental processing
        ↓
dimensional modeling
        ↓
analytics marts
        ↓
data quality
        ↓
orchestration
        ↓
CI/CD
        ↓
infrastructure-as-code
        ↓
security
        ↓
observability
```

The portfolio objective is to demonstrate the ability to build and reason about a cloud data platform rather than only implement isolated ETL scripts.

---

# Architecture

```text
                           GitHub
                              │
                  Code / Docs / CI / IaC
                              │
                              ▼

CSV FILES ─────────────┐
                       │
REST API ──────────────┼──────► Azure Data Factory
                       │               │
                       │               ▼
                       │         ADLS Gen2 Landing
                       │               │
                       │               ▼
                       │        Azure Databricks
                       │         Spark / PySpark
                       │               │
                       │               ▼
                       │           Delta Lake
                       │        ┌──────┼──────┐
                       │        ▼      ▼      ▼
                       │     Bronze  Silver  Gold
                       │                │
                       │                ▼
                       │               dbt
                       │                │
                       └────────────────▼
                              Analytics Models
```

Cross-cutting platform capabilities:

```text
Unity Catalog
Azure Managed Identities
Azure RBAC
GitHub Actions
Terraform
Apache Airflow
Monitoring
Data Quality
Cost Management
Architecture Decision Records
Operational Runbooks
```

Detailed architecture documentation is available in:

```text
docs/architecture/
```

---

# Technology Stack

## Cloud

- Microsoft Azure
- Azure Data Lake Storage Gen2
- Azure Data Factory
- Azure Databricks
- Microsoft Entra ID
- Azure RBAC

## Data Engineering

- Apache Spark
- PySpark
- Delta Lake
- SQL
- dbt
- Unity Catalog

## Orchestration

- Azure Data Factory
- Apache Airflow

## Infrastructure and Delivery

- Terraform
- Git
- GitHub
- GitHub Actions

## Operations

- dbt data-quality tests
- Delta transaction history
- Terraform drift detection
- Azure cost budgets
- operational runbooks
- production-readiness checklists

---

# Azure Resources

The project uses the following naming convention:

```text
<resource-type>-<project>-<environment>-<region>-<instance>
```

Primary development resources:

| Resource | Name |
|---|---|
| Resource Group | `rg-retail-lakehouse-dev-eas-001` |
| ADLS Gen2 Storage Account | `stretaildeveas001` |
| ADLS Filesystem | `lakehouse` |
| Azure Data Factory | `adf-retail-lakehouse-dev-eas-001` |
| Azure Databricks Workspace | `dbw-retail-lakehouse-dev-eas-001` |
| Databricks Access Connector | `ac-dbx-retail-lakehouse-dev-eas-001` |
| Region | East Asia |

The project was built using limited Azure student credits, so cost control was treated as part of the engineering design.

---

# Data Sources and Grain

A core design rule throughout the project is:

> Define what one row represents before choosing keys, deduplication logic, merge logic, or analytical models.

| Dataset | Source | Grain |
|---|---|---|
| Customers | CSV | One customer source record |
| Products | CSV | One product source record |
| Orders | CSV | One order-product transaction |
| Inventory | REST API | One API product inventory observation |

The external inventory source uses numeric product IDs that are unrelated to the local `P001`-style product IDs.

The project intentionally does not invent a false relationship between those datasets.

---

# Lakehouse Layers

## Landing

Purpose:

> What physically arrived from the source?

Landing preserves source deliveries with minimal modification.

Example layout:

```text
lakehouse/
└── landing/
    ├── customers/
    ├── products/
    ├── orders/
    └── api/
        └── inventory/
```

Landing paths include delivery dates so historical source deliveries can be preserved.

---

## Bronze

Purpose:

> What did the source say?

Bronze stores source-aligned Delta records with ingestion metadata.

Tables:

```text
bronze.customers
bronze.products
bronze.orders
bronze.inventory
```

Metadata includes fields such as:

```text
_ingested_at
_source_file
```

Bronze performs only the minimum transformations needed to create structured, traceable Delta records.

---

## Silver

Purpose:

> What records do we trust?

Silver transformations include:

- type conversion
- trimming and normalization
- email normalization
- identifier normalization
- required-field validation
- positive quantity checks
- non-negative price validation
- valid status checks
- deduplication
- latest-record retention
- referential-integrity checks
- derived `line_amount`
- removal of unnecessary API transport metadata

Tables:

```text
silver.customers
silver.products
silver.orders
silver.inventory
```

---

## Gold

Purpose:

> What does the business need to analyze?

Gold introduces dimensional modeling and business-ready aggregations.

Core models include:

```text
dim_customers
dim_products
fact_orders
```

Analytics marts include:

```text
mart_customer_sales
mart_product_sales
mart_daily_sales
```

The fact-table grain is:

```text
one order-product transaction
```

---

# Azure Data Factory

ADF is responsible primarily for source ingestion and Azure-side orchestration.

## File Ingestion

Example pipeline:

```text
pl_ingest_customers_file_to_landing
```

The pipeline moves source files into date-organized Landing paths.

Dataset and pipeline parameters are used rather than hard-coded source paths.

A real project failure exposed why this matters: the visual pipeline originally appeared parameterized while an underlying dataset still referenced a fixed date.

This produced one of the project's core lessons:

```text
syntactic correctness
        ≠
operational correctness
        ≠
functional correctness
```

---

## REST API Ingestion

Pipeline:

```text
pl_ingest_inventory_api_to_landing
```

Development source:

```text
DummyJSON products endpoint
```

Pagination pattern:

```text
limit = 50
skip  = 0, 50, 100, 150
```

ADF `ForEach` processes the pages and lands separate JSON source deliveries.

Observed records:

```text
50 + 50 + 50 + 44 = 194
```

---

# Spark and PySpark

Spark is the processing engine used inside Databricks.

PySpark patterns demonstrated include:

```text
spark.read
spark.table
select
filter
withColumn
cast
to_timestamp
groupBy
explode
join
Window
row_number
saveAsTable
```

Engineering concepts demonstrated:

- DataFrames
- lazy evaluation
- transformations vs actions
- explicit typing
- nested JSON processing
- array flattening
- window functions
- distributed deduplication
- referential-integrity validation
- Delta table operations
- source lineage metadata

---

# Incremental Processing

The project implements incremental processing with Delta Lake `MERGE`.

Pattern:

```text
Incoming Record
       │
       ▼
Business Key Exists?
     /     \
   yes      no
    │        │
 UPDATE    INSERT
```

Merge keys include:

```text
customers → customer_id
orders    → order_id + product_id
```

The implementation demonstrates:

- inserts
- updates
- idempotent reruns
- duplicate-batch safety
- changed records
- composite merge keys
- Delta transaction history
- time travel

A repeated customer merge maintained the expected row count rather than duplicating previously processed records.

---

# Delta Lake Observability

Delta transaction history is used to inspect table operations.

Example:

```sql
DESCRIBE HISTORY dbw_retail_lakehouse_dev_eas_001.bronze.customers;
```

Observed operations include:

```text
WRITE
MERGE
OPTIMIZE
```

This allows the project to inspect how a table changed over time rather than only whether a pipeline executed.

---

# dbt Analytics Layer

dbt manages SQL transformations and analytics models downstream of Silver.

Project structure:

```text
dbt/retail_lakehouse/
├── models/
│   ├── staging/
│   │   ├── stg_customers.sql
│   │   ├── stg_products.sql
│   │   └── stg_orders.sql
│   └── marts/
│       ├── dim_customers.sql
│       ├── dim_products.sql
│       ├── fact_orders.sql
│       ├── mart_customer_sales.sql
│       ├── mart_product_sales.sql
│       └── mart_daily_sales.sql
└── tests/
```

The development output schema is:

```text
dbt_dev
```

This prevents development transformations from blindly replacing the existing Gold layer while the dbt implementation is being validated.

---

# Data Quality

The dbt project currently executes:

```text
9 models
37 data tests
46 total build operations
```

Successful build result:

```text
PASS=46
WARN=0
ERROR=0
SKIP=0
```

Validation covers:

- not-null constraints
- uniqueness
- referential integrity
- accepted values
- positive order quantities
- non-negative unit prices
- non-negative line amounts
- order-line calculation correctness

Example business-rule test:

```text
line_amount = quantity × unit_price
```

A key principle of the project is:

> Pipeline success and data-quality success are different things.

A job can complete technically while still producing invalid data.

---

# Orchestration

## Azure Data Factory

ADF remains the primary Azure ingestion orchestrator.

Conceptual production flow:

```text
Sources
   ↓
ADF
   ↓
Landing
   ↓
Databricks
   ↓
Silver
   ↓
dbt
   ↓
Analytics Models
```

## Apache Airflow Lab

A focused Airflow lab demonstrates general workflow orchestration.

DAG:

```text
retail_lakehouse_dbt_pipeline
```

Flow:

```text
Airflow
   ↓
BashOperator
   ↓
dbt build
   ↓
Databricks SQL Warehouse
```

Airflow successfully executed the dbt project with all 46 build operations passing.

Airflow is intentionally treated as an orchestration lab rather than a replacement for ADF in this Azure-focused architecture.

---

# CI with GitHub Actions

GitHub Actions automatically validates repository changes.

Current workflow runs on pushes and pull requests to `main`.

Checks include:

```text
Validate dbt
Validate Python
```

The CI pipeline verifies:

- dbt project parsing
- Airflow/Python syntax compilation

Latest validated workflow state:

```text
Validate dbt    ✅
Validate Python ✅
```

Cloud credentials are not committed to the repository.

A CI-only dbt profile is used for parse-time validation.

---

# Infrastructure as Code

Terraform represents the core Azure infrastructure.

Managed resources include:

```text
Resource Group
ADLS Gen2 Storage Account
ADLS Filesystem
Azure Data Factory
Azure Databricks Workspace
Databricks Access Connector
ADF Storage RBAC Assignment
Databricks Storage RBAC Assignment
```

The infrastructure originally existed manually and was safely adopted into Terraform using `terraform import`.

Final validation:

```text
No changes. Your infrastructure matches the configuration.
```

This demonstrates:

- infrastructure declaration
- Terraform state
- existing-resource import
- drift detection
- provider locking
- safe planning before applying changes

Terraform state files are excluded from Git.

The provider lock file is committed for reproducibility.

---

# Security and Identity

The project avoids embedding storage keys in pipelines and notebooks.

## Azure Data Factory

```text
Azure Data Factory
       ↓
System-Assigned Managed Identity
       ↓
Storage Blob Data Contributor
       ↓
ADLS Gen2
```

## Azure Databricks

```text
Databricks
       ↓
Unity Catalog Storage Credential
       ↓
Databricks Access Connector
       ↓
System-Assigned Managed Identity
       ↓
Storage Blob Data Contributor
       ↓
ADLS Gen2
```

Storage security includes:

```text
HTTPS-only traffic         enabled
Minimum TLS                TLS 1.2
Hierarchical Namespace     enabled
Public blob access         disabled
```

The current development environment allows public network access at selected service boundaries.

A production environment should evaluate:

- private endpoints
- tighter firewall rules
- private Databricks networking
- workload identity for CI/CD
- centralized audit logging
- environment-specific isolation

See:

```text
docs/security/security-model.md
docs/adr/ADR-003-managed-identities.md
```

---

# Observability

The project uses multiple observability layers.

```text
ADF
├── pipeline status
├── activity failures
└── retries

Delta Lake
├── transaction history
├── MERGE history
└── table versions

dbt
├── model execution
├── data tests
└── quality failures

GitHub Actions
└── CI validation

Terraform
└── infrastructure drift

Azure
└── cost controls
```

No single monitoring signal is treated as sufficient.

A production data platform should answer:

1. Did the pipeline execute successfully?
2. Is the resulting data correct?
3. Is the infrastructure healthy and operating within expected cost?

---

# Failure Engineering

The project encountered and documented real failure scenarios.

Examples include:

### Missing source file

ADF returned:

```text
UserErrorFileNotFound
```

Retries did not resolve the deterministic failure.

Lesson:

> Retry transient failures. Fix deterministic failures.

### Incorrect parameterization

A pipeline completed successfully while processing the wrong delivery date.

Lesson:

> A green pipeline does not guarantee functional correctness.

### Airflow metadata failure

Airflow initially failed because its metadata database was not initialized correctly.

Lesson:

> Orchestration infrastructure has its own operational state.

### Terraform configuration mistake

CLI import commands were accidentally placed inside `main.tf`.

Lesson:

> Terraform configuration describes infrastructure; CLI commands manipulate configuration, state, and infrastructure.

### Duplicate Terraform import

Terraform prevented the same remote role assignment from being imported twice.

Lesson:

> Terraform state defines ownership of remote infrastructure objects.

### Incremental rerun

Repeated Delta `MERGE` execution did not duplicate previously processed entities.

Lesson:

> Idempotency makes pipeline recovery safer.

See:

```text
docs/operations/failure-drills.md
docs/operations/pipeline-failure-runbook.md
```

---

# Cost Safety

The project is designed for a limited-credit Azure environment.

Cost-management practices include:

- Azure budget alerts
- small development datasets
- stopping unnecessary triggers
- avoiding duplicate Azure resources
- terminating unused compute
- treating Databricks compute as the primary cost risk
- validating infrastructure before applying changes

The project deliberately avoids deploying infrastructure simply to make the architecture appear more complex.

See:

```text
docs/cost-safety.md
```

---

# Repository Structure

```text
azure-retail-lakehouse/
├── .github/
│   └── workflows/
│       └── ci.yml
│
├── airflow/
│   └── dags/
│       └── retail_lakehouse_dbt_pipeline.py
│
├── data/
│   └── sample/
│
├── dbt/
│   └── retail_lakehouse/
│       ├── models/
│       └── tests/
│
├── docs/
│   ├── adr/
│   ├── architecture/
│   ├── operations/
│   ├── security/
│   └── cost-safety.md
│
├── notebooks/
│   ├── 01_landing_exploration.py
│   ├── 02_bronze_ingestion.py
│   ├── 03_silver_transformations.py
│   ├── 04_incremental_merge.py
│   └── 05_gold_dimensional_model.py
│
├── terraform/
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── variables.tf
│   └── .terraform.lock.hcl
│
├── .gitignore
└── README.md
```

---

# Documentation

The repository contains production-style engineering documentation rather than relying only on code.

## Architecture

```text
docs/architecture/
```

## Architecture Decision Records

```text
ADR-001 Azure Databricks
ADR-002 ADLS Gen2
ADR-003 Managed Identities
```

## Security

```text
docs/security/security-model.md
```

## Operations

```text
docs/operations/
├── observability-and-cost.md
├── pipeline-failure-runbook.md
├── failure-drills.md
└── production-readiness-checklist.md
```

---

# Key Engineering Lessons

## Define grain before keys

Before choosing a merge key, primary key, or deduplication rule:

> What should one row represent?

This question drives the rest of the data model.

---

## Green does not always mean correct

```text
syntactic correctness
≠
operational correctness
≠
functional correctness
```

Successful execution must be followed by validation of the expected input and output.

---

## Storage and compute are separate

```text
ADLS
= durable storage

Databricks
= managed compute platform

Spark
= distributed processing engine
```

---

## Authentication and authorization are different

```text
Managed Identity
= who the workload is

Azure RBAC
= what the workload is allowed to do
```

---

## Upstream changes do not automatically update downstream layers

```text
Bronze
   ↓
Silver
   ↓
Gold
```

Each layer is persisted independently.

Changes must be deliberately propagated.

---

## Idempotency matters

A pipeline should be safe to rerun.

Repeated processing of the same batch should not silently duplicate or corrupt downstream data.

---

## Infrastructure is also code

Application code is only one part of a data platform.

Infrastructure configuration, identity, permissions, monitoring, CI, and failure recovery are also engineering concerns.

---

# Development vs Production

This project follows production-oriented design principles, but it is intentionally a portfolio/development environment.

A larger production deployment should additionally evaluate:

- separate dev / staging / production environments
- remote Terraform state
- private networking
- centralized monitoring and alerting
- production CI/CD identity
- disaster recovery
- backup strategy
- SLA / SLO definitions
- larger-scale performance testing
- formal data governance policies

These are documented as production-hardening opportunities rather than being unnecessarily deployed in a limited-credit learning environment.

---

# Project Outcomes

The completed project demonstrates practical experience with:

```text
Azure
ADLS Gen2
Azure Data Factory
Azure Databricks
Apache Spark
PySpark
Delta Lake
Medallion Architecture
Incremental MERGE
Dimensional Modeling
dbt
Data Quality Testing
Apache Airflow
Terraform
GitHub Actions
Managed Identities
Azure RBAC
Unity Catalog
Observability
Failure Recovery
Technical Documentation
```

---

# Repository

GitHub:

`https://github.com/briannegarilao/azure-retail-lakehouse`

---

# Author

**Brianne Garilao**

Data Engineering portfolio project focused on Azure, Databricks, PySpark, Delta Lake, dbt, Terraform, and production-oriented cloud data engineering.