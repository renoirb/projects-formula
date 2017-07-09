{% from "projects/map.jinja" import projects with context %}
{%- set projectsList = salt['pillar.get']('projects:projects', {}) %}

{%- if projects.lookup is defined %}

root_dir is {{ projects.lookup.root_dir }}:
  test.succeed_without_changes:
    - name: The parent directory ({{ projects.lookup.root_dir }}) where we store all projects

project_clone_subdir is {{ projects.lookup.project_clone_subdir }}:
  test.succeed_without_changes:
    - name: The sub directory name ({{ projects.lookup.root_dir }}<projectName>/{{ projects.lookup.project_clone_subdir }}) we store DVCS code clone

ssh_key is {{ projects.lookup.ssh_key }}:
  test.succeed_without_changes:
    - name: The SSH key we would use for accessing DVCS repositories

ssh_key_pub is {{ projects.lookup.ssh_key_pub }}:
  test.succeed_without_changes:
    - name: The SSH public key we would use for accessing DVCS repositories

{%- endif %}


{%- if projectsList is defined %}
{%-   for slug,obj in projectsList.items() %}
project {{ slug }}:
  test.succeed_without_changes:
    - name: 'With data {{ obj|json }}'

{%-   endfor %}

projects count is {{ projectsList.keys()|count }}:
  test.succeed_without_changes:
    - name: Counting how many projects are in pillar data

Projects projects pillar:
  test.succeed_without_changes:
    - name: 'We currently have {{ projectsList.keys()|json }}'

{%-   set previousGrains = salt['grains.get']('projects', null) %}
PreviousGrains value:
  test.succeed_without_changes:
    - name: 'We had {{ previousGrains|json }}'

{%- endif %}
