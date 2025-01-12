import cv2
import base64
import os
from openai import OpenAI

def capture_image():
    cap = cv2.VideoCapture(0)
    if not cap.isOpened():
        print("Error: Camera could not be opened.")
        return None

    ret, frame = cap.read()
    cap.release()

    if not ret:
        print("Error: Could not capture image.")
        return None

    image_path = "captured_image.jpg"
    cv2.imwrite(image_path, frame)
    print(f"Image captured and saved as {image_path}")
    return image_path

def analyze_image_with_gpt(image_path, api_key):
    client = OpenAI(api_key=api_key)

    with open(image_path, "rb") as image_file:
        image_data = base64.b64encode(image_file.read()).decode("utf-8")

    prompt = (
       "Describe the main elements of the image in simple, direct language. Focus on key objects, their positions, and basic room features. Avoid detailed adjectives. Mention people if present. Keep the description very brief, suitable for about 5-7 seconds of speech. Explain this as if the user is blind or has impaired vision in adequate detail."
    )

    try:
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": prompt},
                        {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{image_data}"}}
                    ]
                }
            ],
            max_tokens=300
        )
        return response.choices[0].message.content
    except Exception as e:
        return f"Error: {str(e)}"

# Main execution
api_key = os.environ.get('OPENAI_API_KEY')
if not api_key:
    raise ValueError("No API key found. Set the OPENAI_API_KEY environment variable.")

image_path = capture_image()
if image_path:
    description = analyze_image_with_gpt(image_path, api_key)
    print("Image Description:", description)
else:
    print("Image capture failed. Cannot proceed with analysis.")
