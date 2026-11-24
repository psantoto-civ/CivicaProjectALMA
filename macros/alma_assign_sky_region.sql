{#
  Asigna a cada fila de `relation` una región del seed `alma_sky_regions` a partir de sus
  coordenadas galácticas. Devuelve un SELECT con dos columnas: la clave y `region_code`.

  Parámetros
    relation            CTE o relación con una fila por clave (la observación, no la ventana).
    key                 columna clave de `relation`.
    gal_l, gal_b        longitud y latitud galácticas en grados (l en [0, 360)).
    is_solar_system     columna booleana (ver alma_is_solar_system_target).

  Reglas (columna `rule` del seed) y orden
    name          Sistema Solar: solo cuando is_solar_system es true.
    cone          separación angular al centro (gal_l_deg, gal_b_deg) <= radius_deg.
    galactic_box  |l| < abs_l_max_deg, abs_b_min_deg <= |b| < abs_b_max_deg, con l llevada a
                  (-180, 180]; un límite nulo no restringe.
    fallback      siempre.
  Gana la región con menor `priority`. Los objetivos del Sistema Solar solo pueden caer en la
  regla `name`. Sin coordenadas, solo casa `fallback`.

  La lógica es de datos: cambiar un centro, un radio o el orden se hace en el seed, sin tocar
  la macro. El cruce es observaciones x regiones (~44 filas), barato en Snowflake.
#}
{% macro alma_assign_sky_region(relation, key, gal_l, gal_b, is_solar_system) -%}
    select
        obs.{{ key }},
        regions.region_code
    from {{ relation }} as obs
    inner join {{ ref('alma_sky_regions') }} as regions
        on (
            (regions.rule = 'name' and obs.{{ is_solar_system }})
            or (
                regions.rule = 'cone'
                and not obs.{{ is_solar_system }}
                and {{ angular_separation_deg(
                        'obs.' ~ gal_l, 'obs.' ~ gal_b,
                        'regions.gal_l_deg', 'regions.gal_b_deg') }} <= regions.radius_deg
            )
            or (
                regions.rule = 'galactic_box'
                and not obs.{{ is_solar_system }}
                and (regions.abs_l_max_deg is null
                     or abs(iff(obs.{{ gal_l }} > 180, obs.{{ gal_l }} - 360, obs.{{ gal_l }})) < regions.abs_l_max_deg)
                and (regions.abs_b_min_deg is null or abs(obs.{{ gal_b }}) >= regions.abs_b_min_deg)
                and (regions.abs_b_max_deg is null or abs(obs.{{ gal_b }}) < regions.abs_b_max_deg)
            )
            or regions.rule = 'fallback'
        )
    qualify row_number() over (partition by obs.{{ key }} order by regions.priority) = 1
{%- endmacro %}
