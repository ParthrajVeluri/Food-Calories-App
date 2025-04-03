from fastapi import APIRouter
from fastapi.responses import StreamingResponse
import cv2

# Initialize the camera globally
camera = None

router = APIRouter(
    tags=["Video Capture from main device camera"]
)

def generate_frames(camera):
    while True:
        success, frame = camera.read()
        if not success:
            break
        _, buffer = cv2.imencode('.jpg', frame)
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + buffer.tobytes() + b'\r\n')

def capture_frame():
    global camera
    if camera is None:
        return None 
    success, frame = camera.read()
    if not success:
        return None  
    return frame

@router.get("/video_feed")
async def video_feed():
    """
    Outputs real time video feed from main device camera
    """
    global camera
    # Initialize camera if it's not already initialized
    if camera is None:
        camera = cv2.VideoCapture(0)
    return StreamingResponse(generate_frames(camera), media_type="multipart/x-mixed-replace; boundary=frame")

@router.delete("/stop_video_feed")
async def stop_video_feed():
    """
    Stops camera from sending video feed
    """
    global camera
    if camera:
        camera.release()  # Release the camera
        camera = None  # Set camera to None after release
        return "Stopped streaming"
    else:
        return "No camera is currently streaming"