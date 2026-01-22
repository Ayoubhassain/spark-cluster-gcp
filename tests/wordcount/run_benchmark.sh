#!/bin/bash
# run_benchmark.sh - Java Spark Benchmark

if [ -z "$1" ]; then
    echo "Usage: ./run_benchmark.sh <number_of_cores>"
    echo "Example: ./run_benchmark.sh 4"
    exit 1
fi

CORES=$1
MASTER_URL="spark://spark-master:7077"

# 2. Path: Point to the shared /mnt/spark-data
INPUT_DIR="file:///mnt/spark-data/*.txt"

# 3. Output: Write to /mnt/spark-data so the Edge Node can see the results
OUTPUT_DIR="/mnt/spark-data/wordcount_bench_${CORES}cores"
# -----------------------

# JAR Configuration
JAR_PATH="/home/spark/wordcount-java/target/wordcount-1.0-SNAPSHOT.jar"
MAIN_CLASS="org.spark.example.JavaWordCount"

echo "--------------------------------------------------"
echo "RUNNING JAVA BENCHMARK WITH $CORES CORES"
echo "--------------------------------------------------"

# Clean old output from the shared storage
rm -rf $OUTPUT_DIR 2>/dev/null || true

START_TIME=$(date +%s)

/opt/spark/bin/spark-submit \
    --class $MAIN_CLASS \
    --master $MASTER_URL \
    --executor-memory 512M \
    --total-executor-cores $CORES \
    --conf spark.ui.showConsoleProgress=false \
    $JAR_PATH \
    "$INPUT_DIR" \
    $OUTPUT_DIR

END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))

echo "--------------------------------------------------"
echo "FINISHED: $CORES Cores took $ELAPSED seconds"
echo "Results saved to: $OUTPUT_DIR"
echo "--------------------------------------------------"