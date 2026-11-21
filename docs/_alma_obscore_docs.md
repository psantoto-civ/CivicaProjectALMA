{#
  Descripciones de las columnas de ivoa.obscore en staging, compartidas por
  stg_alma_obscore_typed, stg_alma_obscore_clean y stg_alma_obskeys_latest.
  Uso en YAML: description: "{{ doc('obscore_<columna>') }}"
  Texto oficial de TAP_SCHEMA.columns salvo donde se indica.
#}

{% docs obscore_spw_id %}
Clave sustituta de la ventana espectral: dbt_utils.generate_surrogate_key sobre (obs_id, target_name, sensitivity_10kms). Macro alma_spw_id.
{% enddocs %}

{% docs obscore_proposal_id %}
Identifier of proposal to which an spw belongs.
{% enddocs %}

{% docs obscore_obs_publisher_did %}
publisher dataset identifier
{% enddocs %}

{% docs obscore_group_ous_uid %}
Group OUS ID
{% enddocs %}

{% docs obscore_member_ous_uid %}
Member OUS ID
{% enddocs %}

{% docs obscore_asdm_uid %}
UID of the ASDM containing this Field.
{% enddocs %}

{% docs obscore_obs_id %}
internal dataset identifier, cut at 64 characters
{% enddocs %}

{% docs obscore_target_name %}
name of intended target, chosen by the PI
{% enddocs %}

{% docs obscore_schedblock_name %}
Name of the Scheduling Block used as a template for executing the ASDM containing this Field.
{% enddocs %}

{% docs obscore_obs_title %}
Case-insensitive search over the project title
{% enddocs %}

{% docs obscore_proposal_type %}
Tipo de proyecto (columna `type` del TAP): S, T, V, L, SV, E, P, CAL. Coincide con el último segmento de proposal_id.
{% enddocs %}

{% docs obscore_obs_creator_name %}
case-insensitive partial match over the full PI name. Wildcards can be used
{% enddocs %}

{% docs obscore_proposal_authors %}
Full name of CoIs .
{% enddocs %}

{% docs obscore_proposal_abstract %}
Text search on the proposal abstract. Only abstracts will be returned which contain the given text. The search is case-insensitive.
{% enddocs %}

{% docs obscore_bib_reference %}
Bibliography code
{% enddocs %}

{% docs obscore_pub_title %}
Case insensitive search through the title of the publication.
{% enddocs %}

{% docs obscore_first_author %}
The first author as provided by telbib.eso.org.
{% enddocs %}

{% docs obscore_authors %}
Full list of first author and all co-authors
{% enddocs %}

{% docs obscore_pub_abstract %}
Case insensitive text search through the abstract of the publication.
{% enddocs %}

{% docs obscore_publication_year %}
The year the publication did appear in the printed version of the refereed journal.
{% enddocs %}

{% docs obscore_obs_collection %}
short name for the data collection
{% enddocs %}

{% docs obscore_facility_name %}
telescope name
{% enddocs %}

{% docs obscore_instrument_name %}
instrument name
{% enddocs %}

{% docs obscore_dataproduct_type %}
type of product
{% enddocs %}

{% docs obscore_calib_level %}
calibration level (2 or 3). 2 if product_type = MOUS, 3 if product_type = GOUS
{% enddocs %}

{% docs obscore_collections %}
Indicates that there are external products
{% enddocs %}

{% docs obscore_access_url %}
URL to download the data
{% enddocs %}

{% docs obscore_access_format %}
Content format of the data
{% enddocs %}

{% docs obscore_access_estsize_kb %}
Estimated size of datasets in kilobytes (origen: access_estsize)
{% enddocs %}

{% docs obscore_data_rights %}
Access to data.
{% enddocs %}

{% docs obscore_obs_release_date %}
timestamp of date the data becomes publicly available. Nulo cuando el origen trae el marcador 3000-01-01 (probablemente fecha no fijada; inferencia).
{% enddocs %}

{% docs obscore_qa2_passed %}
Quality Assessment 2 status: does the Member / Group OUS fulfil the PI's requirements?
{% enddocs %}

{% docs obscore_science_observation %}
Flag to indicate whether this is a science observation.
{% enddocs %}

{% docs obscore_scan_intent %}
Scan intent list for the observed field.
{% enddocs %}

{% docs obscore_s_ra_deg %}
RA of central coordinates (origen: s_ra)
{% enddocs %}

{% docs obscore_s_dec_deg %}
DEC of central coordinates (origen: s_dec)
{% enddocs %}

{% docs obscore_gal_longitude_deg %}
Galactic longitude of the observation for RA/Dec. Estimated using PyEphem and RA/Dec. (origen: gal_longitude)
{% enddocs %}

{% docs obscore_gal_latitude_deg %}
Galactic latitude of the observation for RA/Dec. Estimated using PyEphem and RA/Dec. (origen: gal_latitude)
{% enddocs %}

{% docs obscore_s_fov_deg %}
size of the region covered (~diameter of minimum bounding circle) (origen: s_fov)
{% enddocs %}

{% docs obscore_s_region %}
region bounded by observation
{% enddocs %}

{% docs obscore_s_resolution_arcsec %}
typical spatial resolution (origen: s_resolution)
{% enddocs %}

{% docs obscore_spatial_resolution_arcsec %}
Average of the maximum and minimum spatial resolution values of all spectral windows (origen: spatial_resolution)
{% enddocs %}

{% docs obscore_spatial_scale_max_arcsec %}
Due to the fact that radio antennas can not be placed infinitely close, measurements do have a smallest separation which translates into a maximal angular distance beyond which features can not be resolved reliably any more. Adding observations with the ALMA Total Power array can add those missing largest scales. (origen: spatial_scale_max)
{% enddocs %}

{% docs obscore_s_xel1 %}
Number of elements along the first spatial axis
{% enddocs %}

{% docs obscore_s_xel2 %}
Number of elements along the second spatial axis
{% enddocs %}

{% docs obscore_is_mosaic %}
Flag to indicate if this ASDM represents a mosaic or not.
{% enddocs %}

{% docs obscore_t_min_mjd %}
start time of observation (MJD) (origen: t_min)
{% enddocs %}

{% docs obscore_t_max_mjd %}
end time of observation (MJD) (origen: t_max)
{% enddocs %}

{% docs obscore_t_exptime_s %}
exposure time of observation (origen: t_exptime)
{% enddocs %}

{% docs obscore_t_resolution_s %}
typical temporal resolution (origen: t_resolution)
{% enddocs %}

{% docs obscore_t_xel %}
Number of elements along the time axis
{% enddocs %}

{% docs obscore_band_list %}
Space delimited list of bands
{% enddocs %}

{% docs obscore_frequency_ghz %}
Observed (tuned) reference frequency on the sky. (origen: frequency)
{% enddocs %}

{% docs obscore_frequency_support %}
All frequency ranges used by the field [GHz]
{% enddocs %}

{% docs obscore_bandwidth_hz %}
Ancho de la ventana espectral (el TAP lo describe como 'Total Bandwidth', pero los valores corresponden a la ventana).
{% enddocs %}

{% docs obscore_em_min_m %}
start spectral coordinate value (origen: em_min)
{% enddocs %}

{% docs obscore_em_max_m %}
stop spectral coordinate value (origen: em_max)
{% enddocs %}

{% docs obscore_em_resolution_m %}
Estimated frequency resolution from all the spectral windows, using median values of channel widths. (origen: em_resolution)
{% enddocs %}

{% docs obscore_em_res_power %}
typical spectral resolution
{% enddocs %}

{% docs obscore_em_xel %}
Number of elements along the spectral axis
{% enddocs %}

{% docs obscore_spectral_resolution_khz %}
(origen: spectral_resolution)
{% enddocs %}

{% docs obscore_velocity_resolution_m_s %}
Estimated velocity resolution from all the spectral windows, from frequency resolution. (origen: velocity_resolution)
{% enddocs %}

{% docs obscore_sensitivity_10kms_mjy_beam %}
Estimated noise in an nominal 10km/s bandwidth. Note this is an indication only, it does not include the effects of flagging or Hanning smoothing, and a 10km/s bandwidth may not be achievable with the data as taken. (origen: sensitivity_10kms)
{% enddocs %}

{% docs obscore_cont_sensitivity_bandwidth_mjy_beam %}
Estimated noise in the aggregated continuum bandwidth. Note this is an indication only, it does not include the effects of flagging or dynamic range limitations. (origen: cont_sensitivity_bandwidth)
{% enddocs %}

{% docs obscore_pol_states %}
polarization states present in the data
{% enddocs %}

{% docs obscore_pol_xel %}
Number of polarization samples
{% enddocs %}

{% docs obscore_o_ucd %}
UCD describing the observable axis (pixel values)
{% enddocs %}

{% docs obscore_pwv_mm %}
Estimated precipitable water vapour from the XML_CALWVR_ENTITIES table. (origen: pwv)
{% enddocs %}

{% docs obscore_antenna_arrays %}
Blank-separated list of Pad:Antenna pairs, i.e., A109:DV09 J504:DV02 J505:DV05 for antennas DV09, DV02 and DV05 sitting on pads A109, J504, and J505, respectively.
{% enddocs %}

{% docs obscore_last_modified_at %}
Time stamp of last modification of the metadata (lastModified).
{% enddocs %}

{% docs obscore_date_load %}
Inicio de la extracción (UTC) de la carga de la que procede la fila. Ordena las versiones de una misma ventana (spw_id): en stg_alma_obscore_clean es la carga de la versión vigente.
{% enddocs %}

{% docs obscore__file_name %}
Añadida por Snowflake (METADATA$FILENAME): ruta del fichero en el stage.
{% enddocs %}

{% docs obscore__file_row_number %}
Añadida por Snowflake (METADATA$FILE_ROW_NUMBER): número de fila dentro del fichero.
{% enddocs %}

{% docs obscore__loaded_at %}
Añadida por Snowflake (METADATA$START_SCAN_TIME): inicio del escaneo del COPY INTO.
{% enddocs %}
{% docs obscore_scientific_category %}
Categoría científica del proyecto (p. ej. ISM and star formation, Active galaxies). Sin descripción en TAP_SCHEMA.columns; texto propio.
{% enddocs %}

{% docs obscore_science_keyword %}
Palabras clave científicas del proyecto. Sin descripción en TAP_SCHEMA.columns; texto propio.
{% enddocs %}

{% docs obscore_pi_userid %}
Identificador de usuario del PI en el portal de ALMA (inferencia: sin descripción en TAP_SCHEMA.columns).
{% enddocs %}

{% docs obscore_pi_name %}
Nombre del investigador principal (PI) del proyecto. Sin descripción en TAP_SCHEMA.columns; texto propio.
{% enddocs %}
