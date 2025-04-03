from fastapi import APIRouter, Query
from typing import List
from routes.stream import capture_frame
from pydantic import BaseModel
from models.nutrition import NutritionModel
import numpy as np
from services.food_classifier.food_classifier import classify_food


router = APIRouter(
    tags=["Nutritional Information"]
)

class NutritionCreate(BaseModel):
    food: str
    amount_g: float
    calories: float
    total_fat_g: float
    cholestrol_mg: float
    sodium_mg: float
    carbohydrates_g: float
    protein_g: float
    sugar_g: float

@router.get("/food_classification")
async def get_food_classification():
    frame = capture_frame()
    
    # Check if the frame is None, which indicates a problem
    if frame is None:
        return {"error": "Failed to capture frame"}
    
    # Send the frame to the machine learning model for prediction
    model_output = classify_food(frame)
    print(model_output)
    food_item = await NutritionModel.filter(food__icontains=model_output).first()
    return {"food_info": food_item}

@router.get("/search_food", response_model=List[str])
async def search_food(q: str = Query(..., min_length=1, description="Query string to search food names")):
    """Returns a list of food names that contain the query string."""
    q = q.lower()
    foods = await NutritionModel.filter(food__icontains=q).values_list("food", flat=True)
    return foods

@router.post("/create_nutritional_info")
async def create_nutritional_info(nutrition: NutritionCreate):
    new_nutrition = await NutritionModel.create(food=nutrition.food,
                                            amount_g=nutrition.amount_g, 
                                            calories=nutrition.calories,
                                            total_fat_g=nutrition.total_fat_g, 
                                            cholestrol_mg=nutrition.cholestrol_mg,
                                            sodium_mg=nutrition.sodium_mg,
                                            carbohydrates_g=nutrition.carbohydrates_g, 
                                            protein_g=nutrition.protein_g, 
                                            sugar_g=nutrition.sugar_g )
    return {"id": new_nutrition.id, 
            "food": new_nutrition.food,
            "amount_g": new_nutrition.amount_g,
            "calories": new_nutrition.calories,
            "total_fat_g": new_nutrition.total_fat_g,
            "cholestrol_mg": new_nutrition.cholestrol_mg,
            "sodium_mg": new_nutrition.sodium_mg,
            "carbohydrates_g": new_nutrition.carbohydrates_g,
            "protein_g": new_nutrition.protein_g,
            "sugar_g": new_nutrition.sugar_g}



