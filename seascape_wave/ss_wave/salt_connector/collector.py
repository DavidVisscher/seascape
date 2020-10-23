"""
Collects data about the current state using salt.
Collected data is placed on a queue.
"""

import time
import threading
import datetime
import subprocess

from queue import Queue
from pathlib import Path

import schedule

from .client_wrapper import SaltClient
from .docker_stats_parser import get_docker_stats 

def salt_collector(queue: Queue, *, target='*', metric_interval=5, meta_interval=60):
    """
    Schedules a collection to take place periodically according to
    the given interval in seconds.
    """
    schedule.every(metric_interval).seconds.do(_collect_metrics, queue=queue, target=target)
    schedule.every(meta_interval).seconds.do(_collect_meta, queue=queue, target=target)
    while True:
        schedule.run_pending()
        time.sleep(1)


def _collect_metrics(queue: Queue, *, target='*'):
    """
    Collects information from salt and places it on a queue.
    """
    out_data = {'ss_datatype': 'metrics', 'timestamp': str(datetime.datetime.utcnow())}
    salt = SaltClient()

    docker_stats_data = get_docker_stats(tgt=target)
    for host, metrics in docker_stats_data.items():
        if host not in out_data.keys():
            out_data[host] = {}
        out_data[host]['docker_stats'] = metrics

    cpu_percent_data = salt.cmd(target, 'ps.cpu_percent')
    for host, metrics in cpu_percent_data.items():
        if host not in out_data.keys():
            out_data[host] = {}
        out_data[host]['cpu_percent'] = metrics
    
    cpu_times_data = salt.cmd(target, 'ps.cpu_times')
    for host, metrics in cpu_times_data.items():
        if host not in out_data.keys():
            out_data[host] = {}
        out_data[host]['cpu_times'] = metrics

    queue.put(out_data)


def _collect_meta(queue: Queue, *, target='*'):
    """
    Collects meta-information and places it on a queue.
    """
    out_data = {'ss_datatype': 'meta', 'timestamp': str(datetime.datetime.utcnow()) }
    salt = SaltClient()

    grains_data = salt.cmd(target, 'grains.items')
    for host, metadata in grains_data.items():
        if host not in out_data.keys():
            out_data[host] = {}
        out_data[host]['grains'] = metadata

    docker_info_data = salt.cmd(target, 'docker.info')
    for host, metadata in docker_info_data.items():
        if host not in out_data.keys():
            out_data[host] = {}
        out_data[host]['docker'] = metadata
    
    docker_data = salt.cmd(target, 'docker.ps', kwarg={'all':True, 'host':False, 'verbose':False})
    for host, metrics in docker_data.items():
        if host not in out_data.keys():
            out_data[host] = {}
        out_data[host]['docker'] = metrics

    queue.put(out_data)
