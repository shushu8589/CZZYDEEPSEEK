from typing import Any


def success_response(message: str = '操作成功', data: Any = None, code: int = 200) -> dict[str, Any]:
    return {
        'success': True,
        'message': message,
        'data': data if data is not None else {},
        'code': code,
    }


def error_response(message: str = '操作失败', code: int = 500, data: Any = None) -> dict[str, Any]:
    return {
        'success': False,
        'message': message,
        'data': data if data is not None else {},
        'code': code,
    }
