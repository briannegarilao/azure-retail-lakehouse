# ADR-001: Choose Azure + Databricks for Project 2

## Status

Accepted

## Date

2026-08-31

## Context

Project 2 upgrades the local batch data-engineering concepts demonstrated in Project 1 into a cloud-oriented analytics and lakehouse platform.

Project 1 proved the core engineering foundations:

- Python-based ingestion
- CSV, JSON, and REST API sources
- PostgreSQL raw, staging, warehouse, and analytics layers
- Incremental loading
- High-water-mark state
- Idempotent upserts
- Dimensional modeling
- Data-quality tests
- Logging and failure handling
- Docker and Docker Compose
- Bash orchestration
- Git and GitHub
- Production-style documentation

Project 2 must preserve those engineering principles while introducing managed cloud storage, distributed processing, cloud-native ingestion, orchestration, infrastructure-as-code, CI/CD, security, monitoring, and cost awareness.

The project is also intended to support an entry-level Data Engineering career path focused on the Makati / BGC job market.

The selected specialization should therefore:

1. Build directly on Project 1 fundamentals.
2. Provide real cloud experience.
3. Introduce modern lakehouse concepts.
4. Develop PySpark and distributed-processing skills.
5. Remain focused enough to avoid shallow multi-cloud learning.
6. Produce a coherent portfolio project.
7. Be realistic to operate within a limited student cloud budget.

## Decision

Project 2 will use Microsoft Azure as the primary cloud platform and Azure Databricks as the primary managed data-processing platform.

The core architecture is:

```text
Sources
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
```

Supporting engineering technologies include:

```text
Git / GitHub
GitHub Actions
Terraform
Azure Key Vault
Azure identity and access controls
Testing
Monitoring
Cost Management
Documentation
```

Azure Data Factory will initially serve as the primary Azure-native ingestion and orchestration service.

Azure Data Lake Storage Gen2 will provide durable cloud storage and allow storage to remain independent of compute.

Azure Databricks will provide the managed Spark environment.

Apache Spark will provide the distributed processing engine.

PySpark will be used to implement distributed transformations.

Delta Lake will provide transactional lakehouse table capabilities such as schema enforcement, MERGE, and version-aware table operations.

dbt will primarily manage SQL-centric analytical transformations and testing from trusted Silver data into Gold analytical models.

Apache Airflow will be introduced through a focused orchestration lab rather than duplicating the entire ADF production implementation.

## Why Azure

Azure was selected because Project 2 is intentionally specialized around Microsoft cloud data engineering instead of attempting to learn AWS, Azure, and GCP simultaneously.

The project will build practical knowledge in:

- Azure resource organization
- Azure Data Lake Storage Gen2
- Azure Data Factory
- Azure Databricks
- Azure identity concepts
- Azure Key Vault
- Azure monitoring
- Azure Cost Management
- Infrastructure provisioning with Terraform

This produces deeper platform knowledge than a broad but shallow multi-cloud project.

## Why Databricks

Databricks was selected because Project 2 needs a managed environment for learning and applying:

- Apache Spark
- PySpark
- Distributed DataFrames
- Partitions
- Lazy evaluation
- Shuffles
- Delta Lake
- Incremental processing
- MERGE operations
- Lakehouse architecture
- Managed jobs and compute

Databricks also provides a practical bridge between local Python/SQL engineering from Project 1 and distributed data-processing concepts that will become more important in later projects.

Databricks is not being added only as a résumé keyword. Its role is to provide scalable compute and lakehouse processing while ADLS remains the durable storage layer.

## Why ADLS Gen2

ADLS Gen2 was selected as the durable storage layer because the architecture requires storage to be separated from compute.

This allows:

- Raw source deliveries to be preserved
- Historical batches to be replayed
- Databricks compute to be stopped without losing durable data
- Multiple processing tools to access the same storage layer
- Data to be organized into landing, Bronze, Silver, and Gold areas
- Infrastructure and compute choices to evolve without coupling all data to one processing engine

## Why Azure Data Factory

ADF was selected as the primary Azure-native ingestion and orchestration service because Project 2 requires a managed way to:

- Connect to files and APIs
- Move data into ADLS
- Schedule pipelines
- Coordinate dependencies
- Apply retries
- Parameterize runs
- Trigger downstream processing
- Monitor pipeline execution

ADF will not own all transformation logic.

Complex distributed transformations remain primarily in Databricks/PySpark, while SQL-centric analytical modeling is managed through dbt.

## Why Delta Lake

Plain Parquet files provide an efficient analytical storage format but do not independently provide all of the table-management behavior needed for reliable incremental pipelines.

Delta Lake adds transaction-aware table semantics on top of Parquet data.

This supports requirements such as:

- Schema enforcement
- Schema evolution
- MERGE
- UPDATE
- DELETE
- Transaction history
- Safe incremental processing
- Reliable reruns

This connects directly to Project 1 concepts such as idempotent upserts and incremental loading.

## Why dbt

dbt is included because Project 2 needs a version-controlled, testable, documented approach to SQL-based analytical transformations.

The initial responsibility boundary is:

```text
PySpark:
Bronze -> Silver

dbt:
Silver -> Gold / Analytics Marts
```

dbt provides:

- SQL model management
- Dependency graphs
- `ref()`
- Data tests
- Documentation
- Lineage
- Incremental model concepts
- Reusable SQL transformation patterns

The exact boundary may evolve if implementation provides a strong engineering reason.

## Alternatives Considered

### AWS

Not selected for Project 2.

Reason:

The project intentionally chooses one primary cloud platform to develop depth rather than spreading learning across multiple clouds.

AWS may be studied later through transferable cloud concepts.

### Google Cloud Platform / BigQuery

The original Project 2 roadmap included GCS and BigQuery.

This was replaced by Azure and Databricks to align the apprenticeship with the selected Microsoft Azure specialization.

The architectural goal did not change. The cloud implementation changed.

### Snowflake

Not selected as a core Project 2 platform.

Reason:

Adding Snowflake alongside Databricks would create overlapping analytical-platform responsibilities and increase breadth without improving the coherence of the project.

Snowflake concepts can be learned later.

### Microsoft Fabric

Not selected as a complete Project 2 platform.

Reason:

Fabric may be explored later, but using both Fabric and the Azure/Databricks architecture as full implementations would duplicate responsibilities.

### Azure Synapse Analytics

Not selected as a second complete data platform.

Reason:

The project should avoid building competing architectures merely for technology coverage.

Synapse can be compared conceptually when useful.

### Airflow as the Only Orchestrator

Not selected initially.

Reason:

ADF is useful for Azure-native ingestion and managed data movement.

Airflow remains valuable for learning portable, code-first orchestration concepts, so it will be implemented as a focused lab rather than replacing ADF before the architecture has been tested.

## Consequences

### Positive Consequences

The project gains:

- A coherent Azure specialization
- Real cloud platform experience
- Managed ingestion through ADF
- Durable object storage through ADLS Gen2
- Distributed processing with Spark/PySpark
- Lakehouse table semantics through Delta Lake
- SQL transformation management with dbt
- Experience with CI/CD, Terraform, identity, monitoring, and cost controls
- Strong continuity from Project 1 concepts
- A focused portfolio story

The final portfolio message becomes:

> I can build and operate a cloud analytics platform, not just a local pipeline.

### Negative Consequences

The project introduces:

- Cloud cost
- More services to configure
- More complex identity and permission boundaries
- Separation between control plane and data plane
- Distributed processing concepts
- Greater operational complexity
- Dependence on managed cloud services during some modules

Azure Databricks compute requires particularly careful cost controls.

### Trade-offs

Choosing Azure + Databricks means Project 2 intentionally does not provide deep hands-on experience with:

- AWS
- GCP
- Snowflake
- Fabric as a complete platform
- Synapse as a complete platform

This is an accepted trade-off.

Depth in one coherent stack is considered more valuable for this apprenticeship than shallow exposure to several competing platforms.

## Cost Consideration

The project uses a limited Azure for Students credit balance.

Cloud resources must therefore be used deliberately.

The architecture will follow these principles:

- Small development datasets
- Smallest practical compute
- Databricks auto-termination
- Manual termination after exercises
- Budget alerts
- Regular cost inspection
- Cleanup documentation
- Free/local practice when Azure-specific integration is not required

Cost policy is documented in:

`docs/cost-safety.md`

## Security Consideration

The architecture must not depend on hard-coded secrets.

Project 2 will progressively introduce:

- Azure Key Vault
- Managed identity concepts
- Service principal concepts
- GitHub secrets
- Environment-based configuration
- Least-privilege access

No credentials should be committed to Git or embedded directly in notebooks or source files.

## Future Migration Path

The engineering concepts learned in this architecture are intended to be portable.

Examples:

```text
ADLS Gen2
-> S3 / GCS concepts

ADF
-> other managed ingestion or orchestration systems

Azure Databricks
-> Databricks on another cloud or other Spark environments

Delta Lake
-> broader lakehouse table-format concepts

dbt
-> multiple analytical warehouses and lakehouse engines

Terraform
-> multi-cloud infrastructure automation
```

Future projects may introduce other platforms when an engineering requirement creates a reason to do so.

## Final Decision

Project 2 will proceed with:

```text
Microsoft Azure
Azure Data Lake Storage Gen2
Azure Data Factory
Azure Databricks
Apache Spark
PySpark
Delta Lake
Medallion Architecture
dbt
GitHub Actions
Terraform
Azure security and monitoring concepts
Apache Airflow focused orchestration lab
```

This decision remains active unless implementation reveals a significant architectural problem that justifies revisiting it.
