{#
  Separador de los campos que guardan varios valores en una celda.
  SUPUESTOS sin comprobar: verificar el formato real antes de dar por buenos los modelos puente.
#}
{% macro alma_list_separator(column) -%}
    {%- set separators = {
        'science_keyword': ',',
        'band_list': ' ',
        'proposal_authors': ';',
        'authors': ';'
    } -%}
    {{- return(separators[column]) -}}
{%- endmacro %}
