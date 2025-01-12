from fastapi import FastAPI, Request, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from sentence_transformers import SentenceTransformer, util
from ultralytics import YOLO
import mediapipe as mp
from transformers import pipeline
from PIL import Image
import numpy as np
import math
import easyocr
from gtts import gTTS
import os
import base64
import os
from dotenv import load_dotenv
from openai import OpenAI
import shutil
import cv2

#python -m uvicorn main:app --reload
#python -m uvicorn main:app --host 172.18.51.126 --port 8000
sentance_model = SentenceTransformer('all-MiniLM-L6-v2')

# yolo model
model = YOLO("yolov8l.pt") 

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
#model configs done

#functions
def perform_ocr_and_speak(image_path, language='en'):
    # Initialize the EasyOCR reader
    reader = easyocr.Reader([language])
    
    # Perform OCR on the image
    result = reader.readtext(image_path)
    
    # Extract text from the result
    extracted_text = " ".join([text[1] for text in result])
    
    return extracted_text


app = FastAPI()
prompts = ['Read the text', 'describe what I am viewing', 'Identify object location', 'Other']
doc_embeddings = sentance_model.encode(prompts, convert_to_tensor=True)


#server requests
@app.post("/speech")
async def receive_speech(request: Request):
    data = await request.json()
    recognized_text = data.get("query")
    query_embedding_chatbot = sentance_model.encode(recognized_text, convert_to_tensor=True)
    cosine_scores = util.cos_sim(query_embedding_chatbot, doc_embeddings)[0] 
    ranked_docs = sorted(zip(cosine_scores.tolist(), prompts), reverse=True, key=lambda x: x[0])
    score, name = ranked_docs[0]
    if score <= 0.35:
        response_toapp = "I'm Sorry I could not understand"
    elif name == prompts[0]:
        response_toapp = 'Ok, I will begin reading the text, please point your camera towards it'
    elif name == prompts[1]:
        response_toapp = 'Ok, I will describe what is infront of you'
    elif name == prompts[2]:
        response_toapp = 'Ok, locating the object'
    elif name == prompts[3]:
        response_toapp = 'Ok, let me think'
    print("Received from Swift:", recognized_text)
    # ...use recognized_text to trigger your YOLO, Mediapipe, etc.
    return (response_toapp)

