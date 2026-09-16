import pytest

pytestmark = pytest.mark.asyncio


async def test_health_check(client):
    response = await client.get("/api/v1/health")
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["data"]["status"] == "ok"
    assert data["data"]["database"] == "connected"


async def test_get_states(client):
    response = await client.get("/api/v1/geo/states")
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert len(data["data"]) == 27  # 27 estados brasileiros


async def test_register_new_ward(client):
    response = await client.post("/api/v1/auth/register/new-ward", json={
        "estado_id": 25,        # São Paulo
        "estaca_nome": "Estaca Teste Automatizado",
        "ala_nome": "Ala Teste Automatizado",
        "nome_completo": "Gabriel Teste",
        "email": "gabriel.teste@easyward.com",
        "password": "Senha@123",
    })
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert "access_token" in data["data"]
    assert data["data"]["user"]["name"] == "Gabriel Teste"
    assert len(data["data"]["user"]["permissions"]) > 0


async def test_login(client):
    # Primeiro registra
    await client.post("/api/v1/auth/register/new-ward", json={
        "estado_id": 25,
        "estaca_nome": "Estaca Login Teste",
        "ala_nome": "Ala Login Teste",
        "nome_completo": "Usuario Login",
        "email": "login.teste@easyward.com",
        "password": "Senha@123",
    })

    # Depois faz login
    response = await client.post("/api/v1/auth/login", json={
        "email": "login.teste@easyward.com",
        "password": "Senha@123",
    })
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert "access_token" in data["data"]


async def test_login_wrong_password(client):
    response = await client.post("/api/v1/auth/login", json={
        "email": "login.teste@easyward.com",
        "password": "senhaerrada",
    })
    assert response.status_code == 401


async def test_register_existing_ward_member_not_found(client):
    response = await client.post("/api/v1/auth/register/existing-ward", json={
        "ala_id": 999999,
        "nome_completo": "Pessoa Inexistente",
        "email": "inexistente@easyward.com",
        "password": "Senha@123",
    })
    assert response.status_code == 400