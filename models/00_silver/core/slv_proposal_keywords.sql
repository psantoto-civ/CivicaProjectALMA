-- delete+insert por proyecto: se rehacen todos los pares de cada proyecto que cambia.
{{ config(unique_key='proposal_hash_id') }}

with

proposal_keywords as (
    select
        stg.proposal_id,
        trim(keyword.value) as science_keyword,
        max(stg.date_load) as _date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg,
        lateral split_to_table(stg.science_keyword, '{{ alma_list_separator("science_keyword") }}') as keyword
    {{ alma_changed_keys_filter(['proposal_id']) }}
    group by all
),

final as (
    select
        {{ alma_hash_key(['proposal_keywords.proposal_id', 'proposal_keywords.science_keyword']) }} as prop_key_id,
        {{ alma_proposal_hash_id('proposal_keywords.proposal_id') }} as proposal_hash_id,
        {{ alma_science_keyword_id('proposal_keywords.science_keyword') }} as science_keyword_id,
        proposal_keywords._date_load
    from proposal_keywords
    where proposal_keywords.science_keyword <> ''
)

select * from final
