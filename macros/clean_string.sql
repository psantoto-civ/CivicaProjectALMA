{#
  Limpieza mínima de texto para staging: quita espacios en los extremos y convierte
  la cadena vacía en nulo. No cambia mayúsculas (target_name las distingue).
#}
{% macro clean_string(column) -%}
    nullif(trim({{ column }}), '')
{%- endmacro %}
