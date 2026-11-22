{{ config(unique_key='science_keyword_id') }}

with

keywords as (
    select
        trim(keyword.value) as science_keyword,
        max(stg.date_load) as _date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg,
        lateral split_to_table(stg.science_keyword, '{{ alma_list_separator("science_keyword") }}') as keyword
    {{ alma_new_rows_filter() }}
    group by all
),

final as (
    select
        {{ alma_science_keyword_id('keywords.science_keyword') }} as science_keyword_id,
        keywords.science_keyword,
        keywords._date_load
    from keywords
    where keywords.science_keyword <> ''
)

select * from final
