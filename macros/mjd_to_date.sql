{#- Fecha (UTC) de un MJD. MJD 0 = 1858-11-17 00:00 UTC. -#}

{% macro mjd_to_date(mjd) -%}

    dateadd(day, cast(floor({{ mjd }}) as integer), cast('1858-11-17' as date))
    
{%- endmacro %}