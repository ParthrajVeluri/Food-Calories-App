import os
import requests
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

# Load environment variables from a .env file if available.
load_dotenv()

app = FastAPI()

# Allow CORS from any origin (adjust origins as needed for production)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, list specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Retrieve the YouTube API key from an environment variable.
YOUTUBE_API_KEY = os.getenv("YOUTUBE_API_KEY")
if not YOUTUBE_API_KEY:
    print("Warning: YOUTUBE_API_KEY not set. Please set the API key via an environment variable or a .env file.")

@app.get("/search_youtube")
def search_youtube(dish_name: str):
    """
    Search YouTube for the given dish name and return the top video's title, thumbnail, and URL.
    
    Example:
        /search_youtube?dish_name=Sour+Cream+and+Onion+Chicken
    """
    if not dish_name:
        raise HTTPException(status_code=400, detail="Parameter 'dish_name' is required.")

    # Prepare request to YouTube Data API v3
    url = "https://www.googleapis.com/youtube/v3/search"
    params = {
        "part": "snippet",
        "q": dish_name,
        "key": YOUTUBE_API_KEY,
        "type": "video",
        "maxResults": 1  # Increase to 3 if you need more results.
    }
    response = requests.get(url, params=params)
    if response.status_code != 200:
        raise HTTPException(status_code=response.status_code, detail="Error fetching data from YouTube API.")
    
    data = response.json()
    items = data.get("items")
    if not items or len(items) == 0:
        return {"title": None, "thumbnail_url": None, "video_url": None}

    video = items[0]
    snippet = video.get("snippet", {})
    video_id = video.get("id", {}).get("videoId")
    if not video_id:
        return {"title": None, "thumbnail_url": None, "video_url": None}

    title = snippet.get("title")
    thumbnails = snippet.get("thumbnails", {})
    thumbnail_url = thumbnails.get("high", {}).get("url") or thumbnails.get("default", {}).get("url")
    video_url = f"https://www.youtube.com/watch?v={video_id}"

    result = {
        "title": title,
        "thumbnail_url": thumbnail_url,
        "video_url": video_url
    }

    return result

# To run the app, use: uvicorn main:app --reload
