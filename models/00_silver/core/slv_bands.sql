{{ config(unique_key='band_id') }}

with

bands as (
    select
        cast(nullif(trim(band.value), '') as integer) as band_name,
        max(stg.date_load) as _date_load
    from {{ ref('stg_alma_obscore_clean') }} as stg,
        lateral split_to_table(stg.band_list, '{{ alma_list_separator("band_list") }}') as band
    {{ alma_new_rows_filter() }}
    group by all
),

final as (
    select
        {{ alma_band_id('bands.band_name') }} as band_id,
        bands.band_name,
        bands._date_load
    from bands
    where bands.band_name is not null
)

select * from final
