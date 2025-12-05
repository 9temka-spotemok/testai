#!/usr/bin/env python3
"""
Скрипт для сбора всех файлов проекта для отправки в GitHub
"""
import os
import json
from pathlib import Path

def should_ignore(path_str, ignore_patterns):
    """Проверяет, нужно ли игнорировать файл/папку"""
    path_lower = path_str.lower().replace('\\', '/')
    for pattern in ignore_patterns:
        if pattern in path_lower:
            return True
    return False

def collect_files(root_dir):
    """Собирает все файлы проекта, исключая игнорируемые"""
    root = Path(root_dir)
    files = []
    
    ignore_patterns = [
        '__pycache__',
        '.git',
        'node_modules',
        '.venv',
        'venv',
        'env',
        'dist',
        'build',
        '.env',
        '.env.local',
        '.pyc',
        '.pyo',
        '.log',
        '.db',
        '.sqlite3',
        '.cache',
        '.pytest_cache',
        '.mypy_cache',
        '.coverage',
        'htmlcov',
        'test-results',
        'playwright-report',
        '.next',
        'out',
        '.nuxt',
        'storage/raw_snapshots',
        'artifacts',
        'celerybeat-schedule',
        'Thumbs.db',
        '.DS_Store',
    ]
    
    for file_path in root.rglob('*'):
        if file_path.is_file():
            rel_path = file_path.relative_to(root)
            path_str = str(rel_path).replace('\\', '/')
            
            # Пропускаем игнорируемые файлы
            if should_ignore(path_str, ignore_patterns):
                continue
            
            # Пропускаем файлы с расширениями, которые нужно игнорировать
            if any(path_str.endswith(ext) for ext in ['.pyc', '.pyo', '.log', '.db', '.sqlite3', '.cache']):
                continue
            
            try:
                # Читаем содержимое файла
                with open(file_path, 'rb') as f:
                    content = f.read()
                
                # Пробуем декодировать как текст
                try:
                    text_content = content.decode('utf-8')
                    files.append({
                        'path': path_str,
                        'content': text_content
                    })
                except UnicodeDecodeError:
                    # Если не текст, пропускаем (бинарные файлы)
                    print(f"Skipping binary file: {path_str}")
            except Exception as e:
                print(f"Error reading {path_str}: {e}")
    
    return files

if __name__ == '__main__':
    root_dir = r'E:\Проекты\1'
    print(f"Collecting files from {root_dir}...")
    
    files = collect_files(root_dir)
    print(f"Collected {len(files)} files")
    
    # Сохраняем список файлов в JSON для дальнейшего использования
    output_file = 'files_list.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump([file['path'] for file in files], f, indent=2, ensure_ascii=False)
    
    print(f"File list saved to {output_file}")
    print(f"Total files: {len(files)}")


