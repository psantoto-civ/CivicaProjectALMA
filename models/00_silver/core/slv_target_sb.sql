{{ config(unique_key='target_sb_id') }}

-- Grano: objetivo dentro de una member OUS (member_ous_uid + target_name).
-- group by all: si un atributo no es constante en este nivel, salen filas repetidas
-- y falla el test unique de target_sb_id.
with

target_sbs as (
    select
        stg.member_ous_uid,
        stg.target_name,
        stg.s_fov_deg,
        stg.s_region,
        stg.t_min_mjd,
        stg.t_max_mjd,
        stg.t_exptime_s,
        stg.t_resolution_s,
        stg.s_resolution_arcsec,
        stg.pwv_mm,
        stg.asdm_uid,
        stg.science_observation,
        stg.spatial_scale_max_arcsec,
        stg.qa2_passed,
        stg.antenna_arrays,
        stg.is_mosaic,
        stg.obs_release_date,
        stg.spatial_resolution_arcsec,
        stg.frequency_support,
        stg.velocity_resolution_m_s,
        stg.pol_states,
        stg.gal_longitude_deg,
        stg.gal_latitude_deg,
        stg.data_rights,
        stg.access_format,
        stg.access_estsize_kb,
        max(stg.date_load) as _date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg
    {{ alma_changed_keys_filter(['member_ous_uid', 'target_name']) }}
    group by all
),

final as (
    select
        {{ alma_target_sb_id('target_sbs.member_ous_uid', 'target_sbs.target_name') }} as target_sb_id,
        target_sbs.target_name,
        target_sbs.s_fov_deg,
        target_sbs.s_region,
        target_sbs.t_min_mjd,
        target_sbs.t_max_mjd,
        target_sbs.t_exptime_s,
        target_sbs.t_resolution_s,
        target_sbs.s_resolution_arcsec,
        target_sbs.pwv_mm,
        target_sbs.asdm_uid,
        target_sbs.science_observation,
        target_sbs.spatial_scale_max_arcsec,
        target_sbs.qa2_passed,
        target_sbs.antenna_arrays,
        target_sbs.is_mosaic,
        target_sbs.obs_release_date,
        target_sbs.spatial_resolution_arcsec,
        target_sbs.frequency_support,
        target_sbs.velocity_resolution_m_s,
        target_sbs.pol_states,
        {{ alma_target_id('target_sbs.gal_longitude_deg', 'target_sbs.gal_latitude_deg') }} as target_id,
        {{ alma_data_rights_id('target_sbs.data_rights') }} as data_rights_id,
        {{ alma_sb_id('target_sbs.member_ous_uid') }} as sb_id,
        {{ alma_access_format_id('target_sbs.access_format') }} as access_format_id,
        target_sbs.access_estsize_kb,
        target_sbs._date_load
    from target_sbs
)

select * from final

