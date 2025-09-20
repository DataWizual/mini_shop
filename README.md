# Mini Shop Backend

## Описание
Простейший интернет-магазин. Реализован на Flask + SQLite.

## Установка и запуск
```bash
pip install -r requirements.txt
python app.py
```

## API
- `/` → приветственное сообщение
- `/products` → список всех товаров (GET)
- `/products/<id>` → товар по ID (GET)
- `/add_product` → добавить товар (POST, JSON: {"name": "Book", "price": 10.5})
