{{ config(unique_key='calib_level_id') }}

with

source_values as (
    select
        stg.calib_level,
        max(stg.date_load) as _date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg
    {{ alma_new_rows_filter() }}
    group by stg.calib_level
),

final as (
    select
        {{ alma_calib_level_id('source_values.calib_level') }} as calib_level_id,
        source_values.calib_level,
        source_values._date_load
    from source_values
    where source_values.calib_level is not null
)

select * from final
