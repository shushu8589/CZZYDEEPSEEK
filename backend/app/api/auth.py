from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.core.database import get_key_db

router = APIRouter(prefix='/auth', tags=['auth'])


@router.post('/login')
def login(payload: dict, request: Request, db: Session = Depends(get_key_db)) -> dict:
    username = (payload.get('username') or '').strip()
    password = payload.get('password') or ''

    if not username:
        raise HTTPException(status_code=400, detail='请输入账号')
    if not password:
        raise HTTPException(status_code=400, detail='请输入密码')

    try:
        sql = text(
            """
            SELECT TOP 1
                KEY_id,
                KEY_name,
                KEY_password,
                [显示项目] AS display_projects,
                Person,
                KEY_LastTime,
                Login_History,
                KEY_IP
            FROM dbo.LEEToolsKey
            WHERE KEY_name = :username
            """
        )
        row = db.execute(sql, {'username': username}).mappings().first()
    except Exception as exc:
        raise HTTPException(status_code=500, detail='数据库连接失败，请检查服务器或网络') from exc

    if not row or row['KEY_password'] != password:
        raise HTTPException(status_code=401, detail='账号或密码错误')

    ip = request.client.host if request.client else ''
    now = datetime.now()
    history_line = f"{now.strftime('%Y-%m-%d %H:%M:%S')}@{ip}"
    old_history = row.get('Login_History') or ''
    new_history = (f"{history_line}\n{old_history}")[:4000]

    db.execute(
        text(
            """
            UPDATE dbo.LEEToolsKey
            SET KEY_LastTime = :last_time,
                KEY_IP = :ip,
                Login_History = :history
            WHERE KEY_id = :key_id
            """
        ),
        {
            'last_time': now,
            'ip': ip,
            'history': new_history,
            'key_id': row['KEY_id'],
        },
    )
    db.commit()

    user = {
        'id': row['KEY_id'],
        'username': row['KEY_name'],
        'name': row['Person'],
        'displayProjects': row.get('display_projects') or '',
        'lastLoginTime': row.get('KEY_LastTime').strftime('%Y-%m-%d %H:%M:%S') if row.get('KEY_LastTime') else '',
        'lastLoginIp': row.get('KEY_IP') or '',
        'currentLoginTime': now.strftime('%Y-%m-%d %H:%M:%S'),
        'currentLoginIp': ip,
    }

    return {
        'success': True,
        'message': '登录成功，正在进入系统……',
        'data': {
            'token': f"local-{row['KEY_id']}",
            'user': user,
        },
        'code': 200,
    }
