from fastapi import Request
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError

from app.core.exceptions import (
    NotFoundError,
    PermissionDeniedError,
    BusinessRuleError,
    UnauthorizedError,
    ConflictError,
)
from app.core.response import error_response

import structlog

async def not_found_handler(request: Request, exc: NotFoundError):
    return JSONResponse(
        status_code=404,
        content=error_response(exc.message),
    )

async def permission_denied_handler(request: Request, exc: PermissionDeniedError):
    return JSONResponse(
        status_code=403,
        content=error_response(exc.message),
    )

async def business_rule_handler(request: Request, exc: BusinessRuleError):
    return JSONResponse(
        status_code=400,
        content=error_response(exc.message),
    )

async def unauthorized_handler(request: Request, exc: UnauthorizedError):
    return JSONResponse(
        status_code=401,
        content=error_response(exc.message),
    )

async def conflict_handler(request: Request, exc: ConflictError):
    return JSONResponse(
        status_code=409,
        content=error_response(exc.message),
    )
    
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    errors = [
        {"field": ".".join(str(loc) for loc in err["loc"]), "message": err["msg"]}
        for err in exc.errors()
    ]
    return JSONResponse(
        status_code=422,
        content=error_response("Erro de validação.", errors=errors),
    )
    
async def generic_exception_handler(request: Request, exc: Exception):
    # registra o erro com structlog e retorna 500
    structlog.get_logger().error("Erro inesperado", exc_info=True)
    return JSONResponse(
        status_code=500,
        content=error_response("Erro interno do servidor."),
    )
