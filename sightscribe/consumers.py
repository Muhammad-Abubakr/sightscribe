import io
import json

from channels.generic.websocket import WebsocketConsumer
from concurrent.futures.thread import ThreadPoolExecutor
from PIL import Image

from utilities.object_detection import objDRetina, serialize


class ImageStreamConsumer(WebsocketConsumer):
    frame = 0

    def connect(self):
        self.accept()
        self.send(text_data=json.dumps({"message": "connection accepted"}))

    def disconnect(self, close_code):
        pass

    def receive(self, text_data=None, bytes_data=None):
        if bytes_data is not None:
            detected_objects = objDRetina(Image.open(io.BytesIO(bytes_data)))
            self.send(serialize(detected_objects))

            # with ThreadPoolExecutor(max_workers=4) as executor:
            #     executor.submit()
