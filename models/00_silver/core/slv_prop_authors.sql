{{ config(unique_key='prop_author_id') }}

with

prop_authors as (
    select
        stg.proposal_id,
        trim(author.value) as author_name,
        max(stg.date_load) as _date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg,
        lateral split_to_table(stg.proposal_authors, '{{ alma_list_separator("proposal_authors") }}') as author
    {{ alma_changed_keys_filter(['proposal_id']) }}
    group by all
),

final as (
    select
        {{ alma_hash_key(['prop_authors.author_name', 'prop_authors.proposal_id']) }} as prop_author_id,
        {{ alma_author_id('prop_authors.author_name') }} as author_id,
        {{ alma_proposal_hash_id('prop_authors.proposal_id') }} as proposal_hash_id,
        prop_authors._date_load
    from prop_authors
    where prop_authors.author_name <> ''
)

select * from final
