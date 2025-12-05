@echo off
chcp 65001 >nul
echo ========================================
echo Запуск AI Competitor Insight Hub
echo ========================================
echo.

cd /d "%~dp0"

echo [1/5] Проверка зависимостей...
python --version >nul 2>&1
if errorlevel 1 (
    echo ОШИБКА: Python не найден!
    pause
    exit /b 1
)

node --version >nul 2>&1
if errorlevel 1 (
    echo ОШИБКА: Node.js не найден!
    pause
    exit /b 1
)

echo [2/5] Запуск инфраструктуры (PostgreSQL и Redis)...
docker-compose up -d postgres redis 2>nul
if errorlevel 1 (
    echo ПРЕДУПРЕЖДЕНИЕ: Docker не найден или не запущен.
    echo Убедитесь, что PostgreSQL и Redis запущены локально.
    echo.
    timeout /t 3 >nul
) else (
    echo Инфраструктура запущена. Ожидание готовности...
    timeout /t 5 >nul
)

echo [3/5] Применение миграций базы данных...
cd backend
if exist .env (
    echo Файл .env найден.
) else (
    echo Создание .env файла из env.example...
    copy env.example .env >nul 2>&1
)

python -m pip show poetry >nul 2>&1
if errorlevel 1 (
    echo Poetry не найден. Используем pip...
    python -m pip install -q -r requirements.txt
    python -m alembic upgrade head
) else (
    echo Poetry найден. Применяем миграции...
    poetry run alembic upgrade head
)
cd ..

echo [4/5] Запуск Backend сервера...
start "Backend API" cmd /k "cd /d %~dp0backend && python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000"

echo [5/5] Запуск Frontend сервера...
cd frontend
if not exist .env.local (
    echo Создание .env.local файла...
    copy env.example .env.local >nul 2>&1
    echo VITE_API_URL=http://localhost:8000 > .env.local
)

if exist package-lock.json (
    echo Зависимости уже установлены.
) else (
    echo Установка зависимостей frontend...
    call npm install
)

start "Frontend Dev Server" cmd /k "cd /d %~dp0frontend && npm run dev"
cd ..

echo.
echo ========================================
echo Проект запущен!
echo ========================================
echo.
echo Backend API: http://localhost:8000
echo API Docs: http://localhost:8000/docs
echo Frontend: http://localhost:5173
echo.
echo Нажмите любую клавишу для выхода...
pause >nul


