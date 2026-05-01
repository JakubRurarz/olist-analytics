import os
from google.cloud import bigquery
import pandas as pd

# Config
PROJECT_ID = "project-464be524-d814-4c8a-b4f"
DATASET_ID = "raw_olist"
DATA_PATH = "/Users/rureczka/Praca/Datasets/Olist Data"


FILES = {
    "olist_customers_dataset.csv": "customers",
    "olist_geolocation_dataset.csv": "geolocation",
    "olist_order_items_dataset.csv": "order_items",
    "olist_order_payments_dataset.csv": "order_payments",
    "olist_order_reviews_dataset.csv": "order_reviews",
    "olist_orders_dataset.csv": "orders",
    "olist_products_dataset.csv": "products",
    "olist_sellers_dataset.csv": "sellers",
    "product_category_name_translation.csv": "product_category_name_translation",
}

def load_data():
    # Connect to BigQuery using your application default credentials
    client = bigquery.Client(project=PROJECT_ID)

    # Create the dataset if it doesn't exist
    dataset_ref = bigquery.Dataset(f"{PROJECT_ID}.{DATASET_ID}")
    dataset_ref.location = "EU"
    client.create_dataset(dataset_ref, exists_ok=True)
    print(f"Dataset {DATASET_ID} ready")

    # Loop through each file and load it
    for filename, table_name in FILES.items():
        filepath = os.path.join(DATA_PATH, filename)
        print(f"Loading {filename} into {table_name}...")

        # Read CSV into pandas dataframe
        df = pd.read_csv(filepath)

        # Define destination table
        table_id = f"{PROJECT_ID}.{DATASET_ID}.{table_name}"

        # Load into BigQuery, replacing table if it exists
        job_config = bigquery.LoadJobConfig(
            write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
            autodetect=True,
        )

        job = client.load_table_from_dataframe(df, table_id, job_config=job_config)
        job.result()  # Wait for job to complete

        print(f"✓ Loaded {len(df)} rows into {table_name}")

    print("\nAll tables loaded successfully")

if __name__ == "__main__":
    load_data()