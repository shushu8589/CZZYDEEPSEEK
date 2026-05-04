from fastapi import APIRouter

from app.core.config import get_settings
from app.core.database import check_all_databases
from app.core.response import success_response

router = APIRouter(tags=['health'])
settings = get_settings()


@router.get('/health')
def health_check() -> dict:
    db_status = check_all_databases()
    database = 'connected' if all(db_status.values()) else 'disconnected'
    return success_response(
        message='服务正常',
        data={
            'app': settings.app_name,
            'database': database,
        },
    )


@router.get('/db/check')
def database_check() -> dict[str, bool]:
    return check_all_databases()
