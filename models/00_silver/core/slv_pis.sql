{{ config(unique_key='pi_id') }}

with

pis as (
    select
        stg.pi_userid,
        stg.pi_name,
        max(stg.date_load) as _date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg
    {{ alma_changed_keys_filter(['pi_userid']) }}
    group by all
),

final as (
    select
        {{ alma_pi_id('pis.pi_userid') }} as pi_id,
        pis.pi_userid,
        pis.pi_name,
        pis._date_load
    from pis
    where pis.pi_userid is not null
)

select * from final
