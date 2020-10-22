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
    raw_stats_output = salt.cmd(tgt, 'cmd.run', arg=[f'docker stats --all --no-stream --format "{STATSFORMAT}"'])

    out = {}
    for minion, data in raw_stats_output.items():
        print(f"{minion}: {data}")
        if int(data['retcode']) == 0:
            out[minion] = parse_stats(data['ret'])

    return out


def parse_stats(raw_stats: str) -> dict:
    """
    Reads the raw stats str returned by salt
    and turns it into a usable dictionary.
    """
    out = []
    for line in raw_stats.split('\n'):
        # Check if line is empty
        if line.strip() == '' or line.isspace():
            continue
        # Otherwise, we parse it
        line_data = json.loads(line)

        # Turn, for example "1/100" into {"usage": 1, "limit": 100}
        for key, value in line_data.items():
            if isinstance(value, str) and '/' in value:
                usage = value.split('/')
                line_data[key] = {'used': usage[0], 'limit': usage[1], "raw": value}

        # Append the data to be returned
        out.append(line_data)
    return out
