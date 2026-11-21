{{ config(unique_key='group_ous_id') }}

with

source_values as (
    select
        stg.group_ous_uid,
        max(stg.date_load) as _date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg
    {{ alma_new_rows_filter() }}
    group by stg.group_ous_uid
),

final as (
    select
        {{ alma_group_ous_id('source_values.group_ous_uid') }} as group_ous_id,
        source_values.group_ous_uid,
        source_values._date_load
    from source_values
    where source_values.group_ous_uid is not null
)

select * from final
