{# vi: set ft=jinja: #}
{#
 # Clone a git repository into a directory
 #
 # See also https://github.com/renoirb/salt-basesystem/tree/master/basesystem/macros
 #}
{% macro git_clone(creates, origin, args={}) %}

{% set user = args.get('user', None) %}
{% set identity = args.get('identity', None) %}

{% set mirror = args.get('mirror', None) %}

{% set branchName = args.get('branch', 'master') %}
{% set remotes = args.get('remotes') %}

{% set before_unpack_remote = args.get('before', []) %}

Git clone {{ creates }}:
  file.directory:
    - name: {{ creates }}
    - makedirs: True
{% if user %}
    - user: {{ user }}
{% endif %}
{% if before_unpack_remote|count() >= 1 %}
    - watch_in:
{% for archive_dest in before_unpack_remote %}
      - file: Unpack {{ archive_dest }}
{% endfor %}
{% endif %}
  git.latest:
    - name: {{ origin }}
    - rev: {{ branchName }}
    - target: {{ creates }}
    - unless: test -d {{ creates }}/.git
    - force_fetch: True
{% if mirror %}
    - mirror: True
{% endif %}
{% if user %}
    - user: {{ user }}
{% endif %}
{% if identity %}
    - identity: {{ identity }}
{% endif %}
{%- if remotes -%}
{% for remote_name,remote in remotes.items() %}
{%- if remote_name != 'origin' -%}
Git add remote {{ remote_name }} to {{ creates }}:
  cmd.run:
    - name: git remote add {{ remote_name }} {{ remote }}
    - unless: grep -q -e 'remote "{{ remote_name }}' .git/config
    - cwd: {{ creates }}
{% if user %}
    - user: {{ user }}
{% endif %}
{%- endif -%}
{% endfor %}
{%- endif -%}
{% endmacro %}



{% macro git_clone_loop(list, inject=None) %}
{% if list.items()|count >= 1 %}
{% for dir,obj in list.items() %}
{% if inject %}
{% do obj.update(inject) %}
{% endif %}
{{ git_clone(dir, obj.origin, obj) }}
{% endfor %}
{% endif %}
{% endmacro %}



{% macro git_mirror(repo, dest, args={}) %}

{% set user = args.get('user', 'root') %}
{% set identity = args.get('identity', None) %}

Git mirror {{ dest }}:
  file.directory:
    - name: {{ dest }}
    - makedirs: True
{% if user %}
    - user: {{ user }}
{% endif %}
  git.latest:
    - name: {{ repo }}
    - target: {{ dest }}
    - mirror: True
    - onlyif: test ! -d {{ dest }}/.git
{% if identity %}
    - identity: {{ identity }}
{% endif %}
{% endmacro %}



{% macro git_archive(local_repo, dest, branch='master') %}

{% set slug = local_repo.split('/')|last() %}

Git archive {{ local_repo }} to {{ dest }}:
  file.directory:
    - name: {{ dest }}
  cmd.run:
    - cwd: {{ local_repo }}
    - name: git archive --prefix={{ slug }}/ --format zip -9 --output {{ dest }}/{{ slug }}-$(date +%Y%m%d-%H%M).zip {{ branch }}
    - unless: test -f {{ dest }}/{{ slug }}-$(date +%Y%m%d-%H%M).zip
    - stateful: True
{% endmacro %}



{% macro git_latest(creates, origin, args={}) %}

{% set user = args.get('user', None) %}
{% set identity = args.get('identity', None) %}

{% set branchName = args.get('branch', 'master') %}
{% set remotes = args.get('remotes') %}

{% set before_unpack_remote = args.get('before', []) %}

Git latest {{ creates }}:
  git.latest:
    - name: {{ origin }}
    - rev: {{ branchName }}
    - target: {{ creates }}
{% if user %}
    - user: {{ user }}
{% endif %}
{% if identity %}
    - identity: {{ identity }}
{% endif %}
{% endmacro %}



{% macro git_latest_loop(list, inject=None) %}
{% if list.items()|count >= 1 %}
{% for dir,obj in list.items() %}
{% if inject %}
{% do obj.update(inject) %}
{% endif %}
{{ git_latest(dir, obj.origin, obj) }}
{% endfor %}
{% endif %}
{% endmacro %}
