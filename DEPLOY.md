docker build -t sre-app:1.0.1 app/
docker run -p 8080:8080 sre-app:1.0.1

cd tests && pytest -v

./deploy.sh 1.0.1
./monitor.sh

curl http://localhost:8080/health