{{ config(unique_key='publication_id') }}

-- Grano: valor de bib_reference tal como viene (puede contener varias publicaciones;
-- decisión del usuario: no se separan).
with

publications as (
    select
        stg.bib_reference,
        stg.pub_title,
        stg.pub_abstract,
        stg.publication_year,
        stg.first_author,
        max(stg.date_load) as _date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg
    {{ alma_changed_keys_filter(['bib_reference']) }}
    group by all
),

final as (
    select
        {{ alma_publication_id('publications.bib_reference') }} as publication_id,
        publications.bib_reference,
        publications.pub_title,
        publications.pub_abstract,
        publications.publication_year,
        {{ alma_author_id('trim(publications.first_author)') }} as first_author_id,
        publications._date_load
    from publications
    where publications.bib_reference is not null
)

select * from final
