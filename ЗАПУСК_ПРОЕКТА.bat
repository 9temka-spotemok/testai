@echo off
chcp 65001 >nul
title AI Competitor Insight Hub - Запуск проекта
color 0A

echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║   AI Competitor Insight Hub - Запуск проекта            ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

cd /d "%~dp0"

REM Проверка Python
echo [✓] Проверка Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo [✗] ОШИБКА: Python не найден!
    echo     Установите Python 3.11+ с https://www.python.org/
    pause
    exit /b 1
)
python --version

REM Проверка Node.js
echo [✓] Проверка Node.js...
node --version >nul 2>&1
if errorlevel 1 (
    echo [✗] ОШИБКА: Node.js не найден!
    echo     Установите Node.js 20 LTS с https://nodejs.org/
    pause
    exit /b 1
)
node --version
echo.

REM Запуск инфраструктуры
echo [1/6] Запуск инфраструктуры (PostgreSQL и Redis)...
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo [⚠] Docker не найден. Пропускаем запуск инфраструктуры.
    echo     Убедитесь, что PostgreSQL и Redis запущены локально.
) else (
    echo [✓] Docker найден. Запускаем PostgreSQL и Redis...
    docker-compose up -d postgres redis
    if errorlevel 1 (
        echo [⚠] Не удалось запустить через Docker. Продолжаем...
    ) else (
        echo [✓] Инфраструктура запущена. Ожидание готовности (10 сек)...
        timeout /t 10 >nul
    )
)
echo.

REM Настройка Backend
echo [2/6] Настройка Backend...
cd backend

if not exist .env (
    echo [✓] Создание .env файла из env.example...
    copy env.example .env >nul 2>&1
    if errorlevel 1 (
        echo [✗] Не удалось создать .env файл
    ) else (
        echo [✓] Файл .env создан
    )
) else (
    echo [✓] Файл .env уже существует
)

echo [✓] Установка зависимостей Python...
python -m pip install -q -r requirements.txt
if errorlevel 1 (
    echo [✗] Ошибка при установке зависимостей
    cd ..
    pause
    exit /b 1
)

echo [✓] Применение миграций базы данных...
python -m alembic upgrade head
if errorlevel 1 (
    echo [⚠] Предупреждение: возможны проблемы с миграциями
    echo     Убедитесь, что база данных доступна
)

cd ..
echo.

REM Настройка Frontend
echo [3/6] Настройка Frontend...
cd frontend

if not exist .env.local (
    echo [✓] Создание .env.local файла...
    (
        echo # Frontend Environment Variables
        echo VITE_API_URL=http://localhost:8000
        echo VITE_APP_NAME=AI Competitor Insight Hub
        echo VITE_APP_VERSION=0.1.0
        echo VITE_DEV_API_URL=http://localhost:8000
    ) > .env.local
    echo [✓] Файл .env.local создан
) else (
    echo [✓] Файл .env.local уже существует
)

if not exist node_modules (
    echo [✓] Установка зависимостей Node.js (это может занять время)...
    call npm install
    if errorlevel 1 (
        echo [✗] Ошибка при установке зависимостей npm
        cd ..
        pause
        exit /b 1
    )
) else (
    echo [✓] Зависимости Node.js уже установлены
)

cd ..
echo.

REM Запуск сервисов
echo [4/6] Запуск Backend сервера...
start "Backend API - http://localhost:8000" cmd /k "cd /d %~dp0backend && echo Запуск Backend API... && python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000"
timeout /t 3 >nul

echo [5/6] Запуск Frontend сервера...
start "Frontend Dev Server - http://localhost:5173" cmd /k "cd /d %~dp0frontend && echo Запуск Frontend... && npm run dev"
timeout /t 2 >nul

echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║                    ПРОЕКТ ЗАПУЩЕН!                      ║
echo ╚══════════════════════════════════════════════════════════╝
echo.
echo 📍 Backend API:     http://localhost:8000
echo 📍 API Docs:       http://localhost:8000/docs
echo 📍 Frontend:        http://localhost:5173
echo.
echo 💡 Откройте браузер и перейдите на http://localhost:5173
echo.
echo ⚠  Для остановки серверов закройте окна командной строки
echo    или нажмите Ctrl+C в каждом окне
echo.
pause


