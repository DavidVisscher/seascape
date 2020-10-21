"""
Provides a function for exporting captured data to a websocket.

Takes data from a queue.
"""

import json
import websocket
import logging

from queue import Queue


def websocket_exporter(queue: Queue, url):
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

    def on_open(ws):
        while True:
            data = queue.get(block=True)
            ws.send(json.dumps(data))

    ws = websocket.WebSocketApp(url, on_message=on_message, on_error=on_error, on_close=on_close)
    ws.on_open = on_open
    ws.run_forever()
