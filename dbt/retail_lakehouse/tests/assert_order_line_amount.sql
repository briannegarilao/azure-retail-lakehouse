select *
from {{ ref('fact_orders') }}
where abs(
    line_amount - (quantity * unit_price)
) > 0.01