{{ config(unique_key='observation_ucd_id') }}

with

source_values as (
    select
        stg.o_ucd,
        max(stg.date_load) as _date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg
    {{ alma_new_rows_filter() }}
    group by stg.o_ucd
),

final as (
    select
        {{ alma_observation_ucd_id('source_values.o_ucd') }} as observation_ucd_id,
        source_values.o_ucd,
        source_values._date_load
    from source_values
    where source_values.o_ucd is not null
)

select * from final
