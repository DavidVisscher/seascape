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

from queue import Queue


def websocket_exporter(queue: Queue, url, api_key):
    """
    Reads from queue and sends the data over a websocket continuously.
    Blocks when queue is empty.
    """
    websocket.enableTrace(True)
    
    def on_message(ws, message):
        logging.info(str.decode(message))

    def on_error(ws, error):
        logging.error(error)

    def on_close(ws):
        logging.critical("WEBSOCKET CLOSED")
        sys.exit(1)

    def on_open(ws):
        ws.send(json.dumps({'topic': 'ingest', 'event': 'phx_join', 'payload': {'api_key': api_key}, 'ref': None}))
        while True:
            data = queue.get(block=True)
            message = {'topic': 'ingest', 'event':'metrics', 'payload': data, 'ref': None}
            ws.send(json.dumps(message))
    
    ws = websocket.WebSocketApp(url, on_message=on_message, on_error=on_error, on_close=on_close)
    ws.on_open = on_open

    if 'SS_INSECURE' in os.environ:
        ws.run_forever(sslopt={"cert_reqs": ssl.CERT_NONE})
    else:
        ws.run_forever()
