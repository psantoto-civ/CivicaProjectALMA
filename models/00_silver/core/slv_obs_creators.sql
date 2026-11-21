{{ config(unique_key='obs_creator_id') }}

with

source_values as (
    select
        stg.obs_creator_name,
        max(stg.date_load) as _date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg
    {{ alma_new_rows_filter() }}
    group by stg.obs_creator_name
),

final as (
    select
        {{ alma_obs_creator_id('source_values.obs_creator_name') }} as obs_creator_id,
        source_values.obs_creator_name,
        source_values._date_load
    from source_values
    where source_values.obs_creator_name is not null
)

select * from final
