from datetime import date, datetime, timezone

from sqlalchemy import (
    Date,
    DateTime,
    ForeignKey,
    Integer,
    String,
)
from sqlalchemy.orm import Mapped, mapped_column

from app.mock_kyc.database import Base


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


class MockAadhaarAttempt(Base):
    __tablename__ = "mock_aadhaar_attempts"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        index=True,
    )

    client_id: Mapped[str] = mapped_column(
        String(36),
        unique=True,
        index=True,
        nullable=False,
    )

    # HMAC fingerprint is used to match the configured test number.
    # It is not the original Aadhaar number.
    aadhaar_fingerprint: Mapped[str] = mapped_column(
        String(64),
        index=True,
        nullable=False,
    )

    status: Mapped[str] = mapped_column(
        String(30),
        default="pending",
        nullable=False,
    )

    failed_attempts: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=utc_now,
        nullable=False,
    )

    expires_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
    )

    otp_verified_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        nullable=True,
    )

    verified_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        nullable=True,
    )


class MockKycProfile(Base):
    __tablename__ = "mock_kyc_profiles"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        index=True,
    )

    # One mock profile for each completed verification attempt.
    attempt_id: Mapped[int] = mapped_column(
        ForeignKey("mock_aadhaar_attempts.id"),
        unique=True,
        nullable=False,
    )

    full_name: Mapped[str] = mapped_column(
        String(120),
        nullable=False,
    )

    date_of_birth: Mapped[date] = mapped_column(
        Date,
        nullable=False,
    )

    gender: Mapped[str] = mapped_column(
        String(30),
        nullable=False,
    )

    address: Mapped[str] = mapped_column(
        String(250),
        nullable=False,
    )

    city: Mapped[str] = mapped_column(
        String(80),
        nullable=False,
    )

    state: Mapped[str] = mapped_column(
        String(80),
        nullable=False,
    )

    pincode: Mapped[str] = mapped_column(
        String(10),
        nullable=False,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=utc_now,
        nullable=False,
    )





# for pan 
class MockPanValidation(Base):
    __tablename__ = "mock_pan_validations"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        index=True,
    )

    # Store only a keyed fingerprint, not the full PAN.
    pan_fingerprint: Mapped[str] = mapped_column(
        String(64),
        unique=True,
        index=True,
        nullable=False,
    )

    pan_masked: Mapped[str] = mapped_column(
        String(10),
        nullable=False,
    )

    holder_category: Mapped[str] = mapped_column(
        String(30),
        nullable=False,
    )

    holder_type: Mapped[str] = mapped_column(
        String(80),
        nullable=False,
    )

    holder_name: Mapped[str] = mapped_column(
        String(180),
        nullable=False,
    )

    date_of_birth_or_incorporation: Mapped[date] = mapped_column(
        Date,
        nullable=False,
    )

    registered_address: Mapped[str] = mapped_column(
        String(250),
        nullable=False,
    )

    city: Mapped[str] = mapped_column(
        String(80),
        nullable=False,
    )

    state: Mapped[str] = mapped_column(
        String(80),
        nullable=False,
    )

    pincode: Mapped[str] = mapped_column(
        String(10),
        nullable=False,
    )

    verification_status: Mapped[str] = mapped_column(
        String(30),
        default="mock_success",
        nullable=False,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=utc_now,
        nullable=False,
    )  