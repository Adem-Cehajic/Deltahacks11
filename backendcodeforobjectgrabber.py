import cv2
from ultralytics import YOLO
import mediapipe as mp
from transformers import pipeline
from PIL import Image
import numpy as np
import math
import time
# yolo model
model = YOLO("yolov8m.pt") 

#depthestimator model also note to SAMMY if running this from ur computer change device to 'cuda' i only put cpu cuz mine isnt powerful enough
depth_estimator = pipeline(task="depth-estimation", model="depth-anything/Depth-Anything-V2-Small-hf", device='cuda')
#SAMMY PLEASE READ THIS ONE COMMENT

# hand tracker model
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(static_image_mode=False,
                       max_num_hands=2,
                       min_detection_confidence=0.5,
                       min_tracking_confidence=0.5)
mp_drawing = mp.solutions.drawing_utils

# get webcam
cap = cv2.VideoCapture(0)
if not cap.isOpened():
    print("Error: Could not open webcam.")
    exit()

#function for full thing which is called upon wanting to find an object
def handtoobjectfinder():
    while True:
        ret, frame = cap.read()
        if not ret:
            print("Error: Failed to capture frame.")
            break

    # Convert the frame to RGB
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        pil_frame = Image.fromarray(rgb_frame)
    # Run Mediapipe Hands on the frame
        hand_results = hands.process(rgb_frame)

    # Run YOLO model on the frame
        yolo_results = model(frame)

        # Run depth-estimation model on the frame
        depth_result = depth_estimator(pil_frame)
        depth_map = np.array(depth_result['depth'])  # Extract the depth map (as a NumPy array)

    # Normalize the depth map for visualization (scale to 0-255)
        normalized_depth = cv2.normalize(depth_map, None, 0, 255, cv2.NORM_MINMAX).astype('uint8')
        depth_colored = cv2.applyColorMap(normalized_depth, cv2.COLORMAP_MAGMA)  # Colorize for better visualization

        c = 0
    # Draw YOLO detections
        for box in yolo_results[0].boxes:
            class_id = int(box.cls)
    # no ppl and ppl counter
            if class_id == 0:
                c += 1
                continue

    # Get box coordinates
            x1, y1, x2, y2 = map(int, box.xyxy[0])  # Bounding box coordinates

    # Map class ID to label
            label = model.names[class_id]

    # Draw bounding box
            cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)

    # Put label and confidence text
            text = f"{label}"
            cv2.putText(frame, text, (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
        #this makes vector vector used later for direction
            object_x = (x1 + x2) // 2
            object_y = (y1 + y2) // 2
        

    # HANDS
        if hand_results.multi_hand_landmarks:
            for hand_landmarks in hand_results.multi_hand_landmarks:
                mp_drawing.draw_landmarks(
                    frame,
                    hand_landmarks,
                    mp_hands.HAND_CONNECTIONS,
                    mp_drawing.DrawingSpec(color=(0, 255, 0), thickness=2, circle_radius=2),
                    mp_drawing.DrawingSpec(color=(0, 0, 255), thickness=2, circle_radius=2),
            )
        if hand_results.multi_hand_landmarks and len(yolo_results[0].boxes) - c != 0:
            hand_landmarks = hand_results.multi_hand_landmarks[0]
            hand_x = int(hand_landmarks.landmark[mp_hands.HandLandmark.WRIST].x * 640)
            hand_y = int(hand_landmarks.landmark[mp_hands.HandLandmark.WRIST].y * 480)
            dx = object_x - hand_x
            dy = object_y - hand_y
            angle_radians = math.atan2(dy, dx)
            print(angle_radians)
            cv2.line(frame, (hand_x, hand_y), (object_x, object_y), (255, 0, 0), 2)

        #IMPORTANT REMEMBER THIS
        combined_frame = cv2.addWeighted(frame, 0.6, depth_colored, 0.4, 0)  # Blend annotations with depth
        #UNCOMMENTING THIS WILL BRING DEPTH COLOR BACK TO DEMO
    
    # Display the annotated frame
        cv2.imshow("YOLO + Mediapipe Hands Tracking", combined_frame)

    # Break the loop if 'q' is pressed
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

handtoobjectfinder()

# Release resources to exit the camera
cap.release()
cv2.destroyAllWindows()
