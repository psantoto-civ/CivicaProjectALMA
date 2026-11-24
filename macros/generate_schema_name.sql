{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set use_prefix = env_var('DBT_SCHEMA_PREFIX', 'true') | trim | lower != 'false' -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- elif use_prefix -%}
        {{ target.schema }}_{{ custom_schema_name | trim }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}