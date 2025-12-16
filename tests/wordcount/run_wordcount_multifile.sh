#!/bin/bash
# WordCount Multi-File Test Runner
# Tests Spark cluster performance with distributed files

set -e

MASTER_URL="spark://spark-master:7077"
INPUT_DIR="/tmp/books/*.txt"
SCRIPT_PATH="/home/spark/wordcount.py"

echo "=================================================="
echo "Multi-File WordCount Performance Test"
echo "Processing 10 Classic Books from Project Gutenberg"
echo "=================================================="
echo ""

# Display dataset info
echo "Dataset Information:"
echo "-------------------"
du -sh /tmp/books 2>/dev/null || echo "Books directory not found!"
echo "Total files: $(ls /tmp/books/*.txt 2>/dev/null | wc -l)"
echo ""

# Test 1: Single Executor
echo "=================================================="
echo "TEST 1: Running with 1 Executor"
echo "=================================================="
rm -rf /tmp/wordcount_multifile_1exec 2>/dev/null || true

/opt/spark/bin/spark-submit \
    --master $MASTER_URL \
    --executor-memory 512M \
    --total-executor-cores 1 \
    --conf spark.ui.showConsoleProgress=false \
    $SCRIPT_PATH \
    "$INPUT_DIR" \
    /tmp/wordcount_multifile_1exec

echo ""
echo "Test 1 Complete!"
echo ""
sleep 3

# Test 2: Two Executors
echo "=================================================="
echo "TEST 2: Running with 2 Executors"
echo "=================================================="
rm -rf /tmp/wordcount_multifile_2exec 2>/dev/null || true

/opt/spark/bin/spark-submit \
    --master $MASTER_URL \
    --executor-memory 512M \
    --total-executor-cores 2 \
    --conf spark.ui.showConsoleProgress=false \
    $SCRIPT_PATH \
    "$INPUT_DIR" \
    /tmp/wordcount_multifile_2exec

echo ""
echo "Test 2 Complete!"
echo ""

echo "=================================================="
echo "Performance Comparison Complete!"
echo "=================================================="
echo ""
echo "View detailed results in Spark Web UI:"
echo "http://$(hostname -I | awk '{print $1}'):8080"
echo ""
echo "Check /tmp/wordcount_multifile_* for output files"
