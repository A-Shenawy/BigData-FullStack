from pyspark.sql import SparkSession
from pyspark.sql.functions import from_json, col, when, lit, to_timestamp
from pyspark.sql.types import StructType, StructField, IntegerType, DoubleType, StringType
from influxdb_client import InfluxDBClient, Point, WritePrecision, WriteOptions
from datetime import datetime

import logging
import os 
import time

# Spark and Kafka Configuration
os.environ['PYSPARK_SUBMIT_ARGS'] = '--repositories https://repo1.maven.org/maven2 --packages org.apache.spark:spark-streaming-kafka-0-10_2.12:3.3.0,org.apache.spark:spark-sql-kafka-0-10_2.12:3.3.0 pyspark-shell'

# Logging Configuration
logging.basicConfig(format="%(asctime)s - %(levelname)s - %(message)s", level=logging.INFO)
logger = logging.getLogger(__name__)

# InfluxDB connection settings
INFLUXDB_URL = "http://influxdb:8086"
INFLUXDB_TOKEN = "mynewadmintoken"  # Replace with the correct token
INFLUXDB_ORG = "my-org"
INFLUXDB_BUCKET = "icu_alerts"

# Initialize InfluxDB Client
client = InfluxDBClient(url=INFLUXDB_URL, token=INFLUXDB_TOKEN, org=INFLUXDB_ORG)
write_api = client.write_api(write_options=WriteOptions(batch_size=500, flush_interval=10000))

# Kafka connection settings
KAFKA_BOOTSTRAP_SERVERS = os.getenv('KAFKA_BROKER_URL', 'kafka:9092')
KAFKA_TOPIC = "patient-data-topic"

# Define schema for incoming JSON messages
schema = StructType([
    StructField("row_id", IntegerType(), True),
    StructField("subject_id", IntegerType(), True),
    StructField("hadm_id", IntegerType(), True),
    StructField("icustay_id", IntegerType(), True),
    StructField("itemid", IntegerType(), True),
    StructField("charttime", StringType(), True),
    StructField("valuenum", DoubleType(), True),
    StructField("valueuom", StringType(), True)
])

def send_to_influxdb(row):
    """
    Function to send Spark row data to InfluxDB.
    """
    start_time = time.time()
    try:
        logger.info(f"   row for InfluxDB: {row.asDict()}")
        current_time = datetime.utcnow().isoformat()
        point = Point("vital_signs_alerts") \
            .tag("subject_id", str(row["subject_id"])) \
            .field("itemid", int(row["itemid"])) \
            .field("valuenum", float(row["valuenum"])) \
            .field("alert", str(row["alert"])) \
            .time(current_time)

        write_api.write(bucket=INFLUXDB_BUCKET, record=point)
        logger.info(f"Successfully written in {time.time() - start_time:.2f} seconds: {row.asDict()}")

    except Exception as e:
        logger.error(f"Error writing to InfluxDB: {e} | Row: {row.asDict()}")

def start_spark_streaming():
    """
    Function to start Spark Streaming to process Kafka messages.
    """
    logger.info("Starting Spark session...")

    spark = SparkSession.builder \
        .appName("MIMIC-III Vitals Monitoring") \
        .config("spark.streaming.kafka.consumer.poll.ms", "1000") \
        .config("spark.streaming.backpressure.enabled", "true") \
        .config("spark.streaming.stopGracefullyOnShutdown", "true") \
        .getOrCreate()

    spark.sparkContext.setLogLevel("WARN")

    # Read messages from Kafka topic
    logger.info(f"Subscribing to Kafka topic: {KAFKA_TOPIC}")
    kafka_stream = spark.readStream \
        .format("kafka") \
        .option("kafka.bootstrap.servers", KAFKA_BOOTSTRAP_SERVERS) \
        .option("subscribe", KAFKA_TOPIC) \
        .option("startingOffsets", "latest") \
        .option("failOnDataLoss", "false") \
        .load()

    # Extract message value and parse JSON
    messages = kafka_stream.selectExpr("CAST(value AS STRING) as json_value")
    parsed_df = messages.select(from_json(col("json_value"), schema).alias("data")).select("data.*")

    # Convert charttime to timestamp for proper processing
    parsed_df = parsed_df.withColumn("charttime", to_timestamp(col("charttime"), "yyyy-MM-dd HH:mm:ss"))

    # Add alert conditions based on ITEMID and VALUENUM thresholds
    alerts_df = parsed_df.withColumn(
        "alert",
        when((col("itemid") == 220045) & ((col("valuenum") < 40) | (col("valuenum") > 120)),
             lit("Heart Rate Alert")
        ).when((col("itemid") == 220179) & ((col("valuenum") < 90) | (col("valuenum") > 180)),
             lit("Systolic BP Alert")
        ).otherwise(lit("OK"))
    )

    logger.info("Starting InfluxDB data writer...")

    # Write alerts to InfluxDB
    alerts_df.writeStream \
        .trigger(processingTime='10 seconds') \
        .foreachBatch(lambda df, epoch_id: df.foreach(send_to_influxdb)) \
        .start() \
        .awaitTermination()

if __name__ == "__main__":
    try:
        logger.info("Starting Spark Streaming subscriberrrrrrrrrr1r1...")
        start_spark_streaming()
    except Exception as e:
        logger.error(f"Subscriber encountered an error: {e}")
    finally:
        client.close()
        logger.info("InfluxDB client closed.")
