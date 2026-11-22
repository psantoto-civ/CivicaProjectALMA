{{ config(unique_key='data_rights_id') }}

with

source_values as (
    select
        stg.data_rights,
        max(stg.date_load) as _date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg
    {{ alma_new_rows_filter() }}
    group by stg.data_rights
),

final as (
    select
        {{ alma_data_rights_id('source_values.data_rights') }} as data_rights_id,
        source_values.data_rights,
        source_values._date_load
    from source_values
    where source_values.data_rights is not null
)

select * from final
