from fastapi import APIRouter
import cv2
from routes.stream import capture_frame
import numpy as np

router = APIRouter(
    tags=["Nutritional Information"]
)

@router.get("/food_classification")
async def get_food_classification():
    frame = capture_frame()
    
    # Check if the frame is None, which indicates a problem
    if frame is None:
        return {"error": "Failed to capture frame"}

    # Preprocess the frame if necessary (resize, normalize, etc.)
    try:
        frame_resized = cv2.resize(frame, (224, 224))  # Example size for ML models
    except cv2.error as e:
        return {"error": f"Failed to resize frame: {str(e)}"}
    
    frame_input = np.expand_dims(frame_resized, axis=0)  # Add batch dimension
    
    # Send the frame to the machine learning model for prediction
    model_output = ""
    
    return {"message": "Frame processed successfully"}

