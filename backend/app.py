# app.py
from fastapi import FastAPI, File, UploadFile, HTTPException
from torchvision import transforms
from PIL import Image
import torch
import torch.nn.functional as F
import io
from torchvision.models import resnet50
import logging

print(Image.core.jpeglib_version if hasattr(Image.core, 'jpeglib_version') else "No JPEG support")

# Configure logging
logging.basicConfig(level=logging.WARNING)
logger = logging.getLogger(__name__)

app = FastAPI()
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# Load model
checkpoint = torch.load("weights/resnet50_dog_breed_classifier.pth", map_location=device)
# label category
class_name = checkpoint["class_names"]
num_classes = len(class_name)  # Matches your label_categories
model = resnet50(num_classes=num_classes).to(device)
try:
   model.load_state_dict(checkpoint['state_dict'])  # Update path
except Exception as e:
    print(f"Error loading model: {e}")
    raise
model.eval()



# Transform
transform = transforms.Compose([
    transforms.Resize((160, 160)),
    transforms.ToTensor()
])

@app.post("/predict/")
async def predict(file: UploadFile = File(...)):
    try:
        # Validate file type
        logger.debug(f"Received file: {file.filename}, content_type: {file.content_type}")
        if not file.content_type.startswith("image/"):
            raise HTTPException(status_code=400, detail="File must be an image")

        # Read and process the uploaded image
        contents = await file.read()
        img = Image.open(io.BytesIO(contents)).convert("RGB")
        
        # Apply transformations
        img = transform(img).unsqueeze(0).to(device)  # Add batch dimension

        # Make prediction
        with torch.no_grad():
            output = model(img)
            probs = F.softmax(output, dim=1)
            top3_probs, top3_indices = torch.topk(probs, 3)

        # Format results
        results = [
            {
                "breed": class_name[top3_indices[0][i].item()],
                "probability": round(top3_probs[0][i].item(), 4)
            }
            for i in range(3)
        ]

        return {"predictions": results, "filename": file.filename}

    except Exception as e:
        logger.error(f"Error processing image: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Error processing image: {str(e)}")
    
# Health check
@app.get("/")
async def root():
    return {"message": "Dog breed prediction API is running"}
