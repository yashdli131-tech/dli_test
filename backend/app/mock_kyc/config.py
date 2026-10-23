import os
from dotenv import load_dotenv

# Load environment variables from backend/.env
load_dotenv()

MOCK_AADHAAR_ENABLED = (
    os.getenv("MOCK_AADHAAR_ENABLED", "false").lower() == "true"
)

MOCK_AADHAAR_NUMBER = os.getenv(
    "MOCK_AADHAAR_NUMBER",
    "999999999999",
)

MOCK_AADHAAR_OTP = os.getenv(
    "MOCK_AADHAAR_OTP",
    "123456",
)

MOCK_AADHAAR_TTL_SECONDS = int(
    os.getenv("MOCK_AADHAAR_TTL_SECONDS", "300")
)

MOCK_AADHAAR_MAX_ATTEMPTS = int(
    os.getenv("MOCK_AADHAAR_MAX_ATTEMPTS", "5")
)

MOCK_AADHAAR_HASH_KEY = os.getenv(
    "MOCK_AADHAAR_HASH_KEY",
    "local-only-change-this-secret",
)


# Pan
# Fixed dummy PAN values for local mock testing
MOCK_PAN_PERSONAL = os.getenv(
    "MOCK_PAN_PERSONAL",
    "ZZZPX1234P",
).strip().upper()

MOCK_PAN_ORGANIZATION = os.getenv(
    "MOCK_PAN_ORGANIZATION",
    "ZZZCX1234C",
).strip().upper()

