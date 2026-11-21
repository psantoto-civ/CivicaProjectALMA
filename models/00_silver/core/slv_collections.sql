{{ config(unique_key='collection_id') }}

with

source_values as (
    select
        stg.collections,
        max(stg.date_load) as _date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg
    {{ alma_new_rows_filter() }}
    group by stg.collections
),

final as (
    select
        {{ alma_collection_id('source_values.collections') }} as collection_id,
        source_values.collections,
        source_values._date_load
    from source_values
    where source_values.collections is not null
)

select * from final
