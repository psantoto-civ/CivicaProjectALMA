{#
  Devuelve true si el nombre del objetivo corresponde a un cuerpo del Sistema Solar.

  Los objetos del Sistema Solar se mueven: sus coordenadas no sirven para asignarlos a una
  región fija, así que se identifican por nombre y tienen prioridad sobre los conos.

  REGEXP_LIKE de Snowflake ancla el patrón a toda la cadena (no hace falta ^ ni $).
  Cada patrón empieza en el principio del nombre o tras un separador, y termina en el final
  o en un separador, para no capturar H-ATLAS, DEIMOS_COSMOS, 30_Doradus o Monoceros_R2
  (falsos positivos vistos con el CSV de la web; ver 02_regiones_y_casos_de_uso.md).

  BORRADOR: validar sobre los datos (consulta en 08_intermediate.md) antes de darlo por bueno.
  - Deimos se excluye a propósito (DEIMOS_COSMOS). Si aparece la luna, añadir un patrón exacto.
  - Urano también aparece como calibrador de flujo en proyectos ajenos: se asigna igualmente
    al Sistema Solar (es un cuerpo del Sistema Solar); el proyecto lo dice su categoría.
#}
{% macro alma_is_solar_system_target(target_name) -%}
    {%- set bodies = [
        'sun', 'mercury', 'venus', 'moon', 'mars', 'jupiter', 'saturn', 'uranus', 'neptune',
        'pluto', 'charon', 'ceres', 'vesta', 'pallas', 'juno', 'hygiea', 'eris', 'makemake', 'haumea',
        'io', 'europa', 'ganymede', 'callisto', 'titan', 'enceladus', 'triton', 'phobos',
        'mimas', 'tethys', 'dione', 'rhea', 'iapetus', 'miranda', 'ariel', 'umbriel', 'titania', 'oberon'
    ] -%}
    {%- set sep = '[ _-]' -%}
    {%- set patterns = [
        '(' ~ bodies | join('|') ~ ')(' ~ sep ~ '.*)?',
        'ephemeris.*',
        '(.*' ~ sep ~ ')?[cp]/?_?(19|20)[0-9]{2}' ~ sep ~ '?[a-z]{1,2}[0-9]{0,3}(' ~ sep ~ '.*)?',
        '[0-9]{1,3}p(' ~ sep ~ '.*)?',
        '(19|20)[0-9]{2}_?[a-z]{2}[0-9]{0,3}(' ~ sep ~ '.*)?'
    ] -%}
    coalesce(
        {%- for p in patterns %}
        regexp_like({{ target_name }}, '{{ p }}', 'i'){% if not loop.last %} or{% endif %}
        {%- endfor %},
        false
    )
{%- endmacro %}
