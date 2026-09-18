select
    c.customer_id,
    c.full_name,
    c.country,
    count(distinct f.order_id) as order_count,
    sum(f.quantity) as units_purchased,
    sum(f.line_amount) as total_sales
from {{ ref('fact_orders') }} f
left join {{ ref('dim_customers') }} c
    on f.customer_id = c.customer_id
group by
    c.customer_id,
    c.full_name,
    c.country
