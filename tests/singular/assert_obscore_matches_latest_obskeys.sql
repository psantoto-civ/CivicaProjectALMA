-- Coherencia entre stg_alma_obscore_clean y el último listado de claves del TAP.
-- warn: las diferencias se corrigen solas en la siguiente ingesta (p. ej. filas modificadas
-- en el TAP después del corte de la descarga, que están en el listado pero aún no en staging).
{{ config(severity='warn') }}

with listing as (

    select
        spw_id,
        date_load
    from {{ ref('stg_alma_obskeys_latest') }}

),

staging as (

    select
        spw_id,
        date_load
    from {{ ref('stg_alma_obscore_clean') }}

),

not_deleted as (

    select
        staging.spw_id,
        'en staging pero no en el TAP (no se borró)' as problema
    from staging
    left join listing
        on listing.spw_id = staging.spw_id
    where listing.spw_id is null
      and staging.date_load <= (select max(date_load) from listing)

),

not_loaded as (

    select
        listing.spw_id,
        'en el TAP pero no en staging' as problema
    from listing
    left join staging
        on staging.spw_id = listing.spw_id
    where staging.spw_id is null

),

failures as (

    select spw_id, problema from not_deleted
    union all
    select spw_id, problema from not_loaded

)

select * from failures

