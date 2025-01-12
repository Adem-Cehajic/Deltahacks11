from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
#python -m uvicorn main:app --reload
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["172.18.30.198"],  # Change to specific domains if needed
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.post("/speech")
async def receive_speech(request: Request):
    data = await request.json()
    recognized_text = data.get("query")
    print("Received from Swift:", recognized_text)
    # ...use recognized_text to trigger your YOLO, Mediapipe, etc.
    return {"status": "OK", "processedText": recognized_text}