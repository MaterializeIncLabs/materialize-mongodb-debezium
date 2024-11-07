#!/usr/bin/env bash

echo "Deploying Debezium MongoDB connector"

# Check if the connector already exists
CONNECTOR_NAME="register-mongodb"
EXISTING_CONNECTOR=$(curl -s -o /dev/null -w "%{http_code}" http://debezium:8083/connectors/$CONNECTOR_NAME)

# Deploy the connector since it doesn't exist
curl -s -X PUT -H "Content-Type:application/json" http://debezium:8083/connectors/$CONNECTOR_NAME/config \
      -d '{
      "name": "'"$CONNECTOR_NAME"'",
      "connector.class": "io.debezium.connector.mongodb.MongoDbConnector",
      "mongodb.hosts": "rs0/mongodb:27017",
      "mongodb.name": "mongo",
      "mongodb.user": "root",
      "mongodb.password": "rootpassword",
      "database.history.kafka.bootstrap.servers": "'"$KAFKA_ADDR"'",
      "database.history.kafka.topic": "mongodb-history",
      "collection.include.list": "shop.products",
      "publish.full.document.only": true
  }'

echo "Connector $CONNECTOR_NAME has been deployed."

