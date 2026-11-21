{{ config(unique_key='target_id') }}

-- Grano: posición (gal_longitude_deg, gal_latitude_deg).
-- La región se asigna con el seed; si cambia el seed: dbt build --full-refresh -s targets.
-- Una posición cuenta como Sistema Solar si alguno de sus objetivos tiene nombre del Sistema Solar.
with

positions as (
    select
        stg.gal_longitude_deg,
        stg.gal_latitude_deg,
        stg.s_ra_deg,
        stg.s_dec_deg,
        boolor_agg({{ alma_is_solar_system_target('stg.target_name') }}) as is_solar_system_target,
        max(stg.date_load) as _date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg
    {{ alma_changed_keys_filter(['gal_longitude_deg', 'gal_latitude_deg']) }}
    group by
        stg.gal_longitude_deg,
        stg.gal_latitude_deg,
        stg.s_ra_deg,
        stg.s_dec_deg
),

positions_with_id as (
    select
        {{ alma_target_id('positions.gal_longitude_deg', 'positions.gal_latitude_deg') }} as target_id,
        positions.s_ra_deg,
        positions.s_dec_deg,
        positions.gal_longitude_deg,
        positions.gal_latitude_deg,
        positions.is_solar_system_target,
        positions._date_load
    from positions
),

target_regions as (
    {{ alma_assign_sky_region(
        'positions_with_id', 'target_id',
        'gal_longitude_deg', 'gal_latitude_deg', 'is_solar_system_target') }}
),

final as (
    select
        positions_with_id.target_id,
        positions_with_id.s_ra_deg,
        positions_with_id.s_dec_deg,
        positions_with_id.gal_longitude_deg,
        positions_with_id.gal_latitude_deg,
        {{ alma_region_id('target_regions.region_code') }} as region_id,
        positions_with_id._date_load
    from positions_with_id
    inner join target_regions
        on target_regions.target_id = positions_with_id.target_id
)

select * from final
