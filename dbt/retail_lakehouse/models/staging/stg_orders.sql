select
    order_id,
    customer_id,
    product_id,
    quantity,
    unit_price,
    line_amount,
    order_timestamp,
    status
from {{ source('silver', 'orders') }}
