"""
Provides a function for exporting captured data to a file.

Takes data from a queue.
"""

import json

from queue import Queue
from pathlib import Path


def file_exporter(queue: Queue, filepath: Path):
    """
    Reads from queue continuously. Blocks when queue is empty.
    Events received are exported to disk as json.
    """

    with filepath.open('w+') as outfile:
        while True:
            data = queue.get(block=True)
            outfile.write(json.dumps(data) + "\n")
