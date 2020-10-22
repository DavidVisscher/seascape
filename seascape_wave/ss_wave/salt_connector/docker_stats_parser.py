"""
Docker stats parser.
"""

import json

from ss_wave.salt_connector.client_wrapper import SaltClient

STATSFORMAT = r'{\"container\":\"{{ .Container }}\",\"name\":\"{{ .Name }}\",\"memory\":\"{{ .MemUsage }}\",\"memory_percent\":\"{{ .MemPerc }}\",\"cpu\":\"{{ .CPUPerc }}\", \"network_io\":\"{{ .NetIO }}\", \"block_io\": \"{{ .BlockIO }}\", \"pids\":\"{{ .PIDs}}\" }'


def get_docker_stats(tgt='*'):
    """
    Gets and parses docker stats for each minion.
    """
    salt = SaltClient()
    raw_stats_output = salt.cmd(tgt, 'cmd.run', arg=[f'docker stats --no-stream --format "{STATSFORMAT}"'])

    out = {}
    for minion, data in raw_stats_output.items():
        print(f"{minion}: {data}")
        if int(data['retcode']) == 0:
            out[minion] = parse_stats(data['ret'])

    return out


def parse_stats(raw_stats: str) -> dict:
    """
    Returns a raw stats 
    """
    out = []
    for line in raw_stats.split('\n'):
        line_data = json.loads(line)
        for key, value in line_data.items():
            if isinstance(value, str) and '/' in value and value.strip() != '':
                usage = value.split('/')
                line_data[key] = {'used': usage[0], 'limit': usage[1]}
        out.append(line_data)
    return out
