from tortoise.models import Model 
from tortoise import fields
import sqlite3

class NutritionModel(Model):
    id = fields.IntField(pk=True)
    food = fields.CharField(max_length=50)
    amount_g = fields.FloatField(max_length=10)
    calories = fields.FloatField(max_length=10)
    total_fat_g = fields.FloatField(max_length=10)
    cholestrol_mg = fields.FloatField(max_length=10)
    sodium_mg = fields.FloatField(max_length=10)
    carbohydrates_g = fields.FloatField(max_length=10)
    protein_g = fields.FloatField(max_length=10)
    sugar_g = fields.FloatField(max_length=10)

def get_food_from_db(food_name: str):
    """
    This function queries the SQLite database for a row matching the food_name.
    """
    conn = sqlite3.connect("db.sqlite3.db")  # Replace with the actual path to your database file
    cursor = conn.cursor()

    # Query to select a row where the food name matches the model's output
    cursor.execute("SELECT * FROM NutritionModel WHERE name = ?", (food_name,))
    result = cursor.fetchone()  # Fetch the first matching row

    conn.close()
    
    return result