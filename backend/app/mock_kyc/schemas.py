from datetime import date, datetime

from pydantic import BaseModel, ConfigDict, Field


class GenerateOtpRequest(BaseModel):
    id_number: str = Field(
        pattern=r"^\d{12}$",
        description="Configured dummy Aadhaar number only",
    )


class SubmitOtpRequest(BaseModel):
    client_id: str = Field(
        min_length=36,
        max_length=36,
    )

    otp: str = Field(
        pattern=r"^\d{6}$",
    )


class AadhaarValidationRequest(BaseModel):
    client_id: str = Field(
        min_length=36,
        max_length=36,
    )

    id_number: str = Field(
        pattern=r"^\d{12}$",
    )


class GenerateOtpResponse(BaseModel):
    success: bool
    message: str
    client_id: str
    expires_in_seconds: int
    mode: str = "mock"


class MockProfileResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    attempt_id: int
    full_name: str
    date_of_birth: date
    gender: str
    address: str
    city: str
    state: str
    pincode: str
    created_at: datetime


class AadhaarVerifiedResponse(BaseModel):
    success: bool
    message: str
    status: str
    profile: MockProfileResponse