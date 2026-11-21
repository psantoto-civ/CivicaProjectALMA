{#
  post_hook de stg_alma_obscore_clean: borra las ventanas espectrales que ya no existen en el TAP.

  Una fila se da por borrada si no aparece en el último listado de claves
  (stg_alma_obskeys_latest) y se cargó en ese listado o antes (date_load <= fecha del
  listado). La segunda condición evita borrar filas cargadas después del último listado.
  Si no hay ningún listado, max(date_load) es nulo y no se borra nada.
#}
{% macro delete_removed_spws() %}
    {%- set keys = ref('stg_alma_obskeys_latest') -%}
    delete from {{ this }}
    where date_load <= (select max(date_load) from {{ keys }})
      and spw_id not in (select spw_id from {{ keys }})
{% endmacro %}

