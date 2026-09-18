select *
from {{ ref('fact_orders') }}
where line_amount < 0