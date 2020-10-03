# Processes hostname based on the following assumption:
# All hostnames have the format [type]-[number].[domain]
# For example: proxy-0.seascape.example
#          or: elastic-12.seascape.example

{% set hostname, domainname = opts ['id'].split('.', 1) %} # Split hostname & Domainname
{% set type, number = hostname.split('-', 1) %} # Split type and number out of hostname

base:
  '*':
    # Things applied to all machines:
    - all 
     
    # Things specific to the machine's role:
    - roles/{{type}} 
     
    # Things specific to this machine:
    - minions/{{ domainname | replace('.', '_') }}/{{ hostname }} 
