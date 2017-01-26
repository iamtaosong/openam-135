Step0:

download openam and tools 13.5 to tools folder, rename openam war to openam.war 

docker build -t taosong/openam-135 .

docker run -d -h openam.example.com --name openam-135- -p 8080:8080 taosong/openam-135

docker run -d -h openam.example.com --name openam-135 -p 8080:8080 -p 18443:8443 taosong/openam-135

docker logs -f openam-135

http://openam.example.com:8080/openam
