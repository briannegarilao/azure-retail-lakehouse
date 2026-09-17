# Azure Retail Analytics Lakehouse Platform

A production-style Azure data engineering project that ingests file and REST API data, stores it in Azure Data Lake Storage Gen2, transforms it with Azure Databricks and PySpark, and organizes trusted Delta Lake tables using a Medallion architecture.

This project is being built as an intermediate data engineering portfolio project focused on the Microsoft Azure + Databricks ecosystem.

## Project Status

**Current state:** Landing, Bronze, and Silver layers are implemented. Incremental Delta `MERGE` processing is the next active module.

```text
Sources
  ↓
Azure Data Factory
  ↓
ADLS Gen2 - Landing
  ↓
Azure Databricks / PySpark
  ↓
Delta Lake
  ├── Bronze   ✅
  ├── Silver   ✅
  └── Gold     ⏳
```

### Completed

- Azure project architecture and cost-safety planning
- Azure resource group and naming convention
- ADLS Gen2 lake storage
- Landing / Bronze / Silver / Gold storage structure
- Azure Data Factory
- File ingestion pipeline
- REST API ingestion pipeline
- Parameterized ADF datasets and pipelines
- API pagination using ADF `ForEach`
- Managed-identity access from ADF to ADLS
- Azure Databricks Premium workspace
- Unity Catalog enabled workspace
- Azure Databricks Access Connector
- Managed-identity access from Databricks to ADLS
- Unity Catalog Storage Credential and External Location
- Spark / PySpark landing exploration
- Bronze Delta tables
- Silver trusted Delta tables
- Data cleaning, validation, deduplication, and referential-integrity checks

### In Progress

- Incremental processing with Delta Lake `MERGE`
- Idempotent reruns and replay-safe processing

### Planned

- Gold dimensional models and analytics marts
- dbt transformations, tests, documentation, and lineage
- Data-quality failure / quarantine patterns
- Focused Apache Airflow orchestration lab
- Production orchestration
- Terraform infrastructure-as-code
- GitHub Actions CI/CD
- Azure Key Vault / production-style secret management
- Monitoring, observability, and operational runbooks
- Failure / recovery exercises
- Final portfolio documentation

---

## Business Problem

A retail organization receives analytical data from multiple source systems, including:

- customer files
- product files
- order files
- REST APIs
- inventory-like operational feeds

The organization needs a cloud data platform that can reliably ingest these sources, preserve source deliveries, create trusted datasets, support safe reruns, and expose analytics-ready models.

The platform must also separate responsibilities across ingestion, storage, compute, governance, security, orchestration, and deployment.

---

## Project Objective

Build an end-to-end Azure lakehouse platform that demonstrates the full data engineering lifecycle:

```text
source contract
→ ingestion
→ durable raw storage
→ distributed transformation
→ trusted data
→ incremental processing
→ dimensional modeling
→ analytics
→ testing
→ orchestration
→ CI/CD
→ infrastructure-as-code
→ monitoring
→ documentation
```

The portfolio goal is to demonstrate:

> I can build and operate a cloud analytics platform, not just a local data pipeline.

---

## Architecture

```text
                    GitHub
                       │
            code / docs / IaC
                       │
                       ▼

FILE SOURCES ───────┐
                    │
REST API ───────────┼────► Azure Data Factory
                    │            │
                    │            ▼
                    │      ADLS Gen2 Landing
                    │            │
                    │            ▼
                    │     Azure Databricks
                    │       Spark / PySpark
                    │            │
                    │            ▼
                    │        Delta Lake
                    │      ┌─────┼─────┐
                    │      ▼     ▼     ▼
                    │   Bronze Silver Gold
                    │            │
                    │            ▼
                    │        dbt / SQL
                    │            │
                    └────────────▼
                         Analytics Models
```

Supporting platform capabilities:

```text
Unity Catalog
Managed Identities
Azure RBAC
Git / GitHub
GitHub Actions
Terraform
Azure Key Vault
Monitoring
Cost Management
Documentation
```

Detailed architecture files are available under:

```text
docs/architecture/
```

---

## Azure Resources

The current development environment uses the following naming convention:

```text
<resource-type>-<project>-<environment>-<region>-<instance>
```

Current primary resources:

| Resource | Name |
|---|---|
| Resource Group | `rg-retail-lakehouse-dev-eas-001` |
| ADLS Gen2 Storage Account | `stretaildeveas001` |
| ADLS Filesystem | `lakehouse` |
| Azure Data Factory | `adf-retail-lakehouse-dev-eas-001` |
| Azure Databricks Workspace | `dbw-retail-lakehouse-dev-eas-001` |
| Databricks Access Connector | `ac-dbx-retail-lakehouse-dev-eas-001` |
| Region | `East Asia` |

The project uses an Azure for Students subscription, so cost controls and resource cleanup are treated as part of the engineering design.

---

## Data Lake Layout

The main ADLS Gen2 filesystem is:

```text
lakehouse/
├── source/
├── landing/
│   ├── customers/
│   ├── products/
│   ├── orders/
│   └── api/
│       └── inventory/
├── bronze/
├── silver/
└── gold/
```

### Layer Responsibilities

**Landing**

Preserves the source delivery as it physically arrived.

```text
What arrived?
```

**Bronze**

Stores source-aligned ingested records as Delta tables with ingestion metadata.

```text
What did the source say?
```

**Silver**

Stores cleaned, typed, validated, deduplicated, and trusted records.

```text
What records do we trust?
```

**Gold**

Will contain business-ready dimensional models and analytical marts.

```text
What does the business need to analyze?
```

---

## Source Data

The project currently uses four logical datasets.

| Dataset | Source | Grain |
|---|---|---|
| Customers | CSV | One customer source record |
| Products | CSV | One product source record |
| Orders | CSV | One order-product transaction record |
| Inventory API | DummyJSON REST API | One API product inventory observation |

The inventory API is intentionally treated as an independent external feed. Its numeric product IDs do not represent the same product master as the local `P001`-style retail product IDs, so the project does not invent a false join between those datasets.

---

## Azure Data Factory

ADF is used for ingestion and orchestration.

### File Ingestion

Pipeline:

```text
pl_ingest_customers_file_to_landing
```

The pipeline copies customer files from the simulated source area into date-organized Landing paths.

The datasets were parameterized so source name, date, and filename are supplied dynamically instead of being hard-coded.

### REST API Ingestion

Pipeline:

```text
pl_ingest_inventory_api_to_landing
```

Source:

```text
https://dummyjson.com/products
```

The API pipeline uses pagination with:

```text
limit=50
skip=0,50,100,150
```

ADF `ForEach` processes the four pages concurrently.

The resulting Landing files contain:

```text
inventory_page_001.json
inventory_page_002.json
inventory_page_003.json
inventory_page_004.json
```

with:

```text
50 + 50 + 50 + 44 = 194 records
```

### ADF Authentication

ADF uses its system-assigned managed identity.

```text
Azure Data Factory
    ↓
System-assigned Managed Identity
    ↓
Storage Blob Data Contributor
    ↓
ADLS Gen2
```

No storage account key is embedded in the pipeline.

---

## Databricks and Unity Catalog

Azure Databricks is used for distributed processing and Delta Lake transformations.

Current workspace:

```text
dbw-retail-lakehouse-dev-eas-001
```

Unity Catalog is enabled.

Databricks accesses ADLS through:

```text
Databricks
    ↓
Unity Catalog External Location
    ↓
Storage Credential
    ↓
Azure Databricks Access Connector
    ↓
System-assigned Managed Identity
    ↓
Storage Blob Data Contributor
    ↓
ADLS Gen2
```

Current Unity Catalog objects:

```text
Storage Credential:
cred_adls_retail_lakehouse

External Location:
ext_retail_lakehouse
```

This avoids placing account keys or secrets inside Spark notebooks.

---

## Current Databricks Data Model

Catalog:

```text
dbw_retail_lakehouse_dev_eas_001
```

Schemas:

```text
bronze
silver
gold
```

### Bronze Tables

```text
dbw_retail_lakehouse_dev_eas_001.bronze
├── customers
├── products
├── orders
└── inventory
```

Current row counts:

| Table | Rows |
|---|---:|
| `bronze.customers` | 7 |
| `bronze.products` | 5 |
| `bronze.orders` | 5 |
| `bronze.inventory` | 194 |

Bronze records include ingestion lineage such as:

```text
_ingested_at
_source_file
```

API transport metadata is also retained where useful.

### Silver Tables

```text
dbw_retail_lakehouse_dev_eas_001.silver
├── customers
├── products
├── orders
└── inventory
```

Silver transformations currently include:

- trimming and standardizing text
- lowercasing customer emails
- uppercasing country and identifier values where appropriate
- required-field validation
- positive quantity and non-negative price checks
- valid order-status checks
- deduplication using Spark window functions
- latest-record retention
- customer/product referential-integrity checks for orders
- derived `line_amount`
- removal of API pagination transport fields from the trusted inventory representation

Current clean sample data produces no rejected rows.

---

## Spark / PySpark Patterns Used

The project currently uses:

```text
spark.read
spark.table
DataFrame
select
filter
withColumn
groupBy
count
orderBy
cast
to_timestamp
explode
Window
row_number
join
write
saveAsTable
```

Important engineering concepts demonstrated so far:

- Spark DataFrames
- lazy evaluation
- transformations vs actions
- nested JSON
- array flattening with `explode`
- explicit type conversion
- metadata lineage
- Delta Lake table creation
- window-based deduplication
- referential-integrity validation

---

## Incremental Processing

The next active module replaces simple full-table overwrite behavior with Delta Lake `MERGE`.

Target pattern:

```text
incoming batch
      ↓
business key match?
   ┌──┴──┐
  yes    no
   │      │
UPDATE  INSERT
```

Examples of intended merge keys:

```text
customers → customer_id
products  → product_id
orders    → order_id + product_id
```

This module is intended to demonstrate:

- upserts
- idempotent reruns
- duplicate-batch safety
- late-arriving data
- changed records
- Delta transaction history
- Delta time travel

---

## Repository Structure

Current and planned repository organization:

```text
azure-retail-lakehouse/
├── README.md
├── data/
│   └── sample/
├── notebooks/
│   ├── 01_landing_exploration.py
│   ├── 02_bronze_ingestion.py
│   ├── 03_silver_transformations.py
│   └── 04_incremental_merge.py
├── adf/
│   ├── pipelines/
│   ├── datasets/
│   ├── linked-services/
│   └── triggers/
├── terraform/
├── docs/
│   ├── adr/
│   ├── architecture/
│   └── cost-safety.md
├── .github/
│   └── workflows/
└── .gitignore
```

Some directories above are planned and will be added as their corresponding project modules are implemented.

---

## Documentation

Current architecture and decision records include:

```text
docs/
├── adr/
│   ├── ADR-001-azure-databricks.md
│   └── ADR-002-adls-gen2.md
├── architecture/
│   ├── architecture-v1.md
│   ├── azure-retail-lakehouse-current-architecture.md
│   ├── azure-retail-lakehouse-identity-access.mmd
│   ├── azure-retail-lakehouse-overview.dot
│   └── azure-retail-lakehouse-overview.mmd
└── cost-safety.md
```

The architecture diagrams can be rendered with Mermaid or Graphviz-compatible tools.

---

## Security Model

The project currently avoids embedding cloud credentials in notebooks or pipeline code.

### ADF

```text
ADF System Managed Identity
→ Storage Blob Data Contributor
→ ADLS
```

### Databricks

```text
Access Connector Managed Identity
→ Storage Blob Data Contributor
→ ADLS
```

### Developer Verification

The signed-in Azure user uses a read-only storage role for CLI-level verification where required.

Future hardening includes:

- Azure Key Vault
- environment separation
- tighter role scope
- service-principal / workload-identity patterns for CI/CD

---

## Cost Safety

This project is built using limited Azure student credits.

Practices include:

- Azure budget alerts
- small learning datasets
- serverless / development-oriented Databricks usage
- stopping unnecessary scheduled triggers
- avoiding duplicate cloud resources
- terminating or avoiding idle compute
- documenting cleanup procedures
- monitoring Azure cost before expanding services

See:

```text
docs/cost-safety.md
```

---

## Engineering Lessons Demonstrated

Several lessons are intentionally carried through the project:

### Green does not always mean correct

An ADF pipeline can succeed while processing the wrong file.

The project explicitly encountered and corrected a case where the visual pipeline appeared parameterized but the dataset JSON was still hard-coded.

```text
syntactic correctness
≠ operational correctness
≠ functional correctness
```

### Retry does not fix configuration errors

ADF retries are useful for transient failures.

They do not fix a missing or incorrect source path.

### Grain comes before keys

Before deduplication, merging, or dimensional modeling, the project defines what one row represents.

Examples:

```text
customers → one customer
products  → one product
orders    → one order-product transaction
inventory → one API product inventory observation
```

### Upstream changes do not automatically refresh downstream data

Bronze, Silver, and Gold are separate persisted states.

A change upstream must be deliberately propagated through downstream transformations.

---

## Technology Stack

### Cloud

- Microsoft Azure
- Azure Data Lake Storage Gen2
- Azure Data Factory
- Azure Databricks
- Microsoft Entra ID
- Azure RBAC

### Data Processing

- Apache Spark
- PySpark
- Delta Lake
- SQL
- Unity Catalog

### Engineering / Delivery

- Git
- GitHub
- GitHub Actions — planned
- Terraform — planned
- dbt — planned
- Apache Airflow — focused lab planned

### Security / Operations

- Managed identities
- Azure Key Vault — planned
- monitoring / observability — planned
- cost management

---

## Out of Scope

The project intentionally does not attempt to specialize in:

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
- full Microsoft Fabric implementation
- full Azure Synapse implementation
- large-scale streaming
- enterprise-scale networking

The objective is depth in the Azure + Databricks lakehouse stack rather than shallow coverage of every platform.

---

## Roadmap

```text
[✓] Project architecture and cost safety
[✓] Azure foundations
[✓] ADLS Gen2
[✓] Azure Data Factory ingestion
[✓] Databricks workspace and secure storage access
[✓] Spark / PySpark foundations
[✓] Delta Lake Bronze
[✓] Trusted Silver
[ ] Incremental Delta MERGE
[ ] Gold dimensional models
[ ] dbt
[ ] data-quality automation
[ ] Airflow lab
[ ] production orchestration
[ ] GitHub Actions CI/CD
[ ] Terraform
[ ] security hardening
[ ] observability / cost controls
[ ] failure and recovery exercises
[ ] final portfolio challenge
```

---

## Current Repository

GitHub:

`https://github.com/briannegarilao/azure-retail-lakehouse`

---

## Author

**Brianne Garilao**

Data Engineering portfolio project focused on Azure, Databricks, PySpark, Delta Lake, and production-style cloud data engineering.
