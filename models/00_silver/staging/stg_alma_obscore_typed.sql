{#
  Tipado 1:1 de RAW.OBSCORE (todas las columnas llegan como VARCHAR).

  - Casteo estricto (cast / to_boolean / to_timestamp_ntz): si un valor no se puede
    convertir, el build falla en lugar de dejar un nulo silencioso.
  - Unidades en el nombre (de TAP_SCHEMA.columns): _deg, _arcsec, _s, _m, _hz, _ghz...
  - Texto: clean_string (trim + '' -> nulo), sin tocar mayúsculas.
  - obs_release_date = 3000-01-01 (marcador, probablemente "fecha no fijada") -> nulo.
  - spw_id: clave sustituta de la ventana espectral (macro alma_spw_id).
  - Sin filtrar ni deduplicar: eso lo hace stg_alma_obscore_clean.
  - Vista (materialización por defecto de staging): versión siempre actual de RAW, consultable.
#}
with source as (

    select
        obs_publisher_did,
        obs_collection,
        facility_name,
        instrument_name,
        obs_id,
        dataproduct_type,
        calib_level,
        collections,
        target_name,
        s_ra,
        s_dec,
        s_fov,
        s_region,
        s_xel1,
        s_xel2,
        em_xel,
        t_xel,
        pol_xel,
        s_resolution,
        t_min,
        t_max,
        t_exptime,
        t_resolution,
        em_min,
        em_max,
        em_res_power,
        pol_states,
        cont_sensitivity_bandwidth,
        pwv,
        group_ous_uid,
        member_ous_uid,
        asdm_uid,
        obs_title,
        type,
        scan_intent,
        science_observation,
        spatial_scale_max,
        qa2_passed,
        bib_reference,
        science_keyword,
        scientific_category,
        pi_userid,
        pi_name,
        spectral_resolution,
        o_ucd,
        access_url,
        access_format,
        access_estsize,
        proposal_id,
        data_rights,
        gal_longitude,
        gal_latitude,
        band_list,
        em_resolution,
        bandwidth,
        antenna_arrays,
        is_mosaic,
        obs_release_date,
        spatial_resolution,
        frequency_support,
        frequency,
        velocity_resolution,
        obs_creator_name,
        pub_title,
        first_author,
        authors,
        pub_abstract,
        publication_year,
        proposal_abstract,
        schedblock_name,
        proposal_authors,
        sensitivity_10kms,
        lastmodified,
        date_load,
        _file_name,
        _file_row_number,
        _loaded_at
    from {{ source('raw', 'obscore') }}

),

typed as (

    select
        -- clave sustituta de la ventana espectral (macro común con stg_alma_obskeys_latest)
        {{ alma_spw_id() }}                                      as spw_id,

        -- identificadores y jerarquía
        {{ clean_string('proposal_id') }}                       as proposal_id,
        {{ clean_string('obs_publisher_did') }}                 as obs_publisher_did,
        {{ clean_string('group_ous_uid') }}                     as group_ous_uid,
        {{ clean_string('member_ous_uid') }}                    as member_ous_uid,
        {{ clean_string('asdm_uid') }}                          as asdm_uid,
        {{ clean_string('obs_id') }}                            as obs_id,           -- truncado a 64 caracteres: no es clave
        {{ clean_string('target_name') }}                       as target_name,      -- sin cambiar mayúsculas
        {{ clean_string('schedblock_name') }}                   as schedblock_name,

        -- proyecto
        {{ clean_string('obs_title') }}                         as obs_title,
        {{ clean_string('type') }}                              as proposal_type,    -- catálogo S, T, V, L, SV, E, P, CAL
        {{ clean_string('scientific_category') }}               as scientific_category,
        {{ clean_string('science_keyword') }}                   as science_keyword,
        {{ clean_string('pi_userid') }}                         as pi_userid,
        {{ clean_string('pi_name') }}                           as pi_name,
        {{ clean_string('obs_creator_name') }}                  as obs_creator_name,
        {{ clean_string('proposal_authors') }}                  as proposal_authors,
        {{ clean_string('proposal_abstract') }}                 as proposal_abstract,

        -- publicaciones
        {{ clean_string('bib_reference') }}                     as bib_reference,
        {{ clean_string('pub_title') }}                         as pub_title,
        {{ clean_string('first_author') }}                      as first_author,
        {{ clean_string('authors') }}                           as authors,
        {{ clean_string('pub_abstract') }}                      as pub_abstract,
        cast(publication_year as integer)                       as publication_year,

        -- producto y acceso
        {{ clean_string('obs_collection') }}                    as obs_collection,
        {{ clean_string('facility_name') }}                     as facility_name,
        {{ clean_string('instrument_name') }}                   as instrument_name,
        {{ clean_string('dataproduct_type') }}                  as dataproduct_type,
        cast(calib_level as integer)                            as calib_level,
        {{ clean_string('collections') }}                       as collections,
        {{ clean_string('access_url') }}                        as access_url,
        {{ clean_string('access_format') }}                     as access_format,
        cast(access_estsize as integer)                         as access_estsize_kb,
        {{ clean_string('data_rights') }}                       as data_rights,
        case
            when obs_release_date like '3000-%' then null       -- marcador, no es una fecha real
            else to_timestamp_ntz(obs_release_date)
        end                                                     as obs_release_date,
        to_boolean(qa2_passed)                                  as qa2_passed,
        to_boolean(science_observation)                         as science_observation,
        {{ clean_string('scan_intent') }}                       as scan_intent,

        -- espacial
        {{ round_deg('cast(s_ra as double)') }}                 as s_ra_deg,
        {{ round_deg('cast(s_dec as double)') }}                as s_dec_deg,
        cast(gal_longitude as double)                           as gal_longitude_deg,
        cast(gal_latitude as double)                            as gal_latitude_deg,
        cast(s_fov as double)                                   as s_fov_deg,
        {{ clean_string('s_region') }}                          as s_region,         -- STC-S, texto
        cast(s_resolution as double)                            as s_resolution_arcsec,
        cast(spatial_resolution as double)                      as spatial_resolution_arcsec,
        cast(spatial_scale_max as double)                       as spatial_scale_max_arcsec,
        cast(s_xel1 as integer)                                 as s_xel1,
        cast(s_xel2 as integer)                                 as s_xel2,
        to_boolean(is_mosaic)                                   as is_mosaic,

        -- temporal
        cast(t_min as double)                                   as t_min_mjd,
        cast(t_max as double)                                   as t_max_mjd,
        cast(t_exptime as double)                               as t_exptime_s,
        cast(t_resolution as double)                            as t_resolution_s,
        cast(t_xel as integer)                                  as t_xel,

        -- espectral
        {{ clean_string('band_list') }}                         as band_list,        -- lista separada por espacios
        cast(frequency as double)                               as frequency_ghz,
        {{ clean_string('frequency_support') }}                 as frequency_support,
        cast(bandwidth as double)                               as bandwidth_hz,     -- ancho de la ventana espectral
        cast(em_min as double)                                  as em_min_m,
        cast(em_max as double)                                  as em_max_m,
        cast(em_resolution as double)                           as em_resolution_m,
        cast(em_res_power as double)                            as em_res_power,     -- adimensional
        cast(em_xel as integer)                                 as em_xel,
        cast(spectral_resolution as double)                     as spectral_resolution_khz,
        cast(velocity_resolution as double)                     as velocity_resolution_m_s,
        cast(sensitivity_10kms as double)                       as sensitivity_10kms_mjy_beam,
        cast(cont_sensitivity_bandwidth as double)              as cont_sensitivity_bandwidth_mjy_beam,

        -- polarización y observable
        {{ clean_string('pol_states') }}                        as pol_states,
        cast(pol_xel as integer)                                as pol_xel,
        {{ clean_string('o_ucd') }}                             as o_ucd,

        -- condiciones y configuración
        cast(pwv as double)                                     as pwv_mm,
        {{ clean_string('antenna_arrays') }}                    as antenna_arrays,

        -- auditoría
        to_timestamp_ntz(lastmodified)                          as last_modified_at,
        to_timestamp_ntz(date_load)                             as date_load,
        _file_name,
        _file_row_number,
        _loaded_at

    from source

)

select * from typed
