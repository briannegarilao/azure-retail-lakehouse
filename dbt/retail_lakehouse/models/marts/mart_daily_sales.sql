select
    order_date,
    count(distinct order_id) as order_count,
    sum(quantity) as units_sold,
    sum(line_amount) as total_sales
from {{ ref('fact_orders') }}
group by order_date
