import os
import requests
from flask import Flask, request, jsonify
from flask_cors import CORS

# Initialize the Flask application
app = Flask(__name__)
CORS(app)  # Enable Cross-Origin Resource Sharing

# --- Get your Gemini API Key ---
# It's best practice to store your key as an environment variable
# instead of writing it directly in the code.
GEMINI_API_KEY = os.environ.get("AIzaSyBtUdl9q385j2UAejjxLW499Q40xf3P8u0")

# If you must hardcode it for testing, you can do this, but it's not recommended for production:
# GEMINI_API_KEY = "YOUR_GEMINI_API_KEY_HERE" 

if not GEMINI_API_KEY:
    print("FATAL: GEMINI_API_KEY environment variable not set.")

# The URL for the Gemini API
GEMINI_API_URL = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-preview-0514:generateContent?key={GEMINI_API_KEY}"


def generate_crop_plan_with_gemini(location):
    """
    Uses the Gemini API to generate a monthly crop planting schedule.
    """
    if not GEMINI_API_KEY:
        return {"error": "Server is missing API Key configuration."}

    # This is the prompt we send to the AI. It's designed to ask for a specific
    # JSON output format, which makes it easy for our Flutter app to understand.
    prompt = f"""
    Based on the general climate and agricultural conditions for {location}, India, create a simplified, ideal one-year monthly crop planting calendar.

    Provide a list of profitable and suitable crops for each month. The plan should be for a small-to-medium scale farm.

    Your response MUST be a valid JSON object. The JSON object should have keys representing each month of the year (e.g., "January", "February", etc.). The value for each month should be an array of strings, where each string is a suggested crop to plant in that month.

    Example for one month:
    "January": ["Wheat", "Mustard", "Gram"]

    Now, generate the full 12-month plan for {location}, India.
    """

    # The data payload for the Gemini API call
    payload = {
        "contents": [{
            "parts": [{
                "text": prompt
            }]
        }],
        "generationConfig": {
            "response_mime_type": "application/json",
        }
    }

    try:
        # Make the request to the Gemini API
        response = requests.post(GEMINI_API_URL, json=payload)
        response.raise_for_status()  # Raise an exception for bad status codes (4xx or 5xx)

        # Extract the JSON content from the response
        result = response.json()
        
        # The AI's response is a string of JSON inside the 'text' field.
        # We need to parse this string to get the actual JSON object.
        plan_text = result['candidates'][0]['content']['parts'][0]['text']
        
        # The response from the API might have ```json markdown, let's clean it.
        if plan_text.strip().startswith("```json"):
            plan_text = plan_text.strip()[7:-3]
        
        return plan_text

    except requests.exceptions.RequestException as e:
        print(f"Error calling Gemini API: {e}")
        return {"error": f"Could not connect to Gemini API. Details: {e}"}
    except (KeyError, IndexError) as e:
        print(f"Error parsing Gemini response: {e}")
        print(f"Full Gemini Response: {result}")
        return {"error": "Could not understand the response from the AI."}


@app.route('/generate_plan', methods=['POST'])
def handle_generate_plan():
    """Receives location from Flutter app and returns the AI-generated plan."""
    data = request.get_json()
    if not data or 'location' not in data:
        return jsonify({'error': 'No location provided'}), 400

    location = data['location']
    print(f"Generating plan for location: {location}")

    # Call the function to get the plan from Gemini
    plan = generate_crop_plan_with_gemini(location)

    # The plan is already a JSON string, so we can return it directly
    # with the correct content type.
    return app.response_class(
        response=plan,
        status=200,
        mimetype='application/json'
    )

@app.route('/', methods=['GET'])
def index():
    return "Gemini Crop Plan API is running!"


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

