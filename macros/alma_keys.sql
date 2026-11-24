{#
  Claves sustitutas del modelo en 3FN. Una macro por clave: PK y FK se calculan siempre
  con la misma macro, así que el valor coincide en las dos tablas.
  Cada argumento es la expresión de la columna (por defecto, su nombre en staging).
  alma_band_id y alma_science_keyword_id ya no se usan en Silver (24-nov-2026): las usa Gold
  para las dimensiones de banda y palabra clave, con los mismos valores que antes.
#}

{#- Hash de varias columnas; nulo si todas son nulas (para que una FK opcional quede nula). -#}
{% macro alma_hash_key(columns) -%}
    iff(
        {%- for column in columns %} {{ column }} is null{% if not loop.last %} and{% endif %}{% endfor %},
        null,
        {{ dbt_utils.generate_surrogate_key(columns) }}
    )
{%- endmacro %}

{% macro alma_proposal_hash_id(proposal_id='proposal_id') -%}{{ alma_hash_key([proposal_id]) }}{%- endmacro %}
{% macro alma_sb_id(member_ous_uid='member_ous_uid') -%}{{ alma_hash_key([member_ous_uid]) }}{%- endmacro %}
{% macro alma_target_sb_id(member_ous_uid='member_ous_uid', target_name='target_name') -%}{{ alma_hash_key([member_ous_uid, target_name]) }}{%- endmacro %}
{% macro alma_target_id(gal_longitude='gal_longitude_deg', gal_latitude='gal_latitude_deg') -%}{{ alma_hash_key([gal_longitude, gal_latitude]) }}{%- endmacro %}
{% macro alma_region_id(region_code='region_code') -%}{{ alma_hash_key([region_code]) }}{%- endmacro %}
{% macro alma_calib_level_id(calib_level='calib_level') -%}{{ alma_hash_key([calib_level]) }}{%- endmacro %}
{% macro alma_group_ous_id(group_ous_uid='group_ous_uid') -%}{{ alma_hash_key([group_ous_uid]) }}{%- endmacro %}
{% macro alma_scientific_category_id(scientific_category='scientific_category') -%}{{ alma_hash_key([scientific_category]) }}{%- endmacro %}
{% macro alma_pi_id(pi_userid='pi_userid') -%}{{ alma_hash_key([pi_userid]) }}{%- endmacro %}
{% macro alma_science_keyword_id(science_keyword='science_keyword') -%}{{ alma_hash_key([science_keyword]) }}{%- endmacro %}
{% macro alma_band_id(band_name='band_name') -%}{{ alma_hash_key([band_name]) }}{%- endmacro %}
{% macro alma_publication_id(bib_reference='bib_reference') -%}{{ alma_hash_key([bib_reference]) }}{%- endmacro %}
{% macro alma_author_id(author_name='author_name') -%}{{ alma_hash_key([author_name]) }}{%- endmacro %}
{% macro alma_observation_id(obs_title='obs_title') -%}{{ alma_hash_key([obs_title]) }}{%- endmacro %}
{% macro alma_observing_program_id(proposal_type='proposal_type') -%}{{ alma_hash_key([proposal_type]) }}{%- endmacro %}
{% macro alma_obs_collections_id(obs_collection='obs_collection') -%}{{ alma_hash_key([obs_collection]) }}{%- endmacro %}
{% macro alma_obs_creator_id(obs_creator_name='obs_creator_name') -%}{{ alma_hash_key([obs_creator_name]) }}{%- endmacro %}
{% macro alma_facility_id(facility_name='facility_name') -%}{{ alma_hash_key([facility_name]) }}{%- endmacro %}
{% macro alma_instrument_id(instrument_name='instrument_name') -%}{{ alma_hash_key([instrument_name]) }}{%- endmacro %}