from fastapi import FastAPI, HTTPException, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse

from app.core.response import error_response


def register_exception_handlers(app: FastAPI) -> None:
    @app.exception_handler(HTTPException)
    async def http_exception_handler(_: Request, exc: HTTPException) -> JSONResponse:
        return JSONResponse(status_code=exc.status_code, content=error_response(message=str(exc.detail), code=exc.status_code))

    @app.exception_handler(RequestValidationError)
    async def request_validation_exception_handler(_: Request, exc: RequestValidationError) -> JSONResponse:
        return JSONResponse(
            status_code=422,
            content=error_response(message='请求参数校验失败', code=422, data={'errors': exc.errors()}),
        )

    @app.exception_handler(Exception)
    async def generic_exception_handler(_: Request, exc: Exception) -> JSONResponse:
        return JSONResponse(status_code=500, content=error_response(message=f'服务器内部错误: {exc}', code=500))
