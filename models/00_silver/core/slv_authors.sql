{{ config(unique_key='author_id') }}

-- Autores de publicaciones, de propuestas y primeros autores (los tres apuntan aquí).
with

publication_authors as (
    select
        trim(author.value) as author_name,
        stg.date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg,
        lateral split_to_table(stg.authors, '{{ alma_list_separator("authors") }}') as author
    {{ alma_new_rows_filter() }}
),

proposal_authors as (
    select
        trim(author.value) as author_name,
        stg.date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg,
        lateral split_to_table(stg.proposal_authors, '{{ alma_list_separator("proposal_authors") }}') as author
    {{ alma_new_rows_filter() }}
),

first_authors as (
    select
        trim(stg.first_author) as author_name,
        stg.date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg
    {{ alma_new_rows_filter() }}
),

all_authors as (
    select publication_authors.author_name, publication_authors.date_load from publication_authors
    union all
    select proposal_authors.author_name, proposal_authors.date_load from proposal_authors
    union all
    select first_authors.author_name, first_authors.date_load from first_authors
),

authors as (
    select
        all_authors.author_name,
        max(all_authors.date_load) as _date_load
    from all_authors
    where all_authors.author_name <> ''
    group by all_authors.author_name
),

final as (
    select
        {{ alma_author_id('authors.author_name') }} as author_id,
        authors.author_name,
        authors._date_load
    from authors
)

select * from final
