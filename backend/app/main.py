from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.mock_kyc.database import Base, engine
from app.mock_kyc import models as mock_kyc_models  # Registers the SQLAlchemy models
from app.mock_kyc.router import router as mock_aadhaar_router
from app.mock_kyc.pan import router as mock_pan_router
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="DLI KYC Backend",
    description="DLI backend with local mock Aadhaar KYC",
    version="1.0.0",
)


app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],
    allow_methods=['*'],
    allow_headers=['*'],
)

@app.on_event("startup")
def create_mock_kyc_tables():
    # Create the mock KYC tables if they do not exist yet.
    # This does not replace or modify your existing tables.
    Base.metadata.create_all(bind=engine)


# Register all three local mock endpoints.
app.include_router(mock_aadhaar_router)
app.include_router(mock_pan_router)

@app.get("/")
def health_check():
    return {
        "success": True,
        "message": "DLI KYC backend is running",
        "aadhaar_mode": "mock",
    }

