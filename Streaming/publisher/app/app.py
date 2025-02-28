from fastapi import FastAPI
from pydantic import BaseModel
import pandas as pd
from kafka import KafkaProducer
import time
import logging
import json
import datetime

app = FastAPI()

def json_serializer(obj):
    if isinstance(obj, (datetime.datetime, datetime.date)):
        return obj.isoformat()
    return str(obj)

KAFKA_BOOTSTRAP_SERVERS = "kafka:9092"
producer = KafkaProducer(
    bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS,
    value_serializer=lambda v: json.dumps(v, default=json_serializer).encode("utf-8")
)

# Logger setup
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class FileInfo(BaseModel):
    file_path: str
    topic_name: str
    record_limit: int
    chunk_size: int

@app.post("/publish-csv")
async def publish_csv(file_info: FileInfo):
    try:
        logger.info("API called")
        total_sent = 0

        # Read CSV in chunks
        for chunk in pd.read_csv(file_info.file_path, chunksize=file_info.chunk_size):
            logger.info(f"Reading chunk with columns: {chunk.columns.tolist()}")

            if "charttime" in chunk.columns:
                chunk["charttime"] = chunk["charttime"].astype(str)
            if "storetime" in chunk.columns:
                chunk["storetime"] = chunk["storetime"].astype(str)

            for _, row in chunk.iterrows():
                if total_sent >= file_info.record_limit:
                    break

                producer.send(file_info.topic_name, value=row.to_dict())
                total_sent += 1

            time.sleep(1)
            if total_sent >= file_info.record_limit:
                break

        return {"status": "success", "message": f"Sent {total_sent} records"}

    except Exception as e:
        logger.error(f"Error while processing the file: {e}")
        return {"status": "error", "message": str(e)}
