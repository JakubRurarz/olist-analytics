with customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select
        customer_id,
        count(order_id)     as order_count,
        min(ordered_at)     as first_order_at,
        max(ordered_at)     as last_order_at
    from {{ ref('stg_orders') }}
    group by customer_id
),

final as (
    select
        customers.customer_id,
        customers.customer_unique_id,
        customers.customer_city,
        customers.customer_state,
        customers.customer_zip_code_prefix,
        orders.order_count,
        orders.first_order_at,
        orders.last_order_at
    from customers
    left join orders
        on customers.customer_id = orders.customer_id
)

select * from final