{{ config(unique_key='facility_id') }}

with

source_values as (
    select
        stg.facility_name,
        max(stg.date_load) as _date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg
    {{ alma_new_rows_filter() }}
    group by stg.facility_name
),

final as (
    select
        {{ alma_facility_id('source_values.facility_name') }} as facility_id,
        source_values.facility_name,
        source_values._date_load
    from source_values
    where source_values.facility_name is not null
)

select * from final
