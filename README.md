# greetings
## Build Docker Image
docker build --no-cache -t my-spring-app:j25 .

## Run the container
docker run -d -p 8080:8080 --name my-spring-container my-spring-app:j25
