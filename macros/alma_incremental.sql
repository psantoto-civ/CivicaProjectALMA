{#
  Filtros incrementales de core (estrategia merge).
  Marca de agua: max(_date_load) de la propia tabla.
  Staging solo añade cargas con date_load mayor que su máximo,
  así que una fila nueva o modificada siempre supera la marca.
  En la primera ejecución o con --full-refresh no filtran nada.
  Los modelos leen staging con el alias `stg`.
#}

{#- Marca de agua de la tabla actual. -#}
{% macro alma_watermark() -%}
    (select coalesce(max(_date_load), '1900-01-01'::timestamp_ntz) from {{ this }})
{%- endmacro %}

{#- Solo filas nuevas de staging. Para tablas cuya fila depende de una sola fila o de un
    único valor (spectral_windows y catálogos). -#}
{% macro alma_new_rows_filter() -%}
    {%- if is_incremental() %}
    where stg.date_load > {{ alma_watermark() }}
    {%- endif %}
{%- endmacro %}

{#- Todas las filas de staging de las claves que tienen alguna fila nueva. Para entidades que
    agregan varias filas y para tablas puente: se recalcula la clave entera. -#}
{% macro alma_changed_keys_filter(key_columns) -%}
    {%- if is_incremental() %}
    where ({% for c in key_columns %}stg.{{ c }}{% if not loop.last %}, {% endif %}{% endfor %}) in (
        select {{ key_columns | join(', ') }}
        from {{ ref('stg_alma_obscore_clean') }}
        where date_load > {{ alma_watermark() }}
    )
    {%- endif %}
{%- endmacro %}
