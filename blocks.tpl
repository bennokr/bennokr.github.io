{%- extends 'display_priority.tpl' -%}

{%- block header -%}
<!DOCTYPE html>
<meta charset="utf-8">
<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js"></script>
{%- endblock header -%}

{% block codecell %}
{{ super() }}
{%- endblock codecell %}

{% block input_group -%}
{{ super() }}
{% endblock input_group %}

{{ super() }}

{% block in_prompt -%}
{%- endblock in_prompt %}

{% block empty_in_prompt -%}
{%- endblock empty_in_prompt %}

{# 

#}

{% block input %}
{%- endblock input %}

{{ super() }}

{% block markdowncell scoped %}
<!--
{{ cell.source | wrap_text(80) }}
-->
{%- endblock markdowncell %}

{% block unknowncell scoped %}
{% endblock unknowncell %}

{% block execute_result -%}

{% block data_priority scoped %}
{{ super() }}
{% endblock %}

{%- set extra_class="" -%}
{%- endblock execute_result %}

{% block stream_stdout -%}
{%- endblock stream_stdout %}

{% block stream_stderr -%}
{%- endblock stream_stderr %}

{% block data_svg scoped -%}
{%- endblock data_svg %}

{% block data_html scoped -%}
{{ output.data['text/html'] }}
{%- endblock data_html %}

{% block data_markdown scoped -%}
{%- endblock data_markdown %}

{% block data_png scoped %}
{%- endblock data_png %}

{% block data_jpg scoped %}
{%- endblock data_jpg %}

{% block data_latex scoped %}
{%- endblock data_latex %}

{% block error -%}
{{- super() -}}
{%- endblock error %}

{%- block traceback_line %}
{%- endblock traceback_line %}

{%- block data_text scoped %}
{%- endblock -%}

{%- block data_javascript scoped %}
<div id="js-output-{{ cell.execution_count }}"></div>
<script>
var element = $('#js-output-{{ cell.execution_count }}');
{{ output.data['application/javascript'] }}
</script>
{%- endblock -%}