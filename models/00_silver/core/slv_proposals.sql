{{ config(unique_key='proposal_hash_id') }}

with

proposals as (
    select
        stg.proposal_id,
        stg.proposal_abstract,
        stg.scientific_category,
        stg.pi_userid,
        stg.bib_reference,
        stg.obs_title,
        max(stg.date_load) as _date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg
    {{ alma_changed_keys_filter(['proposal_id']) }}
    group by all
),

final as (
    select
        {{ alma_proposal_hash_id('proposals.proposal_id') }} as proposal_hash_id,
        proposals.proposal_id,
        proposals.proposal_abstract,
        {{ alma_scientific_category_id('proposals.scientific_category') }} as scientific_category_id,
        {{ alma_pi_id('proposals.pi_userid') }} as pi_id,
        {{ alma_publication_id('proposals.bib_reference') }} as publication_id,
        {{ alma_observation_id('proposals.obs_title') }} as observation_id,
        proposals._date_load
    from proposals
)

select * from final
