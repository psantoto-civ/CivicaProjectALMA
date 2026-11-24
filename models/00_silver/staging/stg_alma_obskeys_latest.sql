{#
  Último listado de claves de ventana espectral del TAP (RAW.OBSKEYS).

  RAW.OBSKEYS es solo de inserciones: cada ejecución de la ingesta añade las columnas de la
  clave natural (obs_id, target_name, sensitivity_10kms) de TODAS las filas que existen en ese momento en ivoa.obscore. Este modelo
  se queda con el listado más reciente y calcula spw_id con la misma macro que los datos.
  Lo usa delete_removed_spws para borrar en stg_alma_obscore_clean lo que ya no existe en el TAP.
#}

with keys as (

    select
        obs_id,
        target_name,
        sensitivity_10kms,
        date_load
    from {{ source('raw', 'obskeys') }}

),

latest_listing as (

    select
        {{ alma_spw_id() }}            as spw_id,
        to_timestamp_ntz(date_load)    as date_load
    from keys
    qualify date_load = max(date_load) over ()

)

select * from latest_listing