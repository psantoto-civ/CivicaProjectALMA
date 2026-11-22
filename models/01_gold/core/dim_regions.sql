-- ===========================================================
--                  dim_regions
-- ===========================================================

-- Grano: región del cielo (seed alma_sky_regions, vía slv_regions).
-- Tabla, no incremental: slv_regions sale del seed y no tiene _date_load (misma excepción que en Silver).
-- Si cambia el seed: dbt build --full-refresh -s slv_targets+ (regiones, objetivos y lo que depende).
{{ config(materialized='table') }}

with

final as (
    select
        regions.region_id,
        regions.region_code,
        regions.region_name,
        regions.region_type,
        regions.ra_deg,
        regions.dec_deg,
        regions.gal_l_deg,
        regions.gal_b_deg,
        regions.radius_deg
    from {{ ref('slv_regions') }} as regions
)

select * from final