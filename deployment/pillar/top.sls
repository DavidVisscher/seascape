# Processes hostname based on the following assumption:
# All hostnames have the format [type]-[number].[domain]
# For example: proxy-0.seascape.example
#          or: elastic-12.seascape.example

{% set hostname, domainname = opts ['id'].split('.', 1) %} # Split hostname & Domainname
{% set type = hostname.split('-', 1)[0] %} # Split number out of hostname

base:
  '*':
    # Things applied to all machines:
    - all 
     
    # Things specific to the machine's role:
    - roles/{{type}} 
     
    # Things specific to this machine:
    # The exception is the rule
    {% set minionpath = '/srv/pillar/minions/' + domainname | replace('.', '_') + '/' + hostname %}
    {% set minionfiles = /srv/pillar/'minions/' | list_files | join(',') %}
    {% if minionpath in minionfiles %}
    - minions/{{ domainname | replace('.', '_') }}/{{ hostname }}
    {% endif %}
