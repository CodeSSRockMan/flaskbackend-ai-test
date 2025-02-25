from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Habilitar CORS para permitir solicitudes desde otros dominios

# Ruta principal
@app.route('/')
def home():
    return "Bienvenido a tu backend en Flask!"

# Documentación de rutas
@app.route('/docs', methods=['GET'])
def documentation():
    return jsonify({
        "routes": [
            {"path": "/", "methods": ["GET"], "description": "Ruta principal"},
            {"path": "/train", "methods": ["POST"], "description": "Entrenar el modelo"},
            {"path": "/ask", "methods": ["POST"], "description": "Realizar preguntas al modelo"}
        ]
    })

# Ruta para entrenar el modelo
@app.route('/train', methods=['POST'])
def train_model():
    # Verificar si el archivo fue enviado
    if 'file' not in request.files:
        return jsonify({"error": "No se subió un archivo"}), 400

    file = request.files['file']
    input_text = request.form.get('inputText')
    language = request.form.get('language')
    previous_model = request.form.get('previousModel')
    model_description = request.form.get('modelDescription')

    # Aquí iría la lógica para entrenar el modelo con el archivo y los demás datos
    response = {
        "message": "Modelo entrenado con éxito",
        "file_name": file.filename,
        "inputText": input_text,
        "language": language,
        "previousModel": previous_model,
        "modelDescription": model_description
    }
    return jsonify(response)

# Ruta para responder preguntas
@app.route('/ask', methods=['POST'])
def ask_question():
    try:
        data = request.json
        if not data:
            return jsonify({"error": "No se enviaron datos"}), 400

        question = data.get("question")
        if not question:
            return jsonify({"error": "El campo 'question' es obligatorio"}), 400

        # Simulación de respuesta basada en el modelo entrenado
        response = {
            "status": "success",
            "question": question,
            "answer": f"Respuesta generada para: {question}",
            "notes": "Información adicional proveniente de la base de datos"
        }
        return jsonify(response)

    except Exception as e:
        return jsonify({"error": "Ocurrió un error al responder la pregunta", "details": str(e)}), 500

# Manejo global de excepciones
@app.errorhandler(Exception)
def handle_exception(e):
    return jsonify({"error": "Ocurrió un error en el servidor", "details": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
