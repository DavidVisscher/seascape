"""
Docker stats parser.
"""

import json

from ss_wave.salt_connector.client_wrapper import SaltClient

STATSFORMAT = r'{\"container\":\"{{ .Container }}\",\"name\":\"{{ .Name }}\",\"memory\":{\"raw\":\"{{ .MemUsage }}\",\"percent\":\"{{ .MemPerc }}\"},\"cpu\":\"{{ .CPUPerc }}\", \"network_io\":\"{{ .NetIO }}\", \"block_io\": \"{{ .BlockIO }}\", \"pids\":\"{{ .PIDs}}\" }'


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
        out.append(json.loads(line))
    return out
