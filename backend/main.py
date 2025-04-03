from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware 
from tortoise.contrib.fastapi import register_tortoise
from config import tortoise_settings

from routes import food
from routes import stream

app = FastAPI(
    title = "Food Nutrition App",
    description = "This is the documentation for the food nutrition app",
    version = "1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True, 
    allow_methods=["*"], 
    allow_headers=["*"] 
)

BASE_PREFIX = "/api/v1"

app.include_router(food.router, prefix=BASE_PREFIX + "/food")
app.include_router(stream.router, prefix=BASE_PREFIX + "/stream")

register_tortoise(
    app,
    config={
        "connections": {"default": tortoise_settings.db_connection},
        "apps": {
            "models": {
                "models": ["models"],
                "default_connection": "default",
            }
        },
    },
    # This will create the DB tables on startup (useful for development)
    generate_schemas=True,
    add_exception_handlers=True,
)
