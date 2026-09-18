# Failure Drills and Lessons Learned

## 1. Missing ADF Source File

### Failure

ADF attempted to ingest a source file that did not exist.

### Result

The pipeline failed with:

`UserErrorFileNotFound`

The retry policy attempted the operation again but could not resolve the issue.

### Lesson

Retries are appropriate for transient failures but do not fix deterministic
configuration or missing-data problems.

---

## 2. Incorrect ADF Parameterization

### Failure

The ADF pipeline appeared to use dynamic parameters but the underlying dataset
still contained a hard-coded path.

The pipeline reported success while processing the wrong delivery date.

### Lesson

Syntactic success is not the same as functional correctness.

A pipeline should validate:

1. successful execution
2. expected source
3. expected destination
4. expected output

---

## 3. Airflow Metadata Initialization

### Failure

Airflow initially failed because its metadata database had not been correctly
initialized.

An error referenced a missing `serialized_dag` table.

### Resolution

The metadata database was initialized/migrated before starting Airflow.

### Lesson

An orchestrator has its own operational state and infrastructure requirements.

Application code can be correct while the orchestration platform itself is not
ready.

---

## 4. Terraform Configuration vs CLI Commands

### Failure

`terraform import` CLI commands were accidentally placed inside `main.tf`.

Terraform reported syntax and block-definition errors.

### Resolution

CLI commands were removed from the Terraform configuration and executed in the
terminal instead.

### Lesson

Terraform configuration and Terraform CLI operations are separate concepts.

`.tf` files describe desired infrastructure.

CLI commands operate on configuration, state, and infrastructure.

---

## 5. Duplicate Terraform Import

### Failure

An already-imported role assignment was imported a second time.

Terraform rejected the operation because the resource was already managed.

### Lesson

Terraform state maps one configuration resource address to one remote object.

Existing state should be inspected before repeating imports.

---

## 6. Incremental Pipeline Rerun

### Test

Incremental customer and order MERGE operations were executed repeatedly.

### Result

Previously processed rows were updated rather than duplicated.

### Lesson

Idempotency is an important production property.

Rerunning the same delivery should not corrupt downstream data.

---

## 7. Data Quality Validation

### Test

The dbt project executed model and data-quality checks.

### Result

46 build operations completed successfully, including 37 tests.

### Lesson

Operational success does not guarantee data correctness.

Data-quality checks should be treated as a pipeline quality gate.