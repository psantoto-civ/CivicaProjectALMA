-- ===========================================================
--                  dim_bands
-- ===========================================================

-- Grano: banda de ALMA. Incremental delete+insert por band_id: bandas nuevas de slv_bands.
{{ config(unique_key='band_id') }}

with

final as (
    select
        bands.band_id,
        bands.band_name,
        bands._date_load
    from {{ ref('slv_bands') }} as bands
    {% if is_incremental() %}
    where bands._date_load > {{ alma_watermark() }}
    {% endif %}
)

select * from final