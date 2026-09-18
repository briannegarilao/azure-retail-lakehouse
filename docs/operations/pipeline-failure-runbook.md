# Pipeline Failure Runbook

## Purpose

This runbook describes the first-response process when the retail lakehouse
pipeline fails.

## 1. Identify the Failed Layer

Determine whether the failure occurred in:

- ingestion
- storage
- transformation
- data quality
- orchestration
- authentication / authorization
- infrastructure

Do not immediately rerun the pipeline without identifying the failure type.

## 2. Check ADF

Review:

- pipeline status
- failed activity
- error message
- source path or endpoint
- retry attempts

Examples:

- missing source file
- REST API failure
- authentication failure
- sink write failure

## 3. Check Landing Data

Confirm that the expected source delivery exists in ADLS.

Validate:

- expected path
- expected filename
- expected delivery date
- file size
- file format

## 4. Check Databricks / Delta

Confirm that the expected Bronze and Silver tables were updated.

Inspect Delta history when required:

DESCRIBE HISTORY <table>;

Check:

- row counts
- MERGE operations
- schema changes
- duplicate behavior

## 5. Check dbt

Run:

dbt build

Review:

- failed models
- failed tests
- relationship violations
- null values
- accepted-value failures
- business-rule failures

## 6. Classify the Failure

Transient failures may be retried.

Examples:

- temporary network failure
- service throttling
- temporary service outage

Deterministic failures should be fixed before retrying.

Examples:

- incorrect file path
- schema mismatch
- invalid credentials
- missing source file
- broken SQL
- data-quality violation

## 7. Verify Recovery

After correcting the issue:

1. rerun the failed workflow
2. confirm orchestration success
3. confirm expected row counts
4. confirm dbt tests pass
5. confirm downstream marts are refreshed

## Principle

A successful rerun is not sufficient by itself.

Recovery is complete only when both pipeline execution and data quality are
verified.