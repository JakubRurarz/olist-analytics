with order_items as (
    select * from {{ ref('stg_order_items') }}
),

orders as (
    select
        order_id,
        customer_id,
        order_status,
        ordered_at
    from {{ ref('stg_orders') }}
),

final as (
    select
        order_items.order_id,
        order_items.order_item_id,
        order_items.product_id,
        order_items.seller_id,
        orders.customer_id,
        orders.order_status,
        orders.ordered_at,
        order_items.shipping_limit_at,
        order_items.price,
        order_items.freight_value,
        order_items.price + order_items.freight_value as total_item_value
    from order_items
    left join orders
        on order_items.order_id = orders.order_id
)

select * from final