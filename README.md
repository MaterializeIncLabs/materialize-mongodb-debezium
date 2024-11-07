# MongoDB to Materialize via Debezium

This project demonstrates how to set up a **MongoDB** database, **Kafka** messaging system, and **Debezium** to capture data changes from MongoDB, which are then made available for querying in **Materialize**.

## Prerequisites

- **Docker** and **Docker Compose** installed on your system.

## Getting Started

To get started, clone this repository and navigate to the project directory. The `docker-compose.yml` file provided will start all the necessary services: MongoDB, Kafka, Debezium, Schema Registry, and Materialize.

### Step 1: Bring Up the Services

To bring up all the services, run:

```bash
docker-compose up -d
```

This command will start the following services:
- **MongoDB**: The database where data is stored.
- **Kafka**: Used for streaming data captured by Debezium.
- **Schema Registry**: Manages Avro schemas used by Kafka.
- **Debezium**: Captures change events from MongoDB and publishes them to Kafka.
- **Materialize**: Reads from Kafka and allows SQL-based querying of the data.

### Step 2: Connect to Materialize

Once all services are running, connect to **Materialize** using the following `psql` command:

```bash
psql postgres://materialize@localhost:6875/materialize
```

This will open a connection to Materialize using the PostgreSQL CLI.

### Step 3: Set Up Kafka and Schema Registry Connections in Materialize

To read data from Kafka, you need to create connections to both Kafka and the Schema Registry. Run the following SQL commands in the Materialize session:

```sql
CREATE CONNECTION kafka_connection TO KAFKA (
    BROKER 'kafka:9092',
    SECURITY PROTOCOL = 'PLAINTEXT'
);

CREATE CONNECTION csr_connection TO CONFLUENT SCHEMA REGISTRY (
    URL 'http://schema-registry:8081'
);
```

### Step 4: Create a Source in Materialize

Now, create a **source** in Materialize that reads from the Kafka topic where Debezium publishes MongoDB changes. Use the following SQL command:

```sql
CREATE SOURCE mongo_products
FROM KAFKA CONNECTION kafka_connection (TOPIC 'mongo.shop.products')
FORMAT AVRO USING CONFLUENT SCHEMA REGISTRY CONNECTION csr_connection
ENVELOPE UPSERT;
```

This command creates a source named `mongo_products` that reads from the Kafka topic `mongo.shop.products`, using **Avro** format for serialization, and an **upsert** envelope to handle change events.

### Step 5: Query the Data

Once the source is created, you can query the data using SQL. For example:

```sql
SELECT after FROM mongo_products;
```

This query will show the current state of all products in the `shop.products` collection in MongoDB.

## Troubleshooting

- **Service Not Starting**: If any services fail to start, check the logs with:
  ```bash
  docker-compose logs <service-name>
  ```
  Replace `<service-name>` with the name of the service (e.g., `kafka`, `materialized`).

- **Connector Issues**: Make sure the MongoDB replica set is initialized properly, and the Debezium connector is successfully deployed.

## Clean Up

To stop and remove all services, run:

```bash
docker-compose down -v
```

This will also remove any persistent volumes created by the containers, ensuring a clean slate for the next time you bring up the services.
