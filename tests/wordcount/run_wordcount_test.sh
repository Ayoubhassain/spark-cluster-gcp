#!/bin/bash
# WordCount Test Runner
# Tests Spark cluster with different executor configurations

set -e

MASTER_URL="spark://spark-master:7077"
INPUT_FILE="/tmp/shakespeare.txt"
SCRIPT_PATH="/home/spark/wordcount.py"

echo "=================================================="
echo "Spark Cluster Performance Testing"
echo "=================================================="
echo ""

# Download Shakespeare if not exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Downloading Shakespeare's Complete Works..."
    curl -o "$INPUT_FILE" https://www.gutenberg.org/files/100/100-0.txt
    echo "Download complete: $(wc -l < $INPUT_FILE) lines, $(wc -w < $INPUT_FILE) words"
    echo ""
fi

# Test 1: Single Executor
echo "=================================================="
echo "TEST 1: Running with 1 Executor"
echo "=================================================="
rm -rf /tmp/wordcount_output_1executor 2>/dev/null || true

/opt/spark/bin/spark-submit \
    --master $MASTER_URL \
    --executor-memory 512M \
    --total-executor-cores 1 \
    --conf spark.ui.showConsoleProgress=false \
    $SCRIPT_PATH \
    $INPUT_FILE \
    /tmp/wordcount_output_1executor

echo ""
echo "Test 1 Complete!"
echo ""
sleep 3

# Test 2: Two Executors
echo "=================================================="
echo "TEST 2: Running with 2 Executors"
echo "=================================================="
rm -rf /tmp/wordcount_output_2executors 2>/dev/null || true

/opt/spark/bin/spark-submit \
    --master $MASTER_URL \
    --executor-memory 512M \
    --total-executor-cores 2 \
    --conf spark.ui.showConsoleProgress=false \
    $SCRIPT_PATH \
    $INPUT_FILE \
    /tmp/wordcount_output_2executors

echo ""
echo "Test 2 Complete!"
echo ""

echo "=================================================="
echo "All Tests Completed!"
echo "=================================================="
echo ""
echo "View detailed results in Spark UI:"
echo "http://$(hostname -I | awk '{print $1}'):8080"
