#!/bin/bash

# Step 1: Initialize Replica Set
echo "Initializing MongoDB Replica Set..."
sleep 10  # Wait to give MongoDB enough time to start

until mongo --host mongodb --eval "printjson(rs.initiate())" || mongo --host mongodb --eval "printjson(rs.status())" | grep '"ok" : 1'; do
  echo "Waiting for MongoDB to be ready for replica set initialization..."
  sleep 1
done
echo "Replica Set Initialized."

# Step 2: Wait for Primary Election
echo "Waiting for MongoDB to become primary before adding user..."
until mongo --host mongodb --eval "printjson(rs.isMaster())" | grep '"ismaster" : true'; do
    sleep 5
    echo "Waiting for MongoDB to be elected as primary..."
done
echo "MongoDB is primary."

# Step 3: Add Admin User
echo "Adding admin user..."
mongo --host mongodb <<EOF
    use admin;
    db.createUser({
        user: "root",
        pwd: "rootpassword",
        roles: [{ role: "root", db: "admin" }]
    });
EOF
echo "Admin user added."

# Step 4: Initialize Database and Insert Data
echo "Initializing shop database and inserting data..."
mongo --host mongodb <<EOF
    use shop;
    db.createCollection("products");

    db.products.insertMany([
      { _id: 1, name: "Product A", price: 100 },
      { _id: 2, name: "Product B", price: 200 }
    ]);
EOF
echo "Shop database initialized and data inserted."

echo "MongoDB setup complete."
