{{ config(unique_key='instrument_id') }}

with

source_values as (
    select
        stg.instrument_name,
        max(stg.date_load) as _date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg
    {{ alma_new_rows_filter() }}
    group by stg.instrument_name
),

final as (
    select
        {{ alma_instrument_id('source_values.instrument_name') }} as instrument_id,
        source_values.instrument_name,
        source_values._date_load
    from source_values
    where source_values.instrument_name is not null
)

select * from final
