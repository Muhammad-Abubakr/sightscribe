import io
import base64
from PIL import Image

from rest_framework.response import Response
from rest_framework.request import Request
from rest_framework.views import APIView

from utilities.object_detection import objDRetina, serialize


class CameraService(APIView):
    """
    View to receive the Camera Stream from the flutter client Application.
    """

    def get(self, request: Request):
        """
        greets the client.
        """
        return Response("Hello, Friend!")

    def post(self, request: Request):
        """
        greets the client.
        """
        pil_image: Image = Image.open(io.BytesIO(base64.b64decode(request.data["image"])))
        detected_objects = objDRetina(pil_image)
        serialize(detected_objects)

        return Response("hehe")
