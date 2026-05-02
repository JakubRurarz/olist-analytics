with sellers as (
    select * from {{ ref('stg_sellers') }}
),

order_items as (
    select
        seller_id,
        count(distinct order_id)    as order_count,
        count(order_item_id)        as item_count,
        sum(price)                  as total_revenue,
        avg(price)                  as avg_item_price
    from {{ ref('stg_order_items') }}
    group by seller_id
),

reviews as (
    select
        order_items.seller_id,
        avg(order_reviews.review_score)     as avg_review_score,
        count(order_reviews.review_id)      as review_count
    from {{ ref('stg_order_reviews') }} as order_reviews
    left join {{ ref('stg_order_items') }} as order_items
        on order_reviews.order_id = order_items.order_id
    group by order_items.seller_id
),

final as (
    select
        sellers.seller_id,
        sellers.seller_city,
        sellers.seller_state,
        sellers.seller_zip_code_prefix,
        order_items.order_count,
        order_items.item_count,
        order_items.total_revenue,
        order_items.avg_item_price,
        reviews.avg_review_score,
        reviews.review_count
    from sellers
    left join order_items
        on sellers.seller_id = order_items.seller_id
    left join reviews
        on sellers.seller_id = reviews.seller_id
)

select * from final