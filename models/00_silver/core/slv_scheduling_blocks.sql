{{ config(unique_key='sb_id') }}

-- Grano: member OUS. Una member OUS aparece con dos proposal_id: se asigna al más antiguo
-- (mínimo en texto; el código empieza por año y convocatoria).
-- collections va como texto (antes, FK a catálogo; 24-nov-2026).
with

changed_rows as (
    select
        stg.member_ous_uid,
        stg.proposal_id,
        stg.s_xel1,
        stg.s_xel2,
        stg.t_xel,
        stg.access_url,
        stg.calib_level,
        stg.group_ous_uid,
        stg.collections,
        stg.date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg
    {{ alma_changed_keys_filter(['member_ous_uid']) }}
),

member_ous_proposals as (
    select
        changed_rows.member_ous_uid,
        min(changed_rows.proposal_id) as proposal_id,
        max(changed_rows.date_load) as _date_load
    from changed_rows
    group by changed_rows.member_ous_uid
),

member_ous as (
    select distinct
        changed_rows.member_ous_uid,
        changed_rows.s_xel1,
        changed_rows.s_xel2,
        changed_rows.t_xel,
        changed_rows.access_url,
        changed_rows.calib_level,
        changed_rows.group_ous_uid,
        changed_rows.collections
    from changed_rows
),

final as (
    select
        {{ alma_sb_id('member_ous.member_ous_uid') }} as sb_id,
        member_ous.s_xel1,
        member_ous.s_xel2,
        member_ous.t_xel,
        member_ous.member_ous_uid,
        member_ous.access_url,
        {{ alma_calib_level_id('member_ous.calib_level') }} as calib_level_id,
        {{ alma_group_ous_id('member_ous.group_ous_uid') }} as group_ous_id,
        member_ous.collections,
        {{ alma_proposal_hash_id('member_ous_proposals.proposal_id') }} as proposal_hash_id,
        member_ous_proposals._date_load
    from member_ous
    inner join member_ous_proposals
        on member_ous_proposals.member_ous_uid = member_ous.member_ous_uid
)

select * from final