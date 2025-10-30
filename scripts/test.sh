#!/bin/bash
set -e

echo "=== Testing yaml2env on Unix/Linux ==="

# Create test YAML file
cat > /tmp/test.yaml << 'EOF'
database:
  host: localhost
  port: 5432
  username: admin
app:
  name: myapp
  debug: true
EOF

echo ""
echo "Test 1: Basic conversion to bash"
./yaml2env /tmp/test.yaml

echo ""
echo "Test 2: Conversion with prefix"
./yaml2env /tmp/test.yaml --prefix MYAPP

echo ""
echo "Test 3: Test sourcing (actual environment variable setting)"
eval "$(./yaml2env /tmp/test.yaml)"
echo "DATABASE_HOST=$DATABASE_HOST"
echo "DATABASE_PORT=$DATABASE_PORT"
echo "APP_NAME=$APP_NAME"

echo ""
echo "Test 4: Nested YAML with arrays"
cat > /tmp/test2.yaml << 'EOF'
services:
  - name: web
    port: 8080
  - name: api
    port: 3000
EOF

./yaml2env /tmp/test2.yaml

echo ""
echo "=== All tests passed ==="

# Cleanup
rm /tmp/test.yaml /tmp/test2.yaml
