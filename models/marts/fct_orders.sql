with orders as (
    select * from {{ ref('stg_orders') }}
),

order_items as (
    select * from {{ ref('stg_order_items') }}
),

order_payments as (
    select * from {{ ref('stg_order_payments') }}
),

order_reviews as (
    select * from {{ ref('stg_order_reviews') }}
),

order_items_aggregated as (
    select
        order_id,
        count(order_item_id)        as item_count,
        sum(price)                  as revenue,
        sum(freight_value)          as freight_cost
    from order_items
    group by order_id
),

order_payments_aggregated as (
    select
        order_id,
        sum(payment_value)          as total_payment_value,
        count(distinct payment_type) as payment_type_count
    from order_payments
    group by order_id
),

order_reviews_aggregated as (
    select
        order_id,
        avg(review_score)           as avg_review_score
    from order_reviews
    group by order_id
),

final as (
    select
        orders.order_id,
        orders.customer_id,
        orders.order_status,
        orders.ordered_at,
        orders.approved_at,
        orders.delivered_to_carrier_at,
        orders.delivered_to_customer_at,
        orders.estimated_delivery_at,

        -- delivery metrics
        timestamp_diff(
            orders.delivered_to_customer_at,
            orders.ordered_at,
            day
        )                                           as delivery_days,

        timestamp_diff(
            orders.estimated_delivery_at,
            orders.delivered_to_customer_at,
            day
        )                                           as days_before_estimated,

        -- order metrics
        coalesce(order_items_aggregated.item_count, 0)      as item_count,
        coalesce(order_items_aggregated.revenue, 0)         as revenue,
        coalesce(order_items_aggregated.freight_cost, 0)    as freight_cost,

        -- payment metrics
        order_payments_aggregated.total_payment_value,
        order_payments_aggregated.payment_type_count,

        -- review metrics
        order_reviews_aggregated.avg_review_score

    from orders
    left join order_items_aggregated
        on orders.order_id = order_items_aggregated.order_id
    left join order_payments_aggregated
        on orders.order_id = order_payments_aggregated.order_id
    left join order_reviews_aggregated
        on orders.order_id = order_reviews_aggregated.order_id
)

select * from final