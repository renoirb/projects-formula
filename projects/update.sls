{% from "projects/map.jinja" import projects with context %}
{%- set projectsList = salt['pillar.get']('projects:projects', {}) %}

{%- set project_repo_dir = projects.lookup.root_dir ~ '%s/' ~ projects.lookup.project_clone_subdir -%}

{%-   from "projects/_macros/git.sls" import git_latest -%}

{%-   set settings = {
          "mirror": True
} %}

{%-   for slug,obj in projectsList.items() %}

{%-     do obj.update(settings) %}

{%-     if obj.origin is defined %}
{%-       set repo_dir = project_repo_dir|format(slug) %}
{%-       if obj.ssh_key is not defined %}
{%-         set add_identity = {
                  "identity": projects.lookup.ssh_key
            } %}
{%-       else %}
{%-         set add_identity = {
                  "identity": obj.ssh_key
            } %}
{%-       endif %}
{%-       do obj.update(add_identity) %}
{{        git_latest(repo_dir, obj.origin, obj) }}
{%-     endif %}

{%-     if obj.pkgs is not undefined %}
Ensure APT dependencies for {{ slug }} are installed:
  pkg.installed:
    - pkgs: {{ obj.pkgs|json }}
{%-     endif %}

{%-   endfor %}
