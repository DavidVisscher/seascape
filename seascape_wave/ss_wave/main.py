'''
Main module for Seascape Wave.

Sets up the basic infrastructure for monitoring an sending data to SeaScape Umbrella.
'''

import logging

import click

import ss_wave.salt_connector as salt_connector


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
