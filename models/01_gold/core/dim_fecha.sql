-- ================================================
--                 dim_fecha
-- ================================================

-- Grano: día (1999-01-01 a 2100-12-31), desde el seed alma_calendar.
-- Tabla, no incremental: sale de un seed y no tiene _date_load (misma excepción que dim_regions).
-- alma_cycle: ciclo de observación de ALMA del día; nulo fuera de los ciclos del seed.

{{ config(materialized='table') }}

with

final as (
    select
        calendar.date_day,
        calendar.year,
        calendar.semester,
        calendar.quarter,
        calendar.month,
        calendar.month_name,
        calendar.alma_cycle
    from {{ ref('alma_calendar') }} as calendar
)

select * from final
