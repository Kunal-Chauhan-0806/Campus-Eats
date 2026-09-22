#!/bin/bash
# ════════════════════════════════════════════════════════════════
#  CampusEats — Build & Run Script (Pure Java + JDBC, No Frameworks)
# ════════════════════════════════════════════════════════════════
#
#  Prerequisites:
#    1. Java 17+  →  https://adoptium.net/
#    2. MySQL 8+  →  https://dev.mysql.com/downloads/
#    3. MySQL Connector/J JAR in ./lib/
#       Download: https://dev.mysql.com/downloads/connector/j/
#       Place as: ./lib/mysql-connector-j-9.x.x.jar
#
#  Run this script:
#    chmod +x run.sh
#    ./run.sh
# ════════════════════════════════════════════════════════════════

set -e

JAR=$(ls lib/mysql-connector-j-*.jar 2>/dev/null | head -1)
if [ -z "$JAR" ]; then
  echo "❌ MySQL JDBC driver not found!"
  echo "   Download from: https://dev.mysql.com/downloads/connector/j/"
  echo "   Place the .jar file in the ./lib/ directory."
  exit 1
fi

echo "📦 Found JDBC driver: $JAR"
echo "🔨 Compiling Java sources..."

mkdir -p out

# Compile all .java files
find src -name "*.java" > sources.txt
javac -cp "$JAR" -d out @sources.txt
rm sources.txt

echo "✅ Compilation successful!"
echo "🚀 Starting CampusEats server..."
echo "   → http://localhost:8080"
echo ""

# Run the server
java -cp "out:$JAR" com.college.canteen.server.Main
