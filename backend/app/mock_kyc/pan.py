import hashlib
import hmac
import re
from datetime import date, datetime, timezone

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, field_validator
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from app.mock_kyc.config import (
    MOCK_AADHAAR_ENABLED,
    MOCK_AADHAAR_HASH_KEY,
    MOCK_PAN_PERSONAL,
    MOCK_PAN_ORGANIZATION,
)
from app.mock_kyc.database import get_db
from app.mock_kyc.models import MockPanValidation


# ============================================================
# ROUTER
# ============================================================

router = APIRouter(
    prefix="/api/v1/pan",
    tags=["Mock PAN Validation"],
)


# ============================================================
# PAN FORMAT VALIDATION
# ============================================================

# PAN format:
# First 3 characters: letters
# 4th character: holder type
# 5th character: letter
# Next 4 characters: digits
# Last character: letter

PAN_PATTERN = re.compile(
    r"^[A-Z]{3}[PCHFTABLJG][A-Z][0-9]{4}[A-Z]$"
)


# ============================================================
# PAN HOLDER TYPES
# ============================================================

PAN_HOLDER_TYPES = {
    "P": ("personal", "Individual", "Mock Individual"),
    "C": ("organization", "Company", "Mock Company"),
    "H": (
        "family_huf",
        "Hindu Undivided Family (HUF)",
        "Mock HUF",
    ),
    "F": ("organization", "Firm / LLP", "Mock Firm"),
    "A": (
        "organization",
        "Association of Persons (AOP)",
        "Mock AOP",
    ),
    "T": ("organization", "Trust", "Mock Trust"),
    "B": (
        "organization",
        "Body of Individuals (BOI)",
        "Mock BOI",
    ),
    "G": (
        "organization",
        "Government Agency",
        "Mock Government Agency",
    ),
    "J": (
        "organization",
        "Artificial Juridical Person",
        "Mock Juridical Entity",
    ),
    "L": (
        "organization",
        "Local Authority",
        "Mock Local Authority",
    ),
}


# ============================================================
# REQUEST SCHEMA
# ============================================================

class PanValidationRequest(BaseModel):
    id_number: str

    @field_validator("id_number", mode="before")
    @classmethod
    def normalize_pan(cls, value):
        if not isinstance(value, str):
            raise ValueError("PAN must be text.")

        pan = value.strip().upper()

        if not PAN_PATTERN.fullmatch(pan):
            raise ValueError(
                "Enter a valid 10-character PAN format."
            )

        return pan


# ============================================================
# RESPONSE SCHEMA
# ============================================================

class PanValidationResponse(BaseModel):
    success: bool
    mode: str
    message: str
    pan_masked: str
    holder_category: str
    holder_type: str
    holder_name: str
    date_of_birth_or_incorporation: date
    registered_address: str
    city: str
    state: str
    pincode: str
    verification_status: str
    created_at: datetime


# ============================================================
# PAN FINGERPRINT
# ============================================================

def pan_fingerprint(pan: str) -> str:
    """
    Create a keyed fingerprint for PAN matching.

    The original PAN is not stored in the database.
    """

    return hmac.new(
        MOCK_AADHAAR_HASH_KEY.encode("utf-8"),
        pan.encode("utf-8"),
        hashlib.sha256,
    ).hexdigest()


# ============================================================
# RESPONSE BUILDER
# ============================================================

def build_response(
    record: MockPanValidation,
) -> PanValidationResponse:

    return PanValidationResponse(
        success=True,
        mode="mock",
        message=(
            "Fictional PAN details returned. "
            "No real PAN database was checked."
        ),
        pan_masked=record.pan_masked,
        holder_category=record.holder_category,
        holder_type=record.holder_type,
        holder_name=(
            "Yash Patel"
            if record.holder_category == "personal"
            else "DLI Demo Private Limited"
            if record.holder_type == "Company"
            else record.holder_name
        ),
        date_of_birth_or_incorporation=(
            date(2004, 9, 19)
            if record.holder_category == "personal"
            else date(2015, 4, 1)
            if record.holder_type == "Company"
            else record.date_of_birth_or_incorporation
        ),
        registered_address=record.registered_address,
        city=record.city,
        state=record.state,
        pincode=record.pincode,
        verification_status=record.verification_status,
        created_at=record.created_at,
    )


# ============================================================
# MOCK PAN VALIDATION API
# ============================================================

@router.post(
    "/pan-validation",
    response_model=PanValidationResponse,
)
def validate_pan(
    request: PanValidationRequest,
    db: Session = Depends(get_db),
):
    """
    Local mock PAN API.

    Endpoint:
    POST /api/v1/pan/pan-validation

    Accepts only the two configured dummy PANs.
    Returns and stores fictional profile details.
    """

    # --------------------------------------------------------
    # 1. Check whether mock mode is enabled
    # --------------------------------------------------------

    if not MOCK_AADHAAR_ENABLED:
        raise HTTPException(
            status_code=503,
            detail="Mock KYC mode is disabled.",
        )

    pan = request.id_number

    # --------------------------------------------------------
    # 2. Accept only configured dummy PAN numbers
    # --------------------------------------------------------

    allowed_dummy_pans = {
        MOCK_PAN_PERSONAL.strip().upper(),
        MOCK_PAN_ORGANIZATION.strip().upper(),
    }

    if pan not in allowed_dummy_pans:
        raise HTTPException(
            status_code=400,
            detail=(
                "PAN is not configured for mock testing. "
                "Use the configured personal or organization "
                "dummy PAN."
            ),
        )

    # --------------------------------------------------------
    # 3. Identify PAN holder type
    # --------------------------------------------------------

    category, holder_type, name_prefix = PAN_HOLDER_TYPES[
        pan[3]
    ]

    fingerprint = pan_fingerprint(pan)

    # --------------------------------------------------------
    # 4. Return the existing record if already validated
    # --------------------------------------------------------

    existing = (
        db.query(MockPanValidation)
        .filter(
            MockPanValidation.pan_fingerprint == fingerprint
        )
        .first()
    )

    if existing is not None:
        return build_response(existing)

    # --------------------------------------------------------
    # 5. Generate stable fictional details
    # --------------------------------------------------------

    digest = hashlib.sha256(
        pan.encode("utf-8")
    ).hexdigest()

    suffix = 100 + int(digest[:8], 16) % 900

    if category == "personal":
        holder_name = f"{name_prefix} {suffix}"
        year = 1980 + int(digest[8:12], 16) % 25
    elif category == "family_huf":
        holder_name = f"{name_prefix} {suffix}"
        year = 2000 + int(digest[8:12], 16) % 20
    else:
        holder_name = f"{name_prefix} {suffix}"
        year = 2000 + int(digest[8:12], 16) % 20

    month = 1 + int(digest[12:14], 16) % 12
    day = 1 + int(digest[14:16], 16) % 28

    demo_date = date(year, month, day)

    demo_locations = [
        ("Demo City", "Demo State", "000000"),
        ("Sample City", "Sample State", "111111"),
        ("Test City", "Test State", "222222"),
    ]

    city, state, pincode = demo_locations[
        int(digest[16:18], 16) % len(demo_locations)
    ]

    # --------------------------------------------------------
    # 6. Create a fictional PAN validation record
    # --------------------------------------------------------

    record = MockPanValidation(
        pan_fingerprint=fingerprint,
        pan_masked=f"{pan[:3]}****{pan[-1]}",
        holder_category=category,
        holder_type=holder_type,
        holder_name=holder_name,
        date_of_birth_or_incorporation=demo_date,
        registered_address=(
            f"Fictional Demo Address {suffix}"
        ),
        city=city,
        state=state,
        pincode=pincode,
        verification_status="mock_success",
        created_at=datetime.now(timezone.utc),
    )

    # --------------------------------------------------------
    # 7. Save the record to PostgreSQL
    # --------------------------------------------------------

    try:
        db.add(record)
        db.commit()
        db.refresh(record)

        return build_response(record)

    except SQLAlchemyError:
        db.rollback()

        raise HTTPException(
            status_code=500,
            detail="Could not save the mock PAN response.",
        )