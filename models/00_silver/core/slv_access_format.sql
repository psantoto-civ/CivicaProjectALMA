{{ config(unique_key='access_format_id') }}

with

source_values as (
    select
        stg.access_format,
        max(stg.date_load) as _date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg
    {{ alma_new_rows_filter() }}
    group by stg.access_format
),

final as (
    select
        {{ alma_access_format_id('source_values.access_format') }} as access_format_id,
        source_values.access_format,
        source_values._date_load
    from source_values
    where source_values.access_format is not null
)

select * from final
