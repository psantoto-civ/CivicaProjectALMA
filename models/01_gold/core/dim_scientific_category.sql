-- ==========================================================
--                  dim_scientific_category
-- ==========================================================

/*
Grano: categoría científica. Incremental merge por scientific_category_id:
categorías nuevas de slv_category.
*/

{{ config(unique_key='scientific_category_id') }}

with

final as (
    select
        category.scientific_category_id,
        category.scientific_category,
        category._date_load
    from {{ ref('slv_category') }} as category
    {% if is_incremental() %}
    where category._date_load > {{ alma_watermark() }}
    {% endif %}
)

select * from final