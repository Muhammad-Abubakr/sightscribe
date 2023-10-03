import os
import cv2
from imageai.Detection import VideoObjectDetection

from helper.utilities import forFrame

detector = VideoObjectDetection()
detector.setModelTypeAsRetinaNet()
detector.setModelPath(
    os.path.join(os.curdir, "models", "retinanet_resnet50_fpn_coco-eeacb38b.pth")
)
detector.loadModel()

video_path = detector.detectObjectsFromVideo(
    camera_input=cv2.VideoCapture(0),
    frames_per_second=20,
    minimum_percentage_probability=30,
    per_frame_function=forFrame,
    save_detected_video=False,
    log_progress=True,
)
