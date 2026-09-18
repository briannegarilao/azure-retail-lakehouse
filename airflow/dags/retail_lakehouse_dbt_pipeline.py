from datetime import datetime, timedelta

from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator


DBT_PROJECT_DIR = (
    "/home/briannegarilao/projects/"
    "azure-retail-lakehouse/dbt/retail_lakehouse"
)

DBT_VENV = (
    "/home/briannegarilao/projects/"
    "azure-retail-lakehouse/dbt/.venv"
)


default_args = {
    "owner": "data-engineering",
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=1),
}


with DAG(
    dag_id="retail_lakehouse_dbt_pipeline",
    description="Run dbt transformations and tests for the retail lakehouse.",
    default_args=default_args,
    start_date=datetime(2026, 9, 1),
    schedule=None,
    catchup=False,
    tags=["retail", "dbt", "lakehouse"],
) as dag:

    check_dbt = BashOperator(
        task_id="check_dbt",
        bash_command=f"{DBT_VENV}/bin/dbt --version",
    )

    dbt_build = BashOperator(
        task_id="dbt_build",
        bash_command=(
            f"cd {DBT_PROJECT_DIR} && "
            f"{DBT_VENV}/bin/dbt build"
        ),
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=(
            f"cd {DBT_PROJECT_DIR} && "
            f"{DBT_VENV}/bin/dbt test"
        ),
    )

    check_dbt >> dbt_build >> dbt_test