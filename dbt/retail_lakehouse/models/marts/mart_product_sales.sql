select
    p.product_id,
    p.product_name,
    p.category,
    count(distinct f.order_id) as order_count,
    sum(f.quantity) as units_sold,
    sum(f.line_amount) as total_sales
from {{ ref('fact_orders') }} f
left join {{ ref('dim_products') }} p
    on f.product_id = p.product_id
group by
    p.product_id,
    p.product_name,
    p.category
