import secrets
import uuid
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from app.mock_kyc.config import (
    MOCK_AADHAAR_ENABLED,
    MOCK_AADHAAR_MAX_ATTEMPTS,
    MOCK_AADHAAR_NUMBER,
    MOCK_AADHAAR_OTP,
    MOCK_AADHAAR_TTL_SECONDS,
)
from app.mock_kyc.database import get_db
from app.mock_kyc.models import MockAadhaarAttempt, MockKycProfile
from app.mock_kyc.schemas import (
    AadhaarValidationRequest,
    AadhaarVerifiedResponse,
    GenerateOtpRequest,
    GenerateOtpResponse,
    MockProfileResponse,
    SubmitOtpRequest,
)
from app.mock_kyc.service import (
    aadhaar_fingerprint,
    complete_mock_validation,
)

router = APIRouter(
    prefix="/api/v1",
    tags=["Mock Aadhaar KYC"],
)


def ensure_mock_mode() -> None:
    """Prevent accidental use when mock mode is disabled."""
    if not MOCK_AADHAAR_ENABLED:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Mock Aadhaar verification is disabled.",
        )


# ---------------------------------------------------------------------
# API 1: Generate a mock Aadhaar OTP session
# POST /api/v1/aadhaar-v2/generate-otp
# ---------------------------------------------------------------------
@router.post(
    "/aadhaar-v2/generate-otp",
    response_model=GenerateOtpResponse,
)
def generate_otp(
    request: GenerateOtpRequest,
    db: Session = Depends(get_db),
):
    ensure_mock_mode()

    # Only the configured fictional test number is accepted.
    if not secrets.compare_digest(
        request.id_number,
        MOCK_AADHAAR_NUMBER,
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This number is not configured for mock testing.",
        )

    now = datetime.now(timezone.utc)

    attempt = MockAadhaarAttempt(
        client_id=str(uuid.uuid4()),
        aadhaar_fingerprint=aadhaar_fingerprint(request.id_number),
        status="pending",
        failed_attempts=0,
        created_at=now,
        expires_at=now + timedelta(
            seconds=MOCK_AADHAAR_TTL_SECONDS
        ),
    )

    try:
        db.add(attempt)
        db.commit()
        db.refresh(attempt)
    except SQLAlchemyError:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Could not create the mock verification session.",
        )

    # The actual fixed OTP is not returned by this endpoint.
    return GenerateOtpResponse(
        success=True,
        message=(
            "Mock OTP session created. "
            "Use the configured local test OTP."
        ),
        client_id=attempt.client_id,
        expires_in_seconds=MOCK_AADHAAR_TTL_SECONDS,
    )


# ---------------------------------------------------------------------
# API 2: Submit mock OTP
# POST /api/v1/aadhaar-v2/submit-otp
#
# If OTP is valid, the mock validation and profile creation run
# automatically in this same backend request.
# ---------------------------------------------------------------------
@router.post(
    "/aadhaar-v2/submit-otp",
    response_model=AadhaarVerifiedResponse,
)
def submit_otp(
    request: SubmitOtpRequest,
    db: Session = Depends(get_db),
):
    ensure_mock_mode()

    attempt = (
        db.query(MockAadhaarAttempt)
        .filter(
            MockAadhaarAttempt.client_id == request.client_id
        )
        .with_for_update()
        .first()
    )

    if attempt is None:
        raise HTTPException(
            status_code=404,
            detail="Verification session not found.",
        )

    if attempt.status == "locked":
        raise HTTPException(
            status_code=429,
            detail="Too many incorrect OTP attempts.",
        )

    if attempt.status == "expired":
        raise HTTPException(
            status_code=410,
            detail="Verification session has expired.",
        )

    # Do not accept another OTP submission for a completed attempt.
    if attempt.status != "pending":
        raise HTTPException(
            status_code=409,
            detail="This verification session is already complete.",
        )

    now = datetime.now(timezone.utc)

    if now >= attempt.expires_at:
        attempt.status = "expired"
        db.commit()

        raise HTTPException(
            status_code=410,
            detail="Verification session has expired.",
        )

    # Compare in constant time.
    if not secrets.compare_digest(request.otp, MOCK_AADHAAR_OTP):
        attempt.failed_attempts += 1

        if attempt.failed_attempts >= MOCK_AADHAAR_MAX_ATTEMPTS:
            attempt.status = "locked"

        db.commit()

        raise HTTPException(
            status_code=400,
            detail="Incorrect test OTP.",
        )

    try:
        # Stage 1: OTP is confirmed.
        attempt.status = "otp_verified"
        attempt.otp_verified_at = now

        # Stage 2: Automatically simulate Aadhaar validation.
        profile = complete_mock_validation(db, attempt)

        # Stage 3: Store verification status and the demo profile.
        db.commit()
        db.refresh(profile)

        return AadhaarVerifiedResponse(
            success=True,
            message=(
                "Mock OTP verified and fictional profile created."
            ),
            status="verified",
            profile=MockProfileResponse.model_validate(profile),
        )

    except HTTPException:
        db.rollback()
        raise

    except SQLAlchemyError:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Could not save the mock KYC profile.",
        )


# ---------------------------------------------------------------------
# API 3: Mock Aadhaar validation
# POST /api/v1/aadhaar/aadhaar-validation
#
# Available for direct testing and retry. During the normal flow,
# submit_otp calls the same validation service automatically.
# ---------------------------------------------------------------------
@router.post(
    "/aadhaar/aadhaar-validation",
    response_model=AadhaarVerifiedResponse,
)
def validate_aadhaar(
    request: AadhaarValidationRequest,
    db: Session = Depends(get_db),
):
    ensure_mock_mode()

    attempt = (
        db.query(MockAadhaarAttempt)
        .filter(
            MockAadhaarAttempt.client_id == request.client_id
        )
        .first()
    )

    if attempt is None:
        raise HTTPException(
            status_code=404,
            detail="Verification session not found.",
        )

    submitted_fingerprint = aadhaar_fingerprint(
        request.id_number
    )

    if not secrets.compare_digest(
        submitted_fingerprint,
        attempt.aadhaar_fingerprint,
    ):
        raise HTTPException(
            status_code=400,
            detail="Aadhaar number does not match this session.",
        )

    # This function refuses validation if the OTP was not verified.
    try:
        profile = complete_mock_validation(db, attempt)
        db.commit()
        db.refresh(profile)

        return AadhaarVerifiedResponse(
            success=True,
            message="Mock Aadhaar validation completed.",
            status="verified",
            profile=MockProfileResponse.model_validate(profile),
        )

    except HTTPException:
        db.rollback()
        raise

    except SQLAlchemyError:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Could not save the mock validation result.",
        )