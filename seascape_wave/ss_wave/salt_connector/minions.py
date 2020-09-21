"""
Module containing functions for minion manipulation.
"""

from .client_wrapper import SaltClient


SALT = SaltClient()

def list_minions(*, show_all=False):
    """
    Returns a list of minion names.

    By default only return the names of running minions.
    Specify show_all to get all known minions, even if down.
    """
    output = SALT.cmd('*', 'test.ping')

    minion_names = []
    for minion, data in output.items():
        if data['ret']:
            minion_names.append(minion)
    return minion_names
