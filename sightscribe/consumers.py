import base64
import io
import json

from channels.generic.websocket import WebsocketConsumer
from utilities.retina import objDRetina, serialize
from PIL import Image


class ImageStreamConsumer(WebsocketConsumer):
    count = 0

    def connect(self):
        self.accept()
        self.send(text_data=json.dumps({"message": "connection accepted"}))

    def disconnect(self, close_code):
        pass

    def receive(self, text_data=None, bytes_data=None):
        if bytes_data is not None:
            self.send(serialize(objDRetina(Image.open(io.BytesIO(bytes_data)))))
            self.count += 1

