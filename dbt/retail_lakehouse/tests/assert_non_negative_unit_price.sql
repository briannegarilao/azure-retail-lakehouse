select *
from {{ ref('fact_orders') }}
where unit_price < 0