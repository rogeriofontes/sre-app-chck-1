cd app
pip install -r requirements.txt
python app.py

# Em outro terminal, teste:
curl http://localhost:8080/
curl http://localhost:8080/health


--
# Construir a imagem
docker build -t sre-app:1.0.1 app/

# Executar o container
se precisar remover: docker rm -f sre-app
docker run -d -p 8080:8080 --name sre-app sre-app:1.0.1

# Testar
curl http://localhost:8080/health

# Ver logs
docker logs minha-app

# Parar e remover
docker stop minha-app
docker rm minha-app

---
cd tests
pip install -r requirements.txt
pytest -v test_app.py