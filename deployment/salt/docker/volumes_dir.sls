{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import compose with context %}

{%- for name, container in compose.items() %}
  {%- if 'volumes' in container %}
    {%- for bind in container.volumes %}
      {%- set mapping = bind.rsplit(':', 1) %}
      {{mapping[0]}}:
        file.directory:
          - user: root
          - group: root
          - dir_mode: 777
          - makedirs: True
          - recurse:
            - user
            - group
            - mode
      {% endfor %}
  {%- endif %}
{%- endfor %}
