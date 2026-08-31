# Cost Safety

## Purpose

This document defines the cost-safety rules for the Azure Retail Analytics Lakehouse Platform.

The project uses a limited Azure for Students credit balance, so every cloud resource must be created deliberately, monitored while active, and cleaned up when no longer needed.

The goal is to gain real Azure and Databricks experience without allowing unnecessary cloud usage to consume the project budget.

## Current Budget Context

At Project 2 kickoff:

- Azure for Students subscription is active
- Starting credit: USD 100
- Current spend at kickoff: USD 0
- Credit validity: 12 months from activation
- Subscription must be checked before every major deployment

The exact remaining balance should always be verified in Azure Cost Management rather than assumed from this document.

## Cost-Safety Principles

1. Understand what a resource does before creating it.
2. Understand what causes that resource to incur cost.
3. Use the smallest practical development configuration.
4. Prefer short-lived compute over continuously running compute.
5. Stop or terminate compute immediately after exercises.
6. Use auto-termination where available.
7. Keep learning datasets small.
8. Avoid duplicate services that solve the same problem.
9. Check cost regularly during cloud-heavy modules.
10. Document how to delete or destroy resources when they are created.
11. Do not treat a budget alert as a hard spending cap.
12. Prefer free or local practice when the cloud service itself is not the learning objective.

## Cost Categories

### Storage-Driven Resources

Primary example:

- Azure Data Lake Storage Gen2

Cost may depend on:

- Amount of data stored
- Read operations
- Write operations
- Other storage transactions
- Data movement or transfer in some scenarios

Project rule:

> Keep Project 2 datasets small and avoid generating unnecessary copies or huge numbers of tiny files.

Storage is expected to be relatively inexpensive for this portfolio project, but it is not assumed to be free.

### Usage-Driven Resources

Primary example:

- Azure Data Factory

Cost may depend on:

- Pipeline executions
- Activity executions
- Data movement
- Integration runtime usage
- Debug or test runs

Project rule:

> Do not repeatedly run pipelines without a reason. Test deliberately and inspect the result before rerunning.

### Compute-Driven Resources

Primary example:

- Azure Databricks compute

This is the highest cost-safety concern in Project 2.

Active compute may continue accumulating cost while it is running, even if no useful work is being performed.

Required workflow:

```text
Start compute
    |
    v
Perform exercise
    |
    v
Verify result
    |
    v
Terminate compute
```

Project rules:

- Use the smallest practical development compute
- Enable auto-termination where available
- Never leave compute running casually
- Check compute status before ending a work session
- Prefer Databricks Free Edition for repeated learning when Azure integration is not required
- Use real Azure Databricks when Azure-specific integration is the learning objective

## Azure Budget and Alerts

A budget should be configured before significant cloud usage.

Recommended initial alert thresholds:

- 25% of project credit used
- 50% of project credit used
- 75% of project credit used
- 90% of project credit used

Important:

> Azure budget notifications are alerts, not automatic shutdown controls.

A budget warning does not replace resource cleanup or compute termination.

## Recommended Internal Project Budget

The USD 100 student credit should be treated as a finite engineering budget.

Suggested working policy:

```text
USD 100 total student credit

Keep the majority reserved for:
- Azure Databricks
- Azure Data Factory integration testing
- Real end-to-end Azure deployments

Minimize spending on:
- Idle compute
- Repeated debug runs
- Duplicate environments
- Large unnecessary datasets
- Services outside Project 2 scope
```

No fixed dollar allocation per service is guaranteed because Azure pricing varies by region, configuration, and usage.

Actual pricing must be checked when each paid resource is provisioned.

## Resource Creation Checklist

Before creating a new Azure resource, answer:

- [ ] What engineering problem does this resource solve?
- [ ] Is it part of the approved Project 2 architecture?
- [ ] Is there a free or local alternative for the current lesson?
- [ ] What exactly causes this resource to incur cost?
- [ ] Is the resource continuously billed or usage-based?
- [ ] What is the smallest practical development configuration?
- [ ] Can it auto-stop or auto-terminate?
- [ ] How will I verify that it is no longer running?
- [ ] How do I delete or destroy it?
- [ ] Do I know which Azure subscription and resource group it will use?

If these questions cannot be answered, do not deploy the resource yet.

## End-of-Session Checklist

Before ending a cloud development session:

- [ ] Check Databricks compute state
- [ ] Terminate compute that is no longer needed
- [ ] Check for unnecessary active jobs
- [ ] Check ADF pipeline/debug runs if relevant
- [ ] Confirm no temporary compute resource was forgotten
- [ ] Review Azure Cost Management when the session involved paid compute
- [ ] Record any resource that still needs cleanup later

## Databricks-Specific Rules

Databricks receives stricter controls because it can create compute-backed cost.

Required rules:

- Auto-termination must be enabled where available
- Development compute should use the smallest configuration that supports the lesson
- Compute is started only when required
- Compute is terminated after verification
- Expensive scale testing is outside Project 2 scope
- Idle compute is considered a preventable cost incident
- Before leaving a work session, compute state must be checked manually

## Data Factory-Specific Rules

ADF development should be intentional.

Rules:

- Avoid unnecessary repeated debug executions
- Validate paths, parameters, and configuration before running
- Use small source files during development
- Inspect failed runs before retrying
- Do not create duplicate pipelines merely for experimentation when parameters can solve the same problem

## ADLS-Specific Rules

ADLS storage is expected to remain small for this project.

Rules:

- Store only project-related datasets
- Keep test data intentionally small
- Preserve source deliveries when they have engineering value
- Avoid unnecessary duplicate copies
- Avoid generating excessive tiny files
- Clean up temporary development paths when they are no longer useful

## Terraform Cost Safety

Terraform can automatically create paid Azure resources.

Before:

```bash
terraform apply
```

the learner must understand the planned resources.

Required workflow:

```text
terraform fmt
terraform validate
terraform plan
review the plan
terraform apply
```

Never treat `terraform apply` as a harmless command.

Likewise:

```bash
terraform destroy
```

must be reviewed because deleting resources can also delete data or shared infrastructure.

## Cleanup Policy

Every resource introduced in Project 2 must eventually have a documented cleanup path.

Cleanup may involve:

- Terminating Databricks compute
- Deleting temporary ADF resources
- Deleting unused storage paths
- Deleting Azure resources manually during early learning
- Destroying Terraform-managed resources later in the project

The project runbook will eventually contain exact cleanup procedures.

## Services Deliberately Avoided for Cost and Scope Control

Project 2 will not deploy competing platforms merely for comparison.

Examples intentionally excluded from the core implementation include:

- Snowflake
- Azure Synapse as a second full platform
- Microsoft Fabric as a second full platform
- AWS
- Google Cloud Platform
- Kubernetes
- Kafka infrastructure
- Large real-time streaming environments

This protects both project focus and cloud credit.

## Cost Incident Response

If unexpected Azure spending is detected:

1. Identify the resource responsible.
2. Stop or terminate active compute.
3. Pause unnecessary jobs or pipelines.
4. Inspect the resource in Azure Cost Management.
5. Determine whether the resource is still required.
6. Delete or resize unnecessary infrastructure.
7. Document what caused the unexpected cost.
8. Update the project safety checklist if a new failure mode was discovered.

The purpose is not only to stop the charge but to understand why it occurred.

## Module 0 Cost Gate

Before Project 2 proceeds to normal Azure provisioning, the following must be true:

- [x] Azure for Students subscription activated
- [x] Starting credit confirmed
- [x] Current spend checked at kickoff
- [x] Databricks identified as the primary active-compute cost risk
- [x] Cost categories understood: storage, usage, compute
- [x] Resource cleanup is part of the project design
- [ ] Azure budget / cost alerts configured
- [ ] Resource naming and tagging convention defined
- [ ] First Azure resource deployment reviewed before creation

## Current Status

```text
Project: Azure Retail Analytics Lakehouse Platform
Module: Module 0 - Project Kickoff + Architecture + Cost Safety
Cost Policy Status: Defined
Cloud Provisioning Status: Not yet started
```
