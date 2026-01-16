import sys
sys.path.insert(0, '../app')

from app import app
import pytest

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_home_endpoint(client):
    """Testa se o endpoint principal funciona"""
    response = client.get('/')
    assert response.status_code == 200
    data = response.get_json()
    assert 'message' in data
    assert 'version' in data

def test_health_endpoint(client):
    """Testa se o endpoint de saúde funciona"""
    response = client.get('/health')
    assert response.status_code == 200
    data = response.get_json()
    assert data['status'] == 'healthy'
    assert 'uptime_seconds' in data
    assert 'timestamp' in data

def test_request_counter(client):
    """Testa se o contador de requisições funciona"""
    # Primeira requisição
    client.get('/')
    response1 = client.get('/metrics')
    count1 = response1.get_json()['total_requests']
    
    # Segunda requisição
    client.get('/')
    response2 = client.get('/metrics')
    count2 = response2.get_json()['total_requests']
    
    assert count2 > count1

def test_metrics_endpoint(client):
    """Testa se o endpoint de métricas funciona"""
    response = client.get('/metrics')
    assert response.status_code == 200
    data = response.get_json()
    assert 'total_requests' in data
    assert 'successful_requests' in data
    assert 'failed_requests' in data
    assert 'success_rate_percent' in data
    assert 'uptime_seconds' in data
    assert 'uptime_minutes' in data