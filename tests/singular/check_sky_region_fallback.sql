-- check_sky_region_fallback: debe haber exactamente una región 'fallback' y tener la prioridad más alta (la última).
-- Si no, alguna observación podría quedarse sin región o caer en el resto antes de tiempo.
with

regions as (
    select
        alma_sky_regions.priority,
        alma_sky_regions.rule
    from {{ ref('alma_sky_regions') }} as alma_sky_regions
),

summary as (
    select
        count_if(regions.rule = 'fallback') as n_fallback,
        max(iff(regions.rule = 'fallback', regions.priority, null)) as fallback_priority,
        max(regions.priority) as max_priority
    from regions
),

failures as (
    select
        summary.n_fallback,
        summary.fallback_priority,
        summary.max_priority
    from summary
    where summary.n_fallback <> 1
       or summary.fallback_priority <> summary.max_priority
)

select * from failures
