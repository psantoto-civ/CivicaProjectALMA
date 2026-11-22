{{ config(unique_key='obs_collections_id') }}

with

source_values as (
    select
        stg.obs_collection,
        max(stg.date_load) as _date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg
    {{ alma_new_rows_filter() }}
    group by stg.obs_collection
),

final as (
    select
        {{ alma_obs_collections_id('source_values.obs_collection') }} as obs_collections_id,
        source_values.obs_collection,
        source_values._date_load
    from source_values
    where source_values.obs_collection is not null
)

select * from final
