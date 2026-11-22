-- ===========================================================
--                  fct_proposals_regions_bands
-- ===========================================================

/*
Incremental delete+insert por proyecto: se rehacen todas las filas de cada proyecto con alguna
fila nueva en int_prop_regions o en slv_proposal_bands.
*/

{{ config(unique_key='proposal_id') }}

with

{% if is_incremental() %}
changed_proposals as (
    select int_prop_regions.proposal_hash_id
    from {{ ref('int_prop_regions') }} as int_prop_regions
    where int_prop_regions._date_load > {{ alma_watermark() }}
    union
    select proposal_bands.proposal_hash_id
    from {{ ref('slv_proposal_bands') }} as proposal_bands
    where proposal_bands._date_load > {{ alma_watermark() }}
),
{% endif %}

prop_regions as (
    select
        int_prop_regions.proposal_hash_id,
        int_prop_regions.proposal_id,
        int_prop_regions.region_id,
        int_prop_regions.n_spw_reg,
        int_prop_regions.total_time_science_reg,
        int_prop_regions.total_time_setup_reg,
        int_prop_regions.total_time_reg,
        int_prop_regions.t_min_mjd,
        int_prop_regions.t_max_mjd,
        int_prop_regions._date_load
    from {{ ref('int_proposal_regions') }} as int_prop_regions
    {% if is_incremental() %}
    where int_prop_regions.proposal_hash_id in (
        select changed_proposals.proposal_hash_id from changed_proposals
    )
    {% endif %}
),

proposal_dates as (
    select
        prop_regions.proposal_hash_id,
        {{ mjd_to_date('min(prop_regions.t_min_mjd)') }} as date_start,
        {{ mjd_to_date('max(prop_regions.t_max_mjd)') }} as date_end
    from prop_regions
    group by prop_regions.proposal_hash_id
),

final as (
    select
        proposal_bands.band_id,
        prop_regions.proposal_id,
        prop_regions.region_id,
        prop_regions.n_spw_reg,
        prop_regions.total_time_science_reg,
        prop_regions.total_time_setup_reg,
        prop_regions.total_time_reg,
        proposal_dates.date_start,
        proposal_dates.date_end,
        greatest(
            prop_regions._date_load,
            coalesce(proposal_bands._date_load, prop_regions._date_load)
        ) as _date_load
    from prop_regions
    inner join proposal_dates
        on proposal_dates.proposal_hash_id = prop_regions.proposal_hash_id
    -- left join: un proyecto sin bandas conserva sus filas, con band_id nulo
    left join {{ ref('slv_proposal_bands') }} as proposal_bands
        on proposal_bands.proposal_hash_id = prop_regions.proposal_hash_id
)

select * from final