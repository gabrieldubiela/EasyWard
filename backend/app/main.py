import sentry_sdk
import structlog
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.exceptions import RequestValidationError
from app.modules.health.router import router as health_router

from app.core.config import settings
from app.core.middleware import setup_middlewares
from app.core.exceptions import (
    NotFoundError,
    PermissionDeniedError,
    BusinessRuleError,
    UnauthorizedError,
    ConflictError,
)
from app.core.exception_handlers import (
    not_found_handler,
    permission_denied_handler,
    business_rule_handler,
    unauthorized_handler,
    conflict_handler,
    validation_exception_handler,
    generic_exception_handler,
)

if settings.SENTRY_DSN:
    sentry_sdk.init(
        dsn=settings.SENTRY_DSN,
        environment=settings.APP_ENV,
        traces_sample_rate=0.2,
    )

@asynccontextmanager
async def lifespan(app: FastAPI):
    structlog.get_logger().info("app.starting", environment=settings.APP_ENV)
    yield
    structlog.get_logger().info("app.shutdown")

app = FastAPI(
    title="EasyWard API",
    version="0.1.0",
    docs_url="/docs" if settings.is_development else None,
    redoc_url="/redoc" if settings.is_development else None,
    lifespan=lifespan,
)

setup_middlewares(app)

app.add_exception_handler(NotFoundError, not_found_handler)
app.add_exception_handler(PermissionDeniedError, permission_denied_handler)
app.add_exception_handler(BusinessRuleError, business_rule_handler)
app.add_exception_handler(UnauthorizedError, unauthorized_handler)
app.add_exception_handler(ConflictError, conflict_handler)
app.add_exception_handler(RequestValidationError, validation_exception_handler)
app.add_exception_handler(Exception, generic_exception_handler)

app.include_router(health_router, prefix="/api/v1")