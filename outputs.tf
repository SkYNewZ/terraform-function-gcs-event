output "code_bucket" {
  value = google_storage_bucket.code.name
}

output "datastore_bucket" {
  value = google_storage_bucket.datastore.name
}

output "function_name" {
  value = google_cloudfunctions_function.function.name
}

