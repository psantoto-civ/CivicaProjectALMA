{{ config(unique_key='dataproduct_type_id') }}

with

source_values as (
    select
        stg.dataproduct_type,
        max(stg.date_load) as _date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg
    {{ alma_new_rows_filter() }}
    group by stg.dataproduct_type
),

final as (
    select
        {{ alma_dataproduct_type_id('source_values.dataproduct_type') }} as dataproduct_type_id,
        source_values.dataproduct_type,
        source_values._date_load
    from source_values
    where source_values.dataproduct_type is not null
)

select * from final
