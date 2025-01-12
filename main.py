from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
#python -m uvicorn main:app --reload
#python -m uvicorn main:app --host 172.18.51.126 --port 8000
app = FastAPI()



@app.post("/speech")
async def receive_speech(request: Request):
    data = await request.json()
    recognized_text = data.get("query")
    print("Received from Swift:", recognized_text)
    # ...use recognized_text to trigger your YOLO, Mediapipe, etc.
    return {"status": "OK", "processedText": recognized_text}