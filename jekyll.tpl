{% extends 'markdown.tpl' %}

{%- block header -%}
---
layout: post
title: "{{resources['metadata']['title']}}"
tags:
    - python
    - notebook
---
{%- endblock header -%}

{% block codecell scoped %}
<a name="{{ cell.execution_count }}" ></a>
{{ super() }}
{% endblock codecell %}

{% block input %}
{% if cell.source %}
```{{ cell['metadata']['magics_language'] or nb.metadata.language_info.name  }}
{{ cell.source }}
```
{% endif %}
{% endblock input %}

{% block headingcell scoped %}
{{ '#' * cell.level }} {{ cell.source | replace('\n', ' ') }}
{% endblock headingcell %}

{%- block data_priority scoped -%}
{%- for type in output.data -%}
{%- if type == 'application/pdf' -%}
{%- block data_pdf -%}
{%- endblock -%}
{%- elif type == 'image/svg+xml' -%}
![svg]({{ output.output.svg_filename | path2support }}) 
{%- elif type == 'image/png' -%}
![png]({{ output.png_filename | path2support }}) 
{%- elif type == 'text/html' -%}
{{ output.data['text/html'] | relpath2support }}
{%- elif type == 'text/markdown' -%}
{%- block data_markdown -%}
{{ cell.source | wrap_text(80) }} 
{%- endblock -%}
{%- elif type == 'image/jpeg' -%}
![jpeg]({{ output.jpeg_filename | path2support }}) 
{%- elif type == 'text/plain' -%}
{%- block data_text -%}
{%- endblock -%}
{%- elif type == 'text/latex' -%}
{%- block data_latex -%}
{%- endblock -%}
{%- elif type == 'application/javascript' -%}
<div id="js-output-{{ cell.execution_count }}"></div>
<div class="output_subarea output_javascript {{extra_class}}">
<script type="text/javascript">
var element = $('#js-output-{{ cell.execution_count }}');
{{ output.data['application/javascript'] | relpath2support }}
</script>
</div>
{%- else -%}
{%- block data_other -%}
{%- endblock -%}
{%- endif -%}
{%- endfor -%}
{%- endblock data_priority -%}

