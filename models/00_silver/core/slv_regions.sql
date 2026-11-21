-- Catálogo del seed: no depende de staging, se reconstruye entero (tabla).
{{ config(materialized='table') }}

with

final as (
    select
        {{ alma_region_id('seed.region_code') }} as region_id,
        seed.region_code,
        seed.region_name,
        seed.region_type,
        seed.priority,
        seed.rule,
        seed.ra_deg,
        seed.dec_deg,
        seed.gal_l_deg,
        seed.gal_b_deg,
        seed.radius_deg,
        seed.abs_l_max_deg,
        seed.abs_b_min_deg,
        seed.abs_b_max_deg,
        seed.note
    from {{ ref('alma_sky_regions') }} as seed
)

select * from final
