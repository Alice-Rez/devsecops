# SonarQube setup on Mac with Rancher Desktop

The SQ setup is a bit more complicated now and it is not covered in course. Additionally if the docker runs in Rancher desktop,the setup is a bit more complicated.

## 1. Set vm.max_map_count in Rancher’s VM

- otherwise the sonarqube will never start as it will not have enough resources
- additionally setup in Rancher Desktop settings for VM 8GB memory and 4CPU

```bash
# open a shell into Rancher Desktop's VM
rdctl shell      # if this isn't found, try: limactl shell rancher-desktop

# inside the VM:
sudo sysctl -w vm.max_map_count=262144
# (optional/persistent)
echo 'vm.max_map_count=262144' | sudo tee /etc/sysctl.d/99-sonarqube.conf

# verify
cat /proc/sys/vm/max_map_count   # should print 262144
```

## 2. start SonarQube with Postgres

- it needs postgres to store the data - otherwise it will never start
- the postgres need to be in same network
- port 9000 does not work! therefore using 9099
- the db needs persistent volume to store all important information, otherwise we will again and again start anew

```bash
# create docker network 
docker network create sonarnet 2>/dev/null || true

# create volume for db
docker volume create sonardb_data

# start db container
docker run -d --name sonardb --network sonarnet \        
  -e POSTGRES_USER=<insert-username> -e POSTGRES_PASSWORD=<insert-pwd> -e POSTGRES_DB=sonarqube \
  postgres:15

# start SQ container

docker run -d --name sonarqube --network sonarnet -p 127.0.0.1:9099:9000 \
  --ulimit nofile=65536:65536 --ulimit nproc=4096:4096 --shm-size=512m \
  -e SONAR_JDBC_URL=jdbc:postgresql://sonardb:5432/sonarqube \
  -e SONAR_JDBC_USERNAME=<insert-username> -e SONAR_JDBC_PASSWORD=<insert-password> \
  -e SONAR_WEB_JAVAOPTS="-Xms512m -Xmx512m" \
  -e SONAR_CE_JAVAOPTS="-Xms512m -Xmx512m" \
  -e SONAR_ES_JAVA_OPTS="-Xms1g -Xmx1g" \
  -v "$HOME/sonar-config/sonar.properties:/opt/sonarqube/conf/sonar.properties:ro" \
  sonarqube:lts-community
```

- in the case of the restart of the laptop, the containers will stop. We can easily restart them using:

```bash
docker restart sonardb sonarqube
```
 - as we are using the docker volume, the 
