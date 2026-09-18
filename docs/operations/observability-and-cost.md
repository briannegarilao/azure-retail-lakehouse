# Observability and Cost Management

## Overview

The Azure Retail Analytics Lakehouse uses monitoring at multiple layers rather
than relying on a single success indicator.

The primary observability layers are:

- Azure Data Factory pipeline monitoring
- Databricks and Delta Lake history
- dbt data-quality tests
- GitHub Actions CI status
- Terraform infrastructure drift detection
- Azure cost budgets and alerts

## Azure Data Factory

Azure Data Factory provides operational monitoring for ingestion workflows.

Key signals include:

- pipeline run status
- activity run status
- execution duration
- trigger history
- retry behavior
- failure messages

A successful ADF run confirms that the orchestration workflow executed, but it
does not by itself guarantee that the resulting data is correct.

## Databricks and Delta Lake

Databricks provides transformation-level execution visibility.

Delta Lake also maintains transaction history for tables.

`DESCRIBE HISTORY` can be used to inspect operations such as:

- WRITE
- MERGE
- OPTIMIZE

This provides table-level lineage and operational history.

## dbt

dbt provides transformation and data-quality observability.

The project currently validates:

- required values
- uniqueness
- referential integrity
- accepted values
- positive quantities
- non-negative monetary values
- calculated line amounts

Pipeline success and data-quality success are treated as separate concerns.

## GitHub Actions

GitHub Actions provides CI visibility for repository changes.

Current CI checks include:

- dbt project parsing
- Python compilation

Pull requests and pushes to the main branch automatically execute these checks.

## Terraform

Terraform provides infrastructure drift detection.

`terraform plan` compares:

1. Terraform configuration
2. Terraform state
3. Azure infrastructure

A clean plan indicates that the managed infrastructure matches the declared
configuration.

## Cost Management

The project uses an Azure subscription budget to reduce the risk of unexpected
costs.

Databricks compute is treated as the primary cost risk.

Development practice:

1. start compute only when required
2. complete the workload
3. terminate or stop unused compute
4. review Azure budget notifications

ADLS and small ADF workloads have substantially lower cost risk for this
learning workload.

## Monitoring Principle

A production data platform should answer three different questions:

1. Did the pipeline execute successfully?
2. Is the resulting data correct?
3. Is the infrastructure healthy and operating within budget?

No single monitoring signal answers all three.