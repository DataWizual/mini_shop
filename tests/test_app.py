import json
from app import app, db, Product

def test_home():
    client = app.test_client()
    response = client.get('/')
    assert response.status_code == 200
    assert b"Mini Shop Backend" in response.data

def test_add_and_get_product():
    client = app.test_client()
    # Добавить товар
    response = client.post('/add_product',
                           data=json.dumps({"name": "TestProduct", "price": 123.45}),
                           content_type='application/json')
    assert response.status_code == 201

    # Проверить список товаров
    response = client.get('/products')
    data = response.get_json()
    assert any(p["name"] == "TestProduct" for p in data)
