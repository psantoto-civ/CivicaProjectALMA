{{ config(unique_key='observing_program_id') }}

with

source_values as (
    select
        stg.proposal_type,
        max(stg.date_load) as _date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg
    {{ alma_new_rows_filter() }}
    group by stg.proposal_type
),

final as (
    select
        {{ alma_observing_program_id('source_values.proposal_type') }} as observing_program_id,
        source_values.proposal_type,
        source_values._date_load
    from source_values
    where source_values.proposal_type is not null
)

select * from final
