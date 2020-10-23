{%- from "haproxy/map.jinja" import proxy with context %}
{%- if proxy.enabled %}

haproxy_packages:
  pkg.installed:
  - names: {{ proxy.pkgs }}

/etc/default/haproxy:
  file.managed:
  - source: salt://haproxy/files/haproxy.default
  - require:
    - pkg: haproxy_packages

/etc/haproxy/haproxy.cfg:
  file.managed:
  - source: salt://haproxy/files/haproxy.cfg
  - template: jinja
  - require:
    - pkg: haproxy_packages

haproxy_ssl:
  file.directory:
  - name: /etc/haproxy/ssl
  - user: root
  - group: haproxy
  - mode: 750
  - require:
    - pkg: haproxy_packages

rate_limit_error_file:
  file.managed:
  - name: /etc/haproxy/errors/429.http11
  - user: root
  - group: root
  - mode: 644
  - source: salt://haproxy/files/errors/429.http11
  - template: jinja
  - makedirs: True
  - require:
    - pkg: haproxy_packages

haproxy_status_packages:
  pkg.installed:
  - pkgs:
    - socat

haproxy_status_sh:
  file.managed:
  - name: /usr/bin/haproxy-status.sh
  - user: root
  - group: root
  - mode: 700
  - source: salt://haproxy/files/haproxy-status.sh
  - template: jinja
  - require:
    - pkg: haproxy_status_packages

{%- if grains.get('virtual_subtype', None) not in ['Docker', 'LXC'] %}

net.ipv4.ip_nonlocal_bind:
  sysctl.present:
    - value: 1

{% endif %}

haproxy_service:
  service.running:
  - name: {{ proxy.service }}
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - watch:
    - file: /etc/haproxy/haproxy.cfg
    - file: /etc/default/haproxy

{%- for listen_name, listen in proxy.get('listen', {}).items() %}
  {%- if listen.get('enabled', True) %}
    {%- for bind in listen.binds %}
      {% if bind.get('ssl', {}).enabled|default(False) and bind.ssl.key is defined %}
        {%- set pem_file = bind.ssl.get('pem_file', '/etc/haproxy/ssl/%s/%s-all.pem'|format(listen_name, loop.index)) %}

{{ pem_file }}:
  file.managed:
    - template: jinja
    - source: salt://haproxy/files/ssl_all.pem
    - user: root
    - group: haproxy
    - mode: 640
    - makedirs: true
    - defaults:
        key: {{ bind.ssl.key|yaml }}
        cert: {{ bind.ssl.cert|yaml }}
        chain: {{ bind.ssl.get('chain', '')|yaml }}
    - require:
      - file: haproxy_ssl
    - watch_in:
      - service: haproxy_service

      {%- endif %}
    {%- endfor %}
  {%- endif %}
{%- endfor %}

{%- endif %}
