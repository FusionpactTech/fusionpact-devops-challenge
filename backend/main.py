from fastapi import FastAPI
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from fastapi.responses import Response
import time

app = FastAPI()

REQUEST_COUNT = Counter("request_count", "Total number of requests")
REQUEST_LATENCY = Histogram("request_latency_seconds", "Latency of requests in seconds")

@app.get("/")
def read_root():
    start_time = time.time()
    REQUEST_COUNT.inc()
    time.sleep(0.2)  # simulate response time
    REQUEST_LATENCY.observe(time.time() - start_time)
    return {"message": "Backend running successfully with Prometheus metrics!"}

@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)

