# Быстрый запуск проекта

## Автоматический запуск

Запустите файл `start_project.bat` двойным кликом или через командную строку:

```cmd
start_project.bat
```

## Ручной запуск (пошагово)

### 1. Запуск инфраструктуры (PostgreSQL и Redis)

Если у вас установлен Docker:

```cmd
docker-compose up -d postgres redis
```

Если Docker не установлен, вам нужно установить PostgreSQL и Redis локально.

### 2. Настройка Backend

```cmd
cd backend

REM Создать .env файл (если его нет)
if not exist .env copy env.example .env

REM Установить зависимости
python -m pip install -r requirements.txt

REM Применить миграции
python -m alembic upgrade head

REM Запустить сервер
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Backend будет доступен на: http://localhost:8000
API документация: http://localhost:8000/docs

### 3. Настройка Frontend

Откройте новый терминал:

```cmd
cd frontend

REM Создать .env.local файл (если его нет)
if not exist .env.local copy env.example .env.local
echo VITE_API_URL=http://localhost:8000 > .env.local

REM Установить зависимости
npm install

REM Запустить dev сервер
npm run dev
```

Frontend будет доступен на: http://localhost:5173

## Проверка работы

1. Откройте браузер и перейдите на http://localhost:5173
2. Проверьте API: http://localhost:8000/health
3. Проверьте документацию API: http://localhost:8000/docs

## Устранение проблем

### Backend не запускается

- Убедитесь, что PostgreSQL запущен и доступен на localhost:5432
- Проверьте DATABASE_URL в backend/.env
- Убедитесь, что все зависимости установлены: `pip install -r requirements.txt`

### Frontend не подключается к Backend

- Проверьте, что Backend запущен на порту 8000
- Проверьте VITE_API_URL в frontend/.env.local
- Убедитесь, что нет проблем с CORS (должны быть настроены автоматически)

### Проблемы с миграциями

```cmd
cd backend
python -m alembic current
python -m alembic upgrade head
```

## Дополнительные сервисы (опционально)

### Celery Worker (для фоновых задач)

```cmd
cd backend
python -m celery -A app.celery_app worker --loglevel=info
```

### Celery Beat (планировщик задач)

```cmd
cd backend
python -m celery -A app.celery_app beat --loglevel=info
```


