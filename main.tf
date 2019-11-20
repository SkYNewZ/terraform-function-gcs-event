# Enable Cloud Function API
resource "google_project_service" "cloudfunctions" {
  service            = "cloudfunctions.googleapis.com"
  disable_on_destroy = false
  project            = var.project_id
}

# Enable Storage API
resource "google_project_service" "storage" {
  service            = "storage-component.googleapis.com"
  disable_on_destroy = false
  project            = var.project_id
}

# Bucket containing files
resource "google_storage_bucket" "datastore" {
  project       = var.project_id
  name          = format("%s-%s", var.project_id, var.bucket_name)
  force_destroy = true
  location      = var.region
  labels        = var.labels
  depends_on = [
    google_project_service.storage
  ]
}

# Bucket containing Cloud Function source code
resource "google_storage_bucket" "code" {
  project       = var.project_id
  name          = format("%s-%s-source-code", var.project_id, var.bucket_name)
  force_destroy = true
  location      = var.region
  labels        = var.labels
  depends_on = [
    google_project_service.storage
  ]
}

# Create .zip file containig Python source code
data "archive_file" "source" {
  type        = "zip"
  output_path = "${path.module}/bin/code.zip"

  source {
    content  = file("${path.module}/code/main.py")
    filename = "main.py"
  }

  source {
    content  = file("${path.module}/code/requirements.txt")
    filename = "requirements.txt"
  }
}

# Copy source code to this bucket
resource "google_storage_bucket_object" "code" {
  name   = format("nicolas-%s.zip", data.archive_file.source.output_md5)
  bucket = google_storage_bucket.code.name
  source = data.archive_file.source.output_path
}


# Cloud Function example
resource "google_cloudfunctions_function" "function" {
  project               = var.project_id
  name                  = "nicolas-poc"
  region                = var.region
  description           = "Demonstrate Cloud Function with GCS trigger"
  runtime               = "python37"
  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.code.name
  source_archive_object = google_storage_bucket_object.code.name
  entry_point           = "hello_gcs_generic"
  labels                = var.labels

  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.datastore.name
  }

  depends_on = [
    google_project_service.cloudfunctions
  ]
}
