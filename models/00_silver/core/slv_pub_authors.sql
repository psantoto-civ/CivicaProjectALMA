-- delete+insert por publicación: se rehacen todos los pares de cada bib_reference que cambia.
{{ config(unique_key='publication_id') }}

with

pub_authors as (
    select
        stg.bib_reference,
        trim(author.value) as author_name,
        max(stg.date_load) as _date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg,
        lateral split_to_table(stg.authors, '{{ alma_list_separator("authors") }}') as author
    {{ alma_changed_keys_filter(['bib_reference']) }}
    group by all
),

final as (
    select
        {{ alma_hash_key(['pub_authors.author_name', 'pub_authors.bib_reference']) }} as pub_author_id,
        {{ alma_publication_id('pub_authors.bib_reference') }} as publication_id,
        {{ alma_author_id('pub_authors.author_name') }} as author_id,
        pub_authors._date_load
    from pub_authors
    where pub_authors.bib_reference is not null
      and pub_authors.author_name <> ''
)

select * from final
