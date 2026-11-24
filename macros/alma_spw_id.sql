{#
  Clave sustituta de la ventana espectral (spw_id), calculada SIEMPRE desde las columnas
  de raw, con el mismo tipado que stg_alma_obscore_typed. Se usa en los dos modelos que
  leen raw (datos y listado de claves), para que el mismo registro dé el mismo spw_id.

  Clave natural (indicada por el usuario el 21-nov-2026; la confirma el test unique de
  spw_id): (obs_id, target_name, sensitivity_10kms).
  - obs_id está truncado a 64 caracteres y no basta solo; con target_name quedan 129 claves
    repetidas (ventanas distintas de la misma observación), que sensitivity_10kms separa.
  - sensitivity_10kms se convierte a double antes de calcular la clave: el valor no
    depende del formato de texto con que la ingesta lo escriba.
  - Ojo: que sensitivity_10kms distinga las ventanas es una propiedad de los datos, no del
    diseño del archivo; si dos ventanas llegaran a coincidir, el test unique lo detecta.

  Si el origen corrige alguno de estos valores, la ventana cambia de spw_id: la versión
  anterior desaparece del listado de claves y se borra (delete_removed_spws), y la nueva
  entra por merge.
#}
{% macro alma_spw_id() -%}
    {{ dbt_utils.generate_surrogate_key([
        clean_string('obs_id'),
        clean_string('target_name'),
        'cast(sensitivity_10kms as double)'
    ]) }}
{%- endmacro %}
