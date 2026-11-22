-- Grano: proyecto × región.
-- Tiempos una vez por observación (slv_target_sb), en horas; ciencia / setup según science_observation.
-- Los tiempos se agregan solo por región: las bandas se observan a la vez, las regiones no.
-- t_min_mjd / t_max_mjd: extremos de las observaciones del proyecto en esa región.
-- _date_load: la carga más reciente de las filas de Silver que usa (para el incremental de core).

with

spw_counts as (
    select
        spectral_windows.target_sb_id,
        count(spectral_windows.spw_id) as n_spw,
        max(spectral_windows._date_load) as _date_load
    from {{ ref('slv_spectral_windows') }} as spectral_windows
    group by spectral_windows.target_sb_id
),

observations as (
    select
        proposals.proposal_hash_id,
        proposals.proposal_id,
        targets.region_id,
        target_sb.t_exptime_s,
        target_sb.science_observation,
        target_sb.t_min_mjd,
        target_sb.t_max_mjd,
        coalesce(spw_counts.n_spw, 0) as n_spw,
        greatest(
            target_sb._date_load,
            scheduling_blocks._date_load,
            targets._date_load,
            coalesce(spw_counts._date_load, target_sb._date_load)
        ) as _date_load
    from {{ ref('slv_target_sb') }} as target_sb
    inner join {{ ref('slv_scheduling_blocks') }} as scheduling_blocks
        on scheduling_blocks.sb_id = target_sb.sb_id
    inner join {{ ref('slv_proposals') }} as proposals
        on proposals.proposal_hash_id = scheduling_blocks.proposal_hash_id
    inner join {{ ref('slv_targets') }} as targets
        on targets.target_id = target_sb.target_id
    left join spw_counts
        on spw_counts.target_sb_id = target_sb.target_sb_id
),

final as (
    select
        observations.proposal_hash_id,
        observations.proposal_id,
        observations.region_id,
        sum(observations.n_spw) as n_spw_reg,
        sum(iff(observations.science_observation, observations.t_exptime_s, 0)) / 3600
            as total_time_science_reg,
        sum(iff(not observations.science_observation, observations.t_exptime_s, 0)) / 3600
            as total_time_setup_reg,
        sum(observations.t_exptime_s) / 3600 as total_time_reg,
        min(observations.t_min_mjd) as t_min_mjd,
        max(observations.t_max_mjd) as t_max_mjd,
        max(observations._date_load) as _date_load
    from observations
    group by
        observations.proposal_hash_id,
        observations.proposal_id,
        observations.region_id
)

select * from final