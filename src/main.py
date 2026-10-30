import logging
import json
import time

from datetime import datetime, timezone

from fastapi import FastAPI, Depends, HTTPException, Request
from sqlalchemy.orm import Session
from sqlalchemy import text

from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from fastapi.responses import Response

from database import engine, get_db, Base
from models import Item
from schemas import ItemCreate, ItemResponse


# Logging
class JSONFormatter(logging.Formatter):
    def format(self, record):
        return json.dumps({
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "level": record.levelname,
            "message": record.getMessage()
        })


logger = logging.getLogger("apex-api")
logger.setLevel(logging.INFO)

handler = logging.StreamHandler()
handler.setFormatter(JSONFormatter())
logger.addHandler(handler)


# Metrics
REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["method", "status"]
)

REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "HTTP request duration"
)


app = FastAPI(title="Apex Operations API")


# Create database tables
@app.on_event("startup")
def startup():
    Base.metadata.create_all(bind=engine)
    logger.info("Application started")


# Request monitoring
@app.middleware("http")
async def monitor_requests(request: Request, call_next):

    start = time.time()

    try:
        response = await call_next(request)

        duration = time.time() - start

        if request.url.path != "/metrics":
            REQUEST_COUNT.labels(
                method=request.method,
                status=str(response.status_code)
            ).inc()

            REQUEST_LATENCY.observe(duration)

        logger.info(
            f"{request.method} {request.url.path} "
            f"status={response.status_code} duration={duration:.4f}"
        )

        return response

    except Exception:
        logger.exception("Request failed")
        raise


# Health check
@app.get("/health")
def health():
    return {"status": "ok"}


# Readiness check
@app.get("/ready")
def readiness(db: Session = Depends(get_db)):

    try:
        db.execute(text("SELECT 1"))
        return {"status": "ready", "database": "connected"}

    except Exception:
        raise HTTPException(
            status_code=503,
            detail="Database unavailable"
        )


# Create item
@app.post("/items", response_model=ItemResponse, status_code=201)
def create_item(item: ItemCreate, db: Session = Depends(get_db)):

    new_item = Item(
        name=item.name,
        description=item.description
    )

    db.add(new_item)
    db.commit()
    db.refresh(new_item)

    logger.info(f"Created item id={new_item.id}")

    return new_item


# Get all items
@app.get("/items", response_model=list[ItemResponse])
def get_items(db: Session = Depends(get_db)):

    return db.query(Item).all()


# Get item by ID
@app.get("/items/{item_id}", response_model=ItemResponse)
def get_item(item_id: int, db: Session = Depends(get_db)):

    item = db.query(Item).filter(Item.id == item_id).first()

    if not item:
        raise HTTPException(
            status_code=404,
            detail="Item not found"
        )

    return item


# Prometheus metrics
@app.get("/metrics")
def metrics():

    return Response(
        content=generate_latest(),
        media_type=CONTENT_TYPE_LATEST
    )


# Run application
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)