from flask import Flask, request, jsonify, send_from_directory, render_template, send_file
from flask_cors import CORS
import os
import logging

app = Flask(__name__)
CORS(app)  # Enable CORS to allow requests from other domains

# Set up logging
logging.basicConfig(level=logging.DEBUG)

@app.after_request
def add_security_headers(response):
    response.headers['Cross-Origin-Opener-Policy'] = 'same-origin'
    response.headers['Cross-Origin-Embedder-Policy'] = 'require-corp'
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
    return response

# Main route
@app.route('/')
def serve_index():
    return send_from_directory(os.getcwd(), 'index.html')

# # Documentation of routes
# @app.route('/docs', methods=['GET'])
# def documentation():
#     return jsonify({
#         "routes": [
#             {"path": "/", "methods": ["GET"], "description": "Main route"},
#             {"path": "/train", "methods": ["POST"], "description": "Train the model"},
#             {"path": "/ask", "methods": ["POST"], "description": "Ask questions to the model"}
#         ]
#     })

# # Route to train the model
# @app.route('/train', methods=['POST'])
# def train_model():
#     # Check if a file was uploaded
#     if 'file' not in request.files:
#         return jsonify({"error": "No file was uploaded"}), 400

#     file = request.files['file']
#     input_text = request.form.get('inputText')
#     language = request.form.get('language')
#     previous_model = request.form.get('previousModel')
#     model_description = request.form.get('modelDescription')

#     # Here you would add the logic to train the model with the file and other data
#     response = {
#         "message": "Model trained successfully",
#         "file_name": file.filename,
#         "inputText": input_text,
#         "language": language,
#         "previousModel": previous_model,
#         "modelDescription": model_description
#     }
#     return jsonify(response)

# # Route to answer questions
# @app.route('/ask', methods=['POST'])
# def ask_question():
#     try:
#         data = request.json
#         if not data:
#             return jsonify({"error": "No data was sent"}), 400

#         question = data.get("question")
#         if not question:
#             return jsonify({"error": "The 'question' field is required"}), 400

#         # Simulate a response based on the trained model
#         response = {
#             "status": "success",
#             "question": question,
#             "answer": f"Generated response for: {question}",
#             "notes": "Additional information from the database"
#         }
#         return jsonify(response)

#     except Exception as e:
#         return jsonify({"error": "An error occurred while answering the question", "details": str(e)}), 500

# Global exception handling
# @app.errorhandler(Exception)
# def handle_exception(e):
#     return jsonify({"error": "An error occurred on the server", "details": str(e)}), 500

# Route to serve the main HTML file

# Route to serve static files
@app.route('/<path:filename>')
def serve_static_files(filename):
    return send_from_directory(os.getcwd(), filename)

if __name__ == '__main__':
    app.run(debug=True, ssl_context='adhoc')