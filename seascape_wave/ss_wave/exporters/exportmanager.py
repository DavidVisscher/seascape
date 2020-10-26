"""
Module to manage exporting data to different sources.

Responsible for managing the different kinds of exporters and delegating to them.
"""

import logging
import threading

from queue import Queue


class ExportManager():
    """
    Class to manage different exporters and their threads.
    """

    def __init__(self):
        """
        Constructor for ExportManager
        """
        self.inbox = Queue()
        self.exporters = []


    def register_exporter(self, exporter, *args):
        """
        Registers an exporter with the manager.
        """
        exporter_queue = Queue()
        exporter_args = [exporter_queue] + list(args)
        exporter_thread = threading.Thread(target=exporter, daemon=True, args=exporter_args)
        self.exporters.append({'thread': exporter_thread, 'queue': exporter_queue})
        logging.info('Exporter thread %s registered.', str(exporter))

    def dispatch(self):
        """
        Reads from inbox and sends to all exporters.
        """
        while True:
            data = self.inbox.get(block=True)
            for exporter in self.exporters:
                exporter['queue'].put(data)

    def start(self):
        """
        Starts all exporter threads.
        """
        self.dispatcher_thread = threading.Thread(target=self.dispatch, daemon=True, args=[])
        self.dispatcher_thread.start()
        logging.info('Dispatcher thread %s started.', str(self.dispatcher_thread))

        for exporter in self.exporters:
            exporter['thread'].start()
            logging.info('Exporter thread %s started.', str(exporter))

    def join(self):
        """
        Joins all exporter threads.
        """
        self.dispatcher_thread.join()
        logging.info('Dispatcher thread %s joined.', str(self.dispatcher_thread))

        for exporter in self.exporters:
            exporter['thread'].join()
            logging.info('Exporter thread %s joined.', str(exporter))
