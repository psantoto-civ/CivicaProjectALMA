{{ config(unique_key='spw_id') }}

with

final as (
    select
        stg.spw_id,
        stg.obs_id,
        stg.em_min_m,
        stg.em_max_m,
        stg.em_res_power,
        stg.em_xel,
        stg.sensitivity_10kms_mjy_beam,
        stg.last_modified_at,
        stg.cont_sensitivity_bandwidth_mjy_beam,
        stg.spectral_resolution_khz,
        stg.em_resolution_m,
        stg.bandwidth_hz,
        stg.frequency_ghz,
        {{ alma_scan_intent_id('stg.scan_intent') }} as scan_intent_id,
        {{ alma_target_sb_id('stg.member_ous_uid', 'stg.target_name') }} as target_sb_id,
        {{ alma_dataproduct_type_id('stg.dataproduct_type') }} as dataproduct_type_id,
        {{ alma_observation_ucd_id('stg.o_ucd') }} as observation_ucd_id,
        stg.date_load as _date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg
    {{ alma_new_rows_filter() }}
)

select * from final

