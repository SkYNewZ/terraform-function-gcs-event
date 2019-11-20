from google.cloud import storage
import sys

# https://cloud.google.com/functions/docs/calling/storage
# https://cloud.google.com/appengine/docs/standard/python3/using-cloud-storage


def hello_gcs_generic(data, context):
    """Background Cloud Function to be triggered by Cloud Storage.
       This generic function logs relevant data when a file is changed.

    Args:
        data (dict): The Cloud Functions event payload.
        context (google.cloud.functions.Context): Metadata of triggering event.
    Returns:
        None; the output is written to Stackdriver Logging
    """

    if context:
        print("Event ID: {}".format(context.event_id))
        print("Event type: {}".format(context.event_type))

    print("Bucket: {}".format(data["bucket"]))
    print("File: {}".format(data["name"]))
    print("Metageneration: {}".format(data["metageneration"]))
    print("Created: {}".format(data["timeCreated"]))
    print("Updated: {}".format(data["updated"]))

    # Read content of incoming file
    client = storage.Client()
    bucket = client.get_bucket(data["bucket"])
    blob = bucket.get_blob(data["name"])

    # If file found
    if not blob:
        print("File not found…")
        sys.exit(1)

    print(blob.download_as_string(raw_download=True))


if __name__ == "__main__":
    data = {
        "bucket": "quentin-poc-dtep-poc-nicolas",
        "name": "test.txt",
        "metageneration": "metageneration-test",
        "timeCreated": "now",
        "updated": "now too",
    }
    hello_gcs_generic(data=data, context=None)
