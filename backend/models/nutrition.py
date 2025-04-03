from tortoise.models import Model 
from tortoise import fields

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
