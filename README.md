# BreedFinder - Dog Breed Identification App

## About

BreedFinder is an iOS application that uses machine learning to identify dog breeds from photos with high accuracy. The app features a ResNet50 model trained on 70 dog breeds, a FastAPI backend, and an intuitive SwiftUI interface.

## Features

- High-accuracy dog breed identification
- Camera and photo library integration
- Visual confidence score display
- Intuitive user interface
- Fast and responsive design

## Project Structure

```
dog-breed-identifier/
├── backend/              # FastAPI backend server
│   ├── app.py            # Main API entry point
│   ├── requirements.txt  # Python dependencies
│   └── weights/resnet50_dog_breed_classifier.pth # Trained model weights
├── DogPhotoUploader/     # iOS Swift app
│   ├── DogPhotoUploader.xcodeproj
│   └── DogPhotoUploader/
│       ├── ContentView.swift
└── data/        # Dataset
    └── dog photos
```

## Installation & Usage

### Backend Setup

1. Clone the repository
   ```
   git clone https://github.com/username/dog-breed-identifier.git
   cd dog-breed-identifier/backend
   ```

2. Create and activate a virtual environment
   ```
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. Install dependencies
   ```
   pip install -r requirements.txt
   ```

4. Ensure model weights file exists
   - Place `resnet50_dog_breed_classifier.pth` in the `backend/weights/` directory
   - Contact project maintainers if you need access to the weights file

5. Start the server
   ```
   uvicorn app:app --host 0.0.0.0 --port 8000
   ```
   
   The API will be available at:
   - Local testing: http://localhost:8000
   - Network access: http://YOUR_IP_ADDRESS:8000

### iOS App Setup

1. Open the project in Xcode
   ```
   cd ../DogPhotoUploader
   open DogPhotoUploader.xcodeproj
   ```

2. Configure the API endpoint in ContentView.swift
   - Update the URL in `uploadImageToServer` function to point to your running backend server
   - Default is `http://127.0.0.1:8000/predict/`

3. Run the app
   - Select a device or simulator
   - Press the play button or ⌘+R

### Using the App

1. Launch the BreedFinder app on your iOS device
2. Select a photo:
   - Tap "Select Photo" to choose from your photo library or take a new picture
3. Upload the photo:
   - After selecting an image, tap "Upload Photo" to send it for analysis
4. View results:
   - The app will display the top three breed predictions with confidence bars
   - Tap "Back to Homepage" to try another image

## API Endpoints

- `GET /`: Health check endpoint
- `POST /predict/`: Accepts image uploads and returns breed predictions
  
  Response format:
  ```json
  {
    "predictions": [
      {"label": "Golden_Retriever", "probability": 0.85},
      {"label": "Labrador_Retriever", "probability": 0.10},
      {"label": "German_Shepherd", "probability": 0.05}
    ],
    "filename": "dog_test.jpg"
  }
  ```

## Requirements

- **Backend**: Python 3.12+ with FastAPI, PyTorch, and other dependencies listed in requirements.txt
- **Frontend**: iOS 18.0+, Xcode 15.0+
- **Storage**: Approximately 100MB for the app and model

## Troubleshooting

- **API Connection Issues**: Ensure the backend server is running and the iOS app has the correct URL
- **Image Upload Fails**: Check that you're using JPEG or PNG format images
- **Low Prediction Accuracy**: Ensure good lighting and clear focus when taking photos

## License
This project is licensed under the MIT License - see the LICENSE file for details.
