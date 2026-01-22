package org.spark.example;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import scala.Tuple2;
import java.util.Arrays;

public class JavaWordCount {
    public static void main(String[] args) {
        if (args.length < 2) {
            System.err.println("Usage: JavaWordCount <input_file> <output_dir>");
            System.exit(1);
        }

        // Configure Spark
        SparkConf sparkConf = new SparkConf().setAppName("JavaWordCount");
        JavaSparkContext ctx = new JavaSparkContext(sparkConf);

        // Read files
        JavaRDD<String> lines = ctx.textFile(args[0], 1);

        // Map-Reduce logic
        JavaRDD<String> words = lines.flatMap(s -> Arrays.asList(s.split(" ")).iterator());
        JavaPairRDD<String, Integer> ones = words.mapToPair(word -> new Tuple2<>(word, 1));
        JavaPairRDD<String, Integer> counts = ones.reduceByKey((i1, i2) -> i1 + i2);

        // Save output
        counts.saveAsTextFile(args[1]);

        // Stop Spark
        ctx.stop();
    }
}