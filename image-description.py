import cv2
import base64
import os
from dotenv import load_dotenv
from openai import OpenAI

# Load environment variables from the .env file
load_dotenv()

def capture_image():
    """Capture an image from the webcam and save it locally."""
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
    """Analyze the captured image using OpenAI GPT."""
    client = OpenAI(api_key=api_key)

    with open(image_path, "rb") as image_file:
        image_data = base64.b64encode(image_file.read()).decode("utf-8")

    prompt = (
        "Describe the main elements of the image in simple, direct language. "
        "Focus on key objects, their positions, and basic room features. Avoid detailed adjectives. "
        "Mention people if present. Keep the description very brief, suitable for about 5-7 seconds of speech. "
        "Explain this as if the user is blind or has impaired vision in adequate detail."
    )

    try:
        response = client.chat.completions.create(
            model="gpt-4",
            messages=[
                {"role": "user", "content": prompt}
            ],
            max_tokens=300
        )
        return response.choices[0].message.content
    except Exception as e:
        return f"Error: {str(e)}"

# Main execution
if __name__ == "__main__":
    # Retrieve the API key from the environment (.env file)
    api_key = os.getenv("OPENAI_API_KEY")
    
    if not api_key:
        print("Error: API key not found. Please ensure it is set in the .env file.")
    else:
        image_path = capture_image()
        if image_path:
            description = analyze_image_with_gpt(image_path, api_key)
            print("Image Description:", description)
        else:
            print("Image capture failed. Cannot proceed with analysis.")
