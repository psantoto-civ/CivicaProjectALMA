{#
  Separación angular en grados entre dos puntos de la esfera (longitud, latitud en grados).
  Fórmula de haversine: estable para distancias pequeñas (conos de 0,1°), al contrario que acos.
  Vale para cualquier sistema (galáctico o ecuatorial) siempre que los dos puntos estén en el mismo.
  `least(1, ...)` evita que el redondeo deje el argumento de asin por encima de 1.
#}
{% macro angular_separation_deg(lon1, lat1, lon2, lat2) -%}
    degrees(2 * asin(least(1, sqrt(
        power(sin(radians({{ lat2 }} - {{ lat1 }}) / 2), 2)
        + cos(radians({{ lat1 }})) * cos(radians({{ lat2 }}))
          * power(sin(radians({{ lon2 }} - {{ lon1 }}) / 2), 2)
    ))))
{%- endmacro %}
