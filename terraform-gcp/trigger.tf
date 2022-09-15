# Used to retrieve project_number later
data "google_project" "project" {
  provider = google-beta
}

# Enable Cloud Run API
resource "google_project_service" "run" {
  provider = google-beta
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

# Enable Eventarc API
resource "google_project_service" "eventarc" {
  provider = google-beta
  service            = "eventarc.googleapis.com"
  disable_on_destroy = false
}

# Create a Pub/Sub trigger
resource "google_eventarc_trigger" "trigger-pubsub-tf" {
  provider = google-beta
  name     = "trigger-pubsub-tf"
  location = google_cloud_run_service.default.location
  matching_criteria {
    attribute = "type"
    value     = "google.cloud.pubsub.topic.v1.messagePublished"
  }
  destination {
    cloud_run_service {
      service = google_cloud_run_service.default.name
      region  = google_cloud_run_service.default.location
    }
  }

  depends_on = [google_project_service.eventarc]
}

# Give default Compute service account eventarc.eventReceiver role
resource "google_project_iam_binding" "project" {
  provider = google-beta
  project = data.google_project.project.id
  role    = "roles/eventarc.eventReceiver"

  members = [
    "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  ]
}