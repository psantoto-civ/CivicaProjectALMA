{{ config(unique_key='target_id') }}

-- Grano: posición (gal_longitude_deg, gal_latitude_deg).


{% if is_incremental() %}
changed_positions as (
    select distinct
        {{ alma_target_id('stg.gal_longitude_deg', 'stg.gal_latitude_deg') }} as target_id
    from {{ ref('stg_alma_obscore_clean') }} as stg
    where stg.date_load > {{ alma_watermark() }}
),
{% endif %}

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
    {% if is_incremental() %}
    where {{ alma_target_id('stg.gal_longitude_deg', 'stg.gal_latitude_deg') }} in (
        select changed_positions.target_id from changed_positions
    )
    {% endif %}
    group by 1
),

target_regions as (
    {{ alma_assign_sky_region(
        'positions', 'target_id',
        'gal_longitude_deg', 'gal_latitude_deg', 'is_solar_system_target') }}
),

recalculated as (
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
),

changed as (
    select
        recalculated.target_id,
        recalculated.s_ra_deg,
        recalculated.s_dec_deg,
        recalculated.gal_longitude_deg,
        recalculated.gal_latitude_deg,
        recalculated.region_id,
        recalculated._date_load
    from recalculated
    {% if is_incremental() %}
    -- fuera las posiciones que ya están en la tabla sin cambio significativo
    left join {{ this }} as current_targets
        on current_targets.target_id = recalculated.target_id
    where current_targets.target_id is null
        or not equal_null(current_targets.region_id, recalculated.region_id)
        or coalesce(abs(current_targets.s_ra_deg - recalculated.s_ra_deg) > 1e-9,
                    not equal_null(current_targets.s_ra_deg, recalculated.s_ra_deg))
        or coalesce(abs(current_targets.s_dec_deg - recalculated.s_dec_deg) > 1e-9,
                    not equal_null(current_targets.s_dec_deg, recalculated.s_dec_deg))
        or coalesce(abs(current_targets.gal_longitude_deg - recalculated.gal_longitude_deg) > 1e-9,
                    not equal_null(current_targets.gal_longitude_deg, recalculated.gal_longitude_deg))
        or coalesce(abs(current_targets.gal_latitude_deg - recalculated.gal_latitude_deg) > 1e-9,
                    not equal_null(current_targets.gal_latitude_deg, recalculated.gal_latitude_deg))
    {% endif %}
),

final as (
    select
        changed.target_id,
        changed.s_ra_deg,
        changed.s_dec_deg,
        changed.gal_longitude_deg,
        changed.gal_latitude_deg,
        changed.region_id,
        changed._date_load
    from changed
)

select * from final