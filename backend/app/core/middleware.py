import time
import structlog
from fastapi import FastAPI, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from slowapi import Limiter
from slowapi.util import get_remote_address
from slowapi.middleware import SlowAPIMiddleware
from app.core.config import settings

log = structlog.get_logger()
limiter = Limiter(key_func=get_remote_address)

def setup_middlewares(app: FastAPI) -> None:
    # 1. CORS
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins_list,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # 2. Rate limiting
    app.state.limiter = limiter
    app.add_middleware(SlowAPIMiddleware)

    # 3. Headers de segurança + log de requisições
    @app.middleware("http")
    async def security_and_logging_middleware(request: Request, call_next) -> Response:
        # registra o tempo de início
        start_time = time.time()
        # chama o próximo middleware/endpoint
        response = await call_next(request)
        # calcula a duração
        duration = time.time() - start_time
        # adiciona headers de segurança na resposta
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
        # registra o log
        log.info(
            "http.request",
            method=request.method,
            path=request.url.path,
            status_code=response.status_code,
            duration_ms=round(duration * 1000),
        )
        # retorna a resposta
        return response
        


