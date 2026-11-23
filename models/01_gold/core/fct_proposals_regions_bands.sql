-- ===========================================================
--                  fct_proposals_regions_bands
-- ===========================================================

-- Grano: proyecto × región × banda.
-- Recuentos: proyectos distintos por banda, región y ciclo (casos de uso 3, 4.1, 7).
-- No usar horas por banda.
-- date_start / date_end: las del proyecto (todas sus regiones), para cruzar con dim_fecha.
-- Incremental delete+insert por proyecto: se rehacen todas las filas de cada proyecto con alguna
-- fila nueva en int_proposal_regions o en slv_proposal_bands.

{{ config(unique_key='proposal_id') }}

with

{% if is_incremental() %}
changed_proposals as (
    select int_proposal_regions.proposal_hash_id
    from {{ ref('int_proposal_regions') }} as int_proposal_regions
    where int_proposal_regions._date_load > {{ alma_watermark() }}
    union
    select proposal_bands.proposal_hash_id
    from {{ ref('slv_proposal_bands') }} as proposal_bands
    where proposal_bands._date_load > {{ alma_watermark() }}
),
{% endif %}

prop_regions as (
    select
        int_proposal_regions.proposal_hash_id,
        int_proposal_regions.proposal_id,
        int_proposal_regions.region_id,
        int_proposal_regions.total_time_science_reg,
        int_proposal_regions.total_time_setup_reg,
        int_proposal_regions.total_time_reg,
        int_proposal_regions.t_min_mjd,
        int_proposal_regions.t_max_mjd,
        int_proposal_regions._date_load
    from {{ ref('int_proposal_regions') }} as int_proposal_regions
    {% if is_incremental() %}
    where int_proposal_regions.proposal_hash_id in (
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

region_bands as (
    select
        proposal_bands.band_id,
        prop_regions.proposal_hash_id,
        prop_regions.proposal_id,
        prop_regions.region_id,
        prop_regions.total_time_science_reg,
        prop_regions.total_time_setup_reg,
        prop_regions.total_time_reg,
        -- nº de filas de banda del par proyecto × región = nº de bandas del proyecto (1 si no tiene)
        1 / count(*) over (
            partition by prop_regions.proposal_hash_id, prop_regions.region_id
        ) as band_weight,
        greatest(
            prop_regions._date_load,
            coalesce(proposal_bands._date_load, prop_regions._date_load)
        ) as _date_load
    from prop_regions
    -- left join: un proyecto sin bandas conserva sus filas, con band_id nulo y band_weight = 1
    left join {{ ref('slv_proposal_bands') }} as proposal_bands
        on proposal_bands.proposal_hash_id = prop_regions.proposal_hash_id
),

final as (
    select
        region_bands.band_id,
        region_bands.proposal_id,
        region_bands.region_id,
        region_bands.band_weight,
        region_bands.total_time_science_reg * region_bands.band_weight as time_science_alloc,
        region_bands.total_time_setup_reg * region_bands.band_weight as time_setup_alloc,
        region_bands.total_time_reg * region_bands.band_weight as time_total_alloc,
        proposal_dates.date_start,
        proposal_dates.date_end,
        region_bands._date_load
    from region_bands
    inner join proposal_dates
        on proposal_dates.proposal_hash_id = region_bands.proposal_hash_id
)

select * from final