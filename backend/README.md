# Dog Breed Prediction API

This is a FastAPI-based API that predicts dog breeds from images using a pre-trained ResNet50 model. It accepts image uploads (JPEG or PNG) and returns the top-3 predicted breeds with probabilities. The API is designed for integration with an iOS app and testing via Postman.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Build Process](#build-process)
- [API Usage](#api-usage)
- [Troubleshooting](#troubleshooting)
- [Project Structure](#project-structure)
- [License](#license)

## Prerequisites

- **Python**: 3.12 (other 3.7+ versions may work).
- **Git**: To clone the repository.
- **Model Weights**: Ensure `weights/resnet50_dog_breed_classifier.pth` is in the `backend/weights/` directory (not included in the repo; contact the team for access).

## Build Process

Follow these steps to set up and run the API locally.

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/dog_breed_identifier.git
cd dog_breed_identifier/backend
```

### 2. Activate the Virtual Environment and Install Python Dependencies
Activate the existing virtual environment:
```bash
source venv/bin/activate
pip install -r requirements.txt
```
- You should see (venv) in your terminal prompt.
- If venv is missing or corrupted, recreate it:
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```
### 3. Run the API
```bash
uvicorn app:app --host 0.0.0.0 --port 8000
```
- The API will be available at `http://localhost:8000`.
- Press Ctrl+C to stop the server.

## API Usage
The API provides two endpoints: a health check and a dog breed prediction endpoint.

### Base URL
- Local testing: http://localhost:8000
- Network (e.g., for iOS app): Use your machine’s IP, e.g., http://192.168.x.x:8000. Find it with:

### Endpoints
#### 1. Health Check (GET /)
- Description: Confirms the API is running.
- Request:
    - Method: GET
    - URL: http://localhost:8000/
- Response:
    - Status: 200 OK
        ```
        {"message": "Dog breed prediction API is running"}
        ```
#### 2. Predict Dog Breed (POST /predict/)
- Description: Uploads an image (JPEG or PNG) and returns the top-3 predicted dog breeds with probabilities.
- Request:
    - Method: POST
    - URL: http://localhost:8000/predict/
    - Headers: None required (Postman sets multipart/form-data automatically).
    - Body: Form-data
        - Key: file
        - Type: File
        - Value: Upload a dog image (e.g., dog_test.jpg or dog.png)
- Response:
    - Success (200 OK)
        ```
        {
            "predictions": [
                {"label": "Golden_Retriever", "probability": 0.85},
                {"label": "Labrador_Retriever", "probability": 0.10},
                {"label": "German_Shepherd", "probability": 0.05}
            ],
            "filename": "dog_test.jpg"
        }
        ```
    - Client Error (400 Bad Request)
        ```
        {"detail": "Invalid image: cannot identify file format"}
        OR
        {"detail": "Invalid image: broken data stream when reading image file"}
        ```
    - Server Error (500 Internal Server Error)
        ```
        {"detail": "Error processing image: <specific_error>"}
        ```
