# app/main.py
from fastapi import FastAPI

app = FastAPI()

@app.get("/events")
def read_events():
    return [
        {"title": "Dummy event 1", "date": "2025-06-01", "link": "https://afisha.timepad.ru/event/3344601"},
        {"title": "Dummy event 2", "date": "2025-06-10", "link": "https://afisha.timepad.ru/event/3324576"},
    ]
