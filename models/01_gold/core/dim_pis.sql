-- ==========================================================
--                  dim_PIs
-- ==========================================================

-- Grano: PI (pi_userid). Incremental merge por pi_id: PIs nuevos o recalculados en slv_pis.
{{ config(unique_key='pi_id') }}

with

final as (
    select
        pis.pi_id,
        pis.pi_userid,
        pis.pi_name,
        pis._date_load
    from {{ ref('slv_pis') }} as pis
    {% if is_incremental() %}
    where pis._date_load > {{ alma_watermark() }}
    {% endif %}
)

select * from final