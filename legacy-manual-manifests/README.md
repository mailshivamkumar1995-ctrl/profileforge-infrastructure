# Legacy Manual Manifests

This folder preserves the original, hand-written Kubernetes YAML manifests used to build the ProfileForge cluster before it was migrated to Terraform (see the parent `terraform/` folder for the current, actively-managed configuration).

**Purpose:** these files are kept for reference and to document the real migration path — every resource here was later adopted into Terraform via `terraform import`, with zero downtime and no resource recreation.

**Note:** Secret manifests (`postgres-secret.yaml`, `django-secret.yaml`, `backend-secret.yaml`) are intentionally excluded from this folder — even though their values were only base64-encoded (not encrypted), committing them to a public repo would expose effectively-plaintext credentials. The real, current secret definitions live in `../*.tf` as Terraform-managed resources.

**Status:** superseded — do not apply these directly; the cluster is now fully managed via Terraform.
