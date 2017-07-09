{% from "projects/map.jinja" import projects with context %}
{%- set projectsList = salt['pillar.get']('projects:projects', {}) %}

Add projects list as a grain to Salt Master:
  grains.present:
    - force: True
    - name: projects
{%- if projectsList.keys()|count > 0 %}
    - value: {{ projectsList.keys()|json }}
{%- else %}
    - value: ~
{%- endif %}

{%- if projectsList.keys()|count > 0 %}
include:
  - projects.update
{%- endif %}
