select
    customer_id,
    first_name,
    last_name,
    concat_ws(' ', first_name, last_name) as full_name,
    email,
    country,
    created_at
from {{ ref('stg_customers') }}
