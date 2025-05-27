# app/main.py
from fastapi import FastAPI

app = FastAPI()

@app.get("/events")
def read_events():
    return [
        {"title": "Dummy event 1", "date": "2025-06-01", "link": "https://example.com"},
        {"title": "Dummy event 2", "date": "2025-06-10", "link": "https://example.com"},
    ]
