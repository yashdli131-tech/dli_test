import hashlib
import hmac
from datetime import date, datetime, timezone

from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.mock_kyc.config import MOCK_AADHAAR_HASH_KEY
from app.mock_kyc.models import MockAadhaarAttempt, MockKycProfile


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def aadhaar_fingerprint(id_number: str) -> str:
    """
    Create a keyed fingerprint so the original test number
    does not need to be stored in PostgreSQL.
    """
    return hmac.new(
        MOCK_AADHAAR_HASH_KEY.encode("utf-8"),
        id_number.encode("utf-8"),
        hashlib.sha256,
    ).hexdigest()


def complete_mock_validation(
    db: Session,
    attempt: MockAadhaarAttempt,
) -> MockKycProfile:
    """
    Simulate the provider's Aadhaar validation response.

    This function may run only after successful OTP verification.
    The resulting profile is entirely fictional.
    """
    if attempt.status not in ("otp_verified", "verified"):
        raise HTTPException(
            status_code=409,
            detail="Verify the OTP before validating Aadhaar.",
        )

    # Avoid creating duplicate profiles for the same attempt.
    existing_profile = (
        db.query(MockKycProfile)
        .filter(MockKycProfile.attempt_id == attempt.id)
        .first()
    )

    if existing_profile:
        attempt.status = "verified"

        if attempt.verified_at is None:
            attempt.verified_at = utc_now()

        return existing_profile

    # Fictional data for local UI and API testing only.
    profile = MockKycProfile(
    attempt_id=attempt.id,
    full_name="Yash Patel",
    date_of_birth=date(2004, 9, 19),
    gender="Male",
    address="123 Dholka Road, Saroda-Dholka",
    city="Ahmedabad",
    state="Gujarat",
    pincode="382225",
)

    db.add(profile)

    # Mark complete only after creating the demo profile.
    attempt.status = "verified"
    attempt.verified_at = utc_now()

    db.flush()

    return profile