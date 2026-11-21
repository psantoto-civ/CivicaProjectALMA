-- RAW.OBSKEYS: cada clave aparece una sola vez en cada listado. Una repetición indicaría
-- que la clave de cinco columnas ha dejado de ser única en el TAP, o un listado cargado dos veces.
with keys as (

    select
        {{ alma_spw_id() }} as spw_id,
        date_load
    from {{ source('raw', 'obskeys') }}

),

duplicates as (

    select
        spw_id,
        date_load,
        count(*) as n
    from keys
    group by spw_id, date_load
    having count(*) > 1

)

select * from duplicates

