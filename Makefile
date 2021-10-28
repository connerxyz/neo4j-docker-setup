# from here https://container-solutions.com/tagging-docker-images-the-right-way/
# use: make build push

NAME   := neo4j-docker
TAG    := $$(git log -1 --pretty=%!H(MISSING))
IMG    := ${NAME}:${TAG}
LATEST := ${NAME}:latest
 
setup:
	mkdir data
	mkdir logs
	mkdir conf
	mkdir plugins
	docker run --rm \
		--volume=$$(pwd)/conf:/conf \
		--user=$$(id -u):$$(id -g) \
		neo4j:latest dump-config
	echo "\n# Adding plugins to configuration" >> ./conf/neo4j.conf
	echo "dbms.security.procedures.whitelist=algo.*,apoc.*" >> ./conf/neo4j.conf
	echo "dbms.security.procedures.unrestricted=algo.*,apoc.*" >> ./conf/neo4j.conf
	echo "Make sure you have downloaded plugins and placed them in ./plugins"

run:
	docker run -d \
		--publish=7474:7474 \
		--publish=7687:7687 \
		--volume=$$(pwd)/data:/data \
		--volume=$$(pwd)/logs:/logs \
		--volume=$$(pwd)/conf:/conf \
		--volume=$$(pwd)/plugins:/plugins \
		--env=NEO4J_AUTH=none \
		--name neo4j-docker neo4j:latest
	echo "It might take some time for the UI to load in the browser."
	sleep 10
	open http://localhost:7474

stop:
	docker stop neo4j-docker

rm:
	docker rm neo4j-docker

# test:
# 	echo ${URL}
# 	echo ${NAME}
# 	echo ${COMMIT}

# build:
#   @docker build -t ${IMG} .
#   @docker tag ${IMG} ${LATEST}
 
# login:
#   @docker log -u ${DOCKER_USER} -p ${DOCKER_PASS}

# push:
#   @docker push ${NAME}
 