{{ config(unique_key='scan_intent_id') }}

with

source_values as (
    select
        stg.scan_intent,
        max(stg.date_load) as _date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg
    {{ alma_new_rows_filter() }}
    group by stg.scan_intent
),

final as (
    select
        {{ alma_scan_intent_id('source_values.scan_intent') }} as scan_intent_id,
        source_values.scan_intent,
        source_values._date_load
    from source_values
    where source_values.scan_intent is not null
)

select * from final
