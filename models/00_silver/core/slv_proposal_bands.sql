-- delete+insert por proyecto: se rehacen todos los pares de cada proyecto que cambia.
-- band_name va como valor (antes, FK a slv_bands; 24-nov-2026). El hash de la banda se calcula en Gold.
{{ config(unique_key='proposal_hash_id') }}

with

proposal_bands as (
    select
        stg.proposal_id,
        cast(nullif(trim(band.value), '') as integer) as band_name,
        max(stg.date_load) as _date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg,
        lateral split_to_table(stg.band_list, '{{ alma_list_separator("band_list") }}') as band
    {{ alma_changed_keys_filter(['proposal_id']) }}
    group by all
),

final as (
    select
        {{ alma_hash_key(['proposal_bands.proposal_id', 'proposal_bands.band_name']) }} as prop_band_id,
        {{ alma_proposal_hash_id('proposal_bands.proposal_id') }} as proposal_hash_id,
        proposal_bands.band_name,
        proposal_bands._date_load
    from proposal_bands
    where proposal_bands.band_name is not null
)

select * from final
