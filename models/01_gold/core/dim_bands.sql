-- ===========================================================
--                  dim_bands
-- ===========================================================

-- Grano: banda de ALMA. Desde el 24-nov-2026 Silver no tiene catálogo de bandas: se sacan los
-- valores distintos de slv_proposal_bands y la clave se calcula aquí con alma_band_id
-- (los mismos valores de band_id que tenía slv_bands).
-- Incremental por band_id: bandas de pares nuevos o recalculados en slv_proposal_bands.

{{ config(unique_key='band_id') }}

with

bands as (
    select
        proposal_bands.band_name,
        max(proposal_bands._date_load) as _date_load
    from {{ ref('slv_proposal_bands') }} as proposal_bands
    {% if is_incremental() %}
    where proposal_bands._date_load > {{ alma_watermark() }}
    {% endif %}
    group by proposal_bands.band_name
),

final as (
    select
        {{ alma_band_id('bands.band_name') }} as band_id,
        bands.band_name,
        bands._date_load
    from bands
)

select * from final