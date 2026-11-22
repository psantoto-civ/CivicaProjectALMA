-- =================================================
--              fct_proposals
-- =================================================

-- Grano: proyecto.
-- Tiempos y ventanas: suma de int_proposal_regions (las regiones reparten las observaciones,
-- así que la suma es exacta). Tiempos en horas; ciencia / setup según science_observation.
-- date_start / date_end: primera y última observación del proyecto; total_time_span en días (MJD).
-- Incremental delete+insert por proyecto: se rehacen los proyectos con alguna fila nueva en
-- slv_proposals, int_proposal_regions o slv_prop_authors.

{{ config(unique_key='proposal_id') }}

with

{% if is_incremental() %}
changed_proposals as (
    select slv_proposals.proposal_hash_id
    from {{ ref('slv_proposals') }} as slv_proposals
    where slv_proposals._date_load > {{ alma_watermark() }}
    union
    select int_proposal_regions.proposal_hash_id
    from {{ ref('int_proposal_regions') }} as int_proposal_regions
    where int_proposal_regions._date_load > {{ alma_watermark() }}
    union
    select prop_authors.proposal_hash_id
    from {{ ref('slv_prop_authors') }} as prop_authors
    where prop_authors._date_load > {{ alma_watermark() }}
),
{% endif %}

proposals as (
    select
        slv_proposals.proposal_hash_id,
        slv_proposals.proposal_id,
        slv_proposals.obs_publisher_did,
        slv_proposals.proposal_abstract,
        slv_proposals.pi_id,
        slv_proposals.scientific_category_id,
        slv_proposals._date_load
    from {{ ref('slv_proposals') }} as slv_proposals
    {% if is_incremental() %}
    where slv_proposals.proposal_hash_id in (
        select changed_proposals.proposal_hash_id from changed_proposals
    )
    {% endif %}
),

proposal_observations as (
    select
        int_proposal_regions.proposal_hash_id,
        sum(int_proposal_regions.total_time_science_reg) as total_observing_time_science,
        sum(int_proposal_regions.total_time_setup_reg) as total_observing_time_setup,
        sum(int_proposal_regions.total_time_reg) as total_observing_time,
        min(int_proposal_regions.t_min_mjd) as t_min_mjd,
        max(int_proposal_regions.t_max_mjd) as t_max_mjd,
        sum(int_proposal_regions.n_spw_reg) as n_spws,
        max(int_proposal_regions._date_load) as _date_load
    from {{ ref('int_proposal_regions') }} as int_proposal_regions
    where int_proposal_regions.proposal_hash_id in (
        select proposals.proposal_hash_id from proposals
    )
    group by int_proposal_regions.proposal_hash_id
),

proposal_authors as (
    select
        prop_authors.proposal_hash_id,
        count(distinct prop_authors.author_id) as n_authors,
        max(prop_authors._date_load) as _date_load
    from {{ ref('slv_prop_authors') }} as prop_authors
    where prop_authors.proposal_hash_id in (
        select proposals.proposal_hash_id from proposals
    )
    group by prop_authors.proposal_hash_id
),

final as (
    select
        proposals.proposal_id,
        proposals.obs_publisher_did,
        proposals.proposal_abstract,
        coalesce(proposal_authors.n_authors, 0) as n_authors,
        proposal_observations.total_observing_time_science,
        proposal_observations.total_observing_time_setup,
        proposal_observations.total_observing_time,
        {{ mjd_to_date('proposal_observations.t_min_mjd') }} as date_start,
        {{ mjd_to_date('proposal_observations.t_max_mjd') }} as date_end,
        proposal_observations.t_max_mjd - proposal_observations.t_min_mjd as total_time_span,
        coalesce(proposal_observations.n_spws, 0) as n_spws,
        proposals.pi_id,
        proposals.scientific_category_id,
        greatest(
            proposals._date_load,
            coalesce(proposal_observations._date_load, proposals._date_load),
            coalesce(proposal_authors._date_load, proposals._date_load)
        ) as _date_load
    from proposals
    left join proposal_observations
        on proposal_observations.proposal_hash_id = proposals.proposal_hash_id
    left join proposal_authors
        on proposal_authors.proposal_hash_id = proposals.proposal_hash_id
)

select * from final