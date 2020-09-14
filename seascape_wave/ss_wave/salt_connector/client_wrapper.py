"""
Module containing a wrapper for the salt LocalClient object that sets some
sane defaults.
"""

import logging

import salt.client


class SaltClient():
    """
    Salt client, wrapped by SeaScape Wave. Just sets some
    sane defaults and maintains logs.
    """

    def __init__(self, *, timeout=30, tgt_type='glob', full_return=True):
        self._timeout = timeout
        self._tgt_type = tgt_type
        self._full_return = full_return

        self._salt_client = salt.client.LocalClient()


    def cmd(self, tgt, function, *, arg=list(), kwarg=None, **kwargs):
        """
        Runs a command on the salt master with configured defaults.
        """
        logging.debug("Running function \"%s\" on \"%s\" with arguments \"%s\"", function, tgt, arg)

        return self._salt_client.cmd(
                tgt, 
                function,
                arg=arg,
                timeout=self._timeout,
                tgt_type=self._tgt_type,
                full_return=self._full_return,
                kwarg=kwarg,
                **kwargs)

