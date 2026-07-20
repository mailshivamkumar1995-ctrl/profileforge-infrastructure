variable "postgres_password" {
  description = "Postgres database password"
  type        = string
  sensitive   = true
}

variable "django_secret_key" {
  description = "Django SECRET_KEY"
  type        = string
  sensitive   = true
}

variable "backend_database_url" {
  description = "Full DATABASE_URL connection string for the backend"
  type        = string
  sensitive   = true
}
