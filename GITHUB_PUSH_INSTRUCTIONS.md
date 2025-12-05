# Инструкция по отправке проекта в GitHub

Репозиторий уже создан: `9temka-spotemok/testai`

## Способ 1: Через Git (рекомендуется)

```bash
cd "E:\Проекты\1"

# Инициализация git (если еще не сделано)
git init

# Добавление удаленного репозитория
git remote add origin https://github.com/9temka-spotemok/testai.git

# Добавление всех файлов
git add .

# Коммит
git commit -m "test"

# Отправка в GitHub
git push -u origin main
```

## Способ 2: Через GitHub Desktop

1. Откройте GitHub Desktop
2. File → Add Local Repository
3. Выберите папку `E:\Проекты\1`
4. Нажмите "Publish repository"
5. Выберите `9temka-spotemok/testai`

## Способ 3: Через веб-интерфейс GitHub

1. Откройте https://github.com/9temka-spotemok/testai
2. Нажмите "uploading an existing file"
3. Перетащите файлы из папки проекта

## Важно

- Убедитесь, что файлы `.env` и `.env.local` не попадут в репозиторий (они в `.gitignore`)
- Все зависимости (`node_modules`, `__pycache__`, `.venv`) также игнорируются
- README.md уже создан в репозитории


