{{ config(unique_key='scientific_category_id') }}

with

source_values as (
    select
        stg.scientific_category,
        max(stg.date_load) as _date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg
    {{ alma_new_rows_filter() }}
    group by stg.scientific_category
),

final as (
    select
        {{ alma_scientific_category_id('source_values.scientific_category') }} as scientific_category_id,
        source_values.scientific_category,
        source_values._date_load
    from source_values
    where source_values.scientific_category is not null
)

select * from final
