import json

from imageai.Detection import ObjectDetection
from PIL import Image
import os


MODEL_PATH = os.path.join(os.getcwd(), "models", "retinanet_resnet50_fpn_coco-eeacb38b.pth")
detector = ObjectDetection()
detector.setModelTypeAsRetinaNet()
detector.setModelPath(MODEL_PATH)
detector.loadModel()


def objDRetina(image: Image):
    return detector.detectObjectsFromImage(input_image=image)


def serialize(objects):
    return json.dumps({"objects": f"{objects}"})
