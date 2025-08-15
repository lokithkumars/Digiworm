from flask import Flask, request, jsonify
import pickle
import numpy as np

# Initialize the Flask application
app = Flask(__name__)

# Load the trained machine learning model
# Make sure the 'model.pkl' file is in the same directory
try:
    model = pickle.load(open("model.pkl", "rb"))
except FileNotFoundError:
    print("Error: 'model.pkl' not found. Make sure the model file is in the correct directory.")
    exit()


# Define the prediction endpoint
@app.route('/predict', methods=['POST'])
def predict():
    # Get the JSON data sent from the Flutter app
    data = request.get_json(force=True)

    # The keys ('feature1', 'feature2', etc.) must match what you send from Flutter
    # and what the model was trained on.
    # For example: {'state': 'California', 'crop': 'Almonds', 'season': 'Autumn'}
    # You will need to preprocess these features (e.g., convert text to numbers)
    # exactly as it's done in the original GitHub project's training script.

    # Example: Assuming the model needs a NumPy array of numerical features
    # This part is CRUCIAL and must be adapted to your specific model
    try:
        # You must convert the input data to the correct format for your model
        # The example below assumes numeric inputs for simplicity
        features = np.array(list(data.values())).reshape(1, -1)
        
        # Use the model to make a prediction
        prediction = model.predict(features)
        
        # Return the prediction as a JSON response
        # The [0] is to extract the single value from the prediction array
        return jsonify({'market_price_prediction': prediction[0]})

    except Exception as e:
        # If anything goes wrong, return an error message
        return jsonify({'error': str(e)})


# Run the app
if __name__ == '__main__':
    # 'host='0.0.0.0'' makes the API accessible from your local network
    # so your phone can reach it during testing.
    app.run(host='0.0.0.0', port=5000)