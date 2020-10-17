import websocket
import json
import random
import time


def join(ws, topic, payload):
   send_event(ws, topic, "phx_join", payload)
   successful = json.loads(ws.recv())
   if successful['payload']['status'] == 'error':
      raise Exception(successful['payload']['response'])
   else:
      successful

def send_event(ws, topic, event, payload):
    print('Sending {}'.format(payload))
    ws.send(json.dumps(dict(topic=topic, event=event, payload=json.dumps(payload), ref=None)))

backoff = 1
while True:
   try:
      print('attempting to connect to websocket')
      ws = websocket.create_connection("ws://localhost:4001/ingest/websocket")
      join(ws, "ingest", dict(api_key="foobar"))
      backoff = 1
      while True:
         # Put this in event loop
         send_event(ws, "ingest", "metrics", dict(foo="bar", a=1))
         time.sleep(5)
   except Exception as error:
      print(error)
      # Retry with incremental backoff + jitter
      timeout = (1000 * backoff + random.randint(0, 1000))
      print('websocket connection failed. reconnecting after {} ms...'.format(timeout))
      time.sleep(timeout / 1000)
      backoff = min(backoff * 2, 60)
      continue
