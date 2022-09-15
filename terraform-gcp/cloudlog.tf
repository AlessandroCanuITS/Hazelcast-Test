# Create an AuditLog for Cloud Storage trigger
resource "google_eventarc_trigger" "trigger-auditlog-tf" {
  provider = google-beta
  name     = "trigger-auditlog-tf"
  location = google_cloud_run_service.default.location
  project  = data.google_project.project.id
  matching_criteria {
    attribute = "type"
    value     = "google.cloud.audit.log.v1.written"
  }
  matching_criteria {
    attribute = "serviceName"
    value     = "storage.googleapis.com"
  }
  matching_criteria {
    attribute = "methodName"
    value     = "storage.objects.create"
  }
  destination {
    cloud_run_service {
      service = google_cloud_run_service.default.name
      region  = google_cloud_run_service.default.location
    }
  }
  service_account = "${data.google_project.project.number}-compute@developer.gserviceaccount.com"

  depends_on = [google_project_service.eventarc]
}