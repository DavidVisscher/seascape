'''
Main module for Seascape Wave.

Sets up the basic infrastructure for monitoring an sending data to SeaScape Umbrella.
'''

import logging
import threading
import os

from pathlib import Path
from queue import Queue

import click

import ss_wave.salt_connector as salt_connector

from ss_wave.exporters.exportmanager import ExportManager
from ss_wave.exporters.file_exporter import file_exporter
from ss_wave.exporters.websocket_exporter import websocket_exporter
from ss_wave.salt_connector.collector import salt_collector


@click.command()
@click.option('-d', '--debug', help="Run in debug mode.", default=False)
def main(debug):
    """
    Main entrypoint for starting the agent.
    """
    # Set up logging first
    init_logging(debug=debug)

    logging.info("Starting Seascape Wave agent")

    logging.info("Discovering nodes...")
    
    nodes = salt_connector.minions.list_minions() 
    logging.info("%s", nodes)

    exportmanager = ExportManager()
    exportmanager.register_exporter(file_exporter, Path('/tmp/ss_wave'))
    
    if 'SS_WEBSOCKET_URL' in os.environ and 'SS_API_KEY' in os.environ:
        exportmanager.register_exporter(websocket_exporter, os.environ['SS_WEBSOCKET_URL'], os.environ['SS_API_KEY'])

    in_thread = threading.Thread(target=salt_collector, daemon=True, args=[exportmanager.inbox])
    in_thread.start()
    exportmanager.start()
    
    in_thread.join()
    exportmanager.join()

def init_logging(debug=False):
    """
    Sets up logging at application start.
    """
    # Create handler for logging to stdout
    consolehandler = logging.StreamHandler()
    if debug:
        consolehandler.setLevel(logging.DEBUG)
    else:
        consolehandler.setLevel(logging.INFO)

    formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
    consolehandler.setFormatter(formatter)

    logging.getLogger().addHandler(consolehandler)

if __name__ == '__main__':
    main()
