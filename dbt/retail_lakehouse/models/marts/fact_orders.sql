select
    order_id,
    customer_id,
    product_id,
    quantity,
    unit_price,
    line_amount,
    order_timestamp,
    cast(order_timestamp as date) as order_date,
    status
from {{ ref('stg_orders') }}
