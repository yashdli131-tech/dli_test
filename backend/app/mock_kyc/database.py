import os
from collections.abc import Generator

from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker

load_dotenv()

DATABASE_URL = (
    os.getenv("MOCK_KYC_DATABASE_URL")
    or os.getenv("DATABASE_URL")
)

if not DATABASE_URL:
    raise RuntimeError(
        "Set MOCK_KYC_DATABASE_URL in backend/.env"
    )

# PostgreSQL connection
engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
)

SessionLocal = sessionmaker(
    bind=engine,
    autoflush=False,
    expire_on_commit=False,
)


class Base(DeclarativeBase):
    """Base class for the mock KYC database tables."""
    pass


def get_db() -> Generator[Session, None, None]:
    """Provide one database session per API request."""
    db = SessionLocal()

    try:
        yield db
    finally:
        db.close()