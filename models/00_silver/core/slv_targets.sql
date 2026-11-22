{{ config(unique_key='target_id') }}

-- Grano: posición (gal_longitude_deg, gal_latitude_deg).
-- La región se asigna con el seed.
-- Una posición cuenta como Sistema Solar si alguno de sus objetivos tiene nombre del Sistema Solar.
with

positions as (
    select
        {{ alma_target_id('stg.gal_longitude_deg', 'stg.gal_latitude_deg') }} as target_id,
        min(stg.gal_longitude_deg) as gal_longitude_deg,
        min(stg.gal_latitude_deg) as gal_latitude_deg,
        min(stg.s_ra_deg) as s_ra_deg,
        min(stg.s_dec_deg) as s_dec_deg,
        boolor_agg({{ alma_is_solar_system_target('stg.target_name') }}) as is_solar_system_target,
        max(stg.date_load) as _date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg
    {{ alma_changed_keys_filter(['gal_longitude_deg', 'gal_latitude_deg']) }}
    group by 1
),

target_regions as (
    {{ alma_assign_sky_region(
        'positions', 'target_id',
        'gal_longitude_deg', 'gal_latitude_deg', 'is_solar_system_target') }}
),

final as (
    select
        positions.target_id,
        positions.s_ra_deg,
        positions.s_dec_deg,
        positions.gal_longitude_deg,
        positions.gal_latitude_deg,
        {{ alma_region_id('target_regions.region_code') }} as region_id,
        positions._date_load
    from positions
    inner join target_regions
        on target_regions.target_id = positions.target_id
)

select * from final
