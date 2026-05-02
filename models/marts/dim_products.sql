with products as (
    select * from {{ ref('stg_products') }}
),

translations as (
    select * from {{ ref('stg_product_category_translations') }}
),

order_items as (
    select
        product_id,
        count(distinct order_id)    as order_count,
        sum(price)                  as total_revenue,
        avg(price)                  as avg_price
    from {{ ref('stg_order_items') }}
    group by product_id
),

final as (
    select
        products.product_id,
        products.product_category_name,
        translations.product_category_name_english,
        products.product_name_length,
        products.product_description_length,
        products.product_photos_qty,
        products.product_weight_g,
        products.product_length_cm,
        products.product_height_cm,
        products.product_width_cm,
        order_items.order_count,
        order_items.total_revenue,
        order_items.avg_price
    from products
    left join translations
        on products.product_category_name = translations.product_category_name
    left join order_items
        on products.product_id = order_items.product_id
)

select * from final