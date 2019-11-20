variable "project_id" {
  type = string
}

variable "bucket_name" {
  type    = string
  default = "poc-nicolas"
}

variable "labels" {
  type = map
  default = {
    creator = "iaaswecan-team"
  }
}

variable "region" {
  type    = string
  default = "europe-west1"
}
