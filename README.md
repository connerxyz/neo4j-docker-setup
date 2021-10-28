# Running Neo4j in Docker Container

This repository contains code capable of running Neo4j community edition, with the APOC and Graph Algorithms plugins, in a Docker container.

## Quickstart (from scratch)

### Pull latest image

```
docker pull neo4j:latest
```

### Configuration

We treat the `Makefile` as a 'runbook' and try to capture administration routines here.

This will setup directories and configuration.

```
make setup
```

Now you must download the plugins and put their JARs in to the `plugins/` folder.

- https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases
- https://github.com/neo4j-contrib/neo4j-graph-algorithms/releases

### Running the container

Again, we rely on the `Makefile`. Your default browser should open to the Neo4j UI after this completes (this may take up to 20 seconds or so). You should be able to select "No authentication" in *Authentication type* dialog box and click *Connect* from there.

```
make run
```

The UI runs on port 7474 and drivers can connect on 7687.

### Verifying the plugins

We have run into an issue with the server not starting when plugins are installed. Skipping for now.

~~Run the following Cypher commands to verify the plugins are configured correctly.~~

```
CALL algo.list();
CALL apoc.index.list();
```

### Getting started with toy data

You can play around with Neo4j and get familiar with some example, "toy" data representing the London underground by executing. See [Neo4j London tube system analysis](https://tbgraph.wordpress.com/2017/08/31/neo4j-london-tube-system-analysis/) for details.

Create station nodes:

```
CREATE CONSTRAINT ON (s:Station) ASSERT s.id is unique;
CREATE INDEX ON :Station(name);
LOAD CSV WITH HEADERS FROM
"https://raw.githubusercontent.com/nicola/tubemaps/master/datasets/london.stations.csv" as row
MERGE (s:Station{id:row.id})
ON CREATE SET s.name = row.name,
              s.latitude=row.latitude,
              s.longitude=row.longitude,
              s.zone=row.zone,
              s.total_lines=row.total_lines;
```

Create edges between stations:

```
LOAD CSV WITH HEADERS FROM
"https://raw.githubusercontent.com/nicola/tubemaps/master/datasets/london.connections.csv" as row
MATCH (s1:Station{id:row.station1})
MATCH (s2:Station{id:row.station2})
MERGE (s1)-[:CONNECTION{time:row.time,line:row.line}]->(s2)
MERGE (s1)<-[:CONNECTION{time:row.time,line:row.line}]-(s2)
```

Query which stations have the most connections to other stations:

```
MATCH (n:Station)--(n1)
RETURN n.name as station,
       count(distinct(n1)) as connections 
order by connections desc LIMIT 15
```

### Stopping the container

Again, we rely on the `Makefile`. 

```
make stop
```

## Connecting programmatically via Python

Make sure the container is running.

```
make run
docker ps
```

Now make sure you have a Python 3 environment with `neo4j` installed within.

```
python --version
pip install neo4j
```

From here you can connect, read, write with a simple script like this. See [Neo4j Python Driver](https://neo4j.com/docs/api/python-driver/current/) for details.

```
from neo4j import GraphDatabase

# Note the port and protocol are different than when loading the UI in the browser.
driver = GraphDatabase.driver("bolt://localhost:7687")
session = driver.session()

query = "CREATE (:Capability {id: 'sdlku98...'})-[:COMPOSED_OF]–>(:Component:Service {id: '287fudk...'})"
session.run(query)

query = "MATCH (c:Capability) WHERE c.id = 'sdlku98...' RETURN c"
session.run(query).data()

driver.close()
```
