-- ===========================================================
--                  fct_proposals_regions_bands
-- ===========================================================

/*
Grano: proyecto x región x banda. PK de fila: proposal_region_band_id.
Recuentos: proyectos distintos por banda, región y ciclo (casos de uso 3, 4.1, 7).
Horas (casos e uso): las de proyecto x región (int_proposal_regions) multiplicadas por
band_weight = 1 / n de bandas del proyecto (factor de reparto). Así un SUM por región, por proyecto
o en total es exacto. Por banda, las horas son un reparto a partes iguales, no un tiempo medido:
en Silver la banda está por proyecto, no por observación. No usar horas por banda.
Un proyecto sin bandas tiene band_name nulo y su fila debe coincidir en el merge.
Merge no borra filas que dejan de existir. Una (proyecto, región) solo
desaparece si cambia el seed de regiones, y eso exige --full-refresh de Gold.
*/

{{ config(unique_key='proposal_region_band_id') }}

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
        {{ dbt_utils.generate_surrogate_key([
            'prop_regions.proposal_id',
            'prop_regions.region_id',
            'proposal_bands.band_name'
        ]) }} as proposal_region_band_id,
        -- nulo si el proyecto no tiene bandas (alma_hash_key devuelve nulo con entrada nula)
        {{ alma_band_id('proposal_bands.band_name') }} as band_id,
        prop_regions.proposal_hash_id,
        prop_regions.proposal_id,
        prop_regions.region_id,
        prop_regions.total_time_science_reg,
        prop_regions.total_time_setup_reg,
        prop_regions.total_time_reg,
        -- nº de filas de banda del par proyecto × región = nº de bandas del proyecto (1 si no tiene)
        cast(1 as float) / count(*) over (
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
        region_bands.proposal_region_band_id,
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