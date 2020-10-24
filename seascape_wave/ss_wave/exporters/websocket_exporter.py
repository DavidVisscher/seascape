"""
Provides a function for exporting captured data to a websocket.

Takes data from a queue.
"""

import os
import sys
import ssl
import json
import websocket
import logging
import time
import random

from queue import Queue


def websocket_exporter(queue: Queue, url, api_key):
    """
    Reads from queue and sends the data over a websocket continuously.
    Blocks when queue is empty.
    """
    websocket.enableTrace(False)
    
    random_backoff = 1

    def on_message(ws, message):
        logging.info(str.decode(message))

    def on_error(ws, error):
        logging.error(error)

    def on_open(ws):
        ws.send(json.dumps({'topic': 'ingest', 'event': 'phx_join', 'payload': {'api_key': api_key}, 'ref': None}))
        while True:
            data = queue.get(block=True)
            message = {'topic': 'ingest', 'event':'metrics', 'payload': data, 'ref': None}
            ws.send(json.dumps(message))

    def on_close(ws):
        nonlocal random_backoff
        random_backoff += random.randint(1,5)
        if random_backoff > 60:
            random_backoff = 60
        logging.critical(f"WEBSOCKET CLOSED. ATTEMPTING RECONNECT IN {random_backoff} SEC.")
        time.sleep(random_backoff)
        start_websocket(url, on_message, on_error, on_open, on_close)
    
    start_websocket(url, on_message, on_error, on_open, on_close)

def start_websocket(url, on_message, on_error, on_open, on_close):
    """
    Starts the websocket connection.
    """ 
    ws = websocket.WebSocketApp(url, on_message=on_message, on_error=on_error, on_close=on_close)
    ws.on_open = on_open

    logging.info('Starting websocket connection to %s', url)
    if 'SS_INSECURE' in os.environ:
        ws.run_forever(sslopt={"cert_reqs": ssl.CERT_NONE})
    else:
        ws.run_forever()
