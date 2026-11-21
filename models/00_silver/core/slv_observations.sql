{{ config(unique_key='observation_id') }}

-- Grano: título del proyecto (obs_title).
with

observations as (
    select
        stg.obs_title,
        stg.proposal_type,
        stg.collections,
        stg.obs_collection,
        stg.obs_creator_name,
        stg.facility_name,
        stg.instrument_name,
        max(stg.date_load) as _date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg
    {{ alma_changed_keys_filter(['obs_title']) }}
    group by all
),

final as (
    select
        {{ alma_observation_id('observations.obs_title') }} as observation_id,
        observations.obs_title,
        {{ alma_observing_program_id('observations.proposal_type') }} as observing_program_id,
        {{ alma_collection_id('observations.collections') }} as collection_id,
        {{ alma_obs_collections_id('observations.obs_collection') }} as obs_collections_id,
        {{ alma_obs_creator_id('observations.obs_creator_name') }} as obs_creator_id,
        {{ alma_facility_id('observations.facility_name') }} as facility_id,
        {{ alma_instrument_id('observations.instrument_name') }} as instrument_id,
        observations._date_load
    from observations
    where observations.obs_title is not null
)

select * from final
