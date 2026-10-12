terraform {
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = ">= 2.17"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    http = {
      source = "hashicorp/http"
    }

  }
}

provider "vsphere" {
  vsphere_server       = var.vcenter_server
  user                 = var.vcenter_user
  password             = var.vcenter_password
  allow_unverified_ssl = true
}

# the supervisor hands out a session token for a vCenter login, this is the same
# token that `vcf context create` gets. terraform asks for a new one on every run.
data "http" "supervisor_login" {
  url      = "https://${var.supervisor_endpoint}/wcp/login"
  method   = "POST"
  insecure = true

  request_headers = {
    Authorization = "Basic ${base64encode("${var.vcenter_user}:${var.vcenter_password}")}"
  }

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "The supervisor refused the vCenter login: HTTP ${self.status_code}."
    }
  }
}

# the supervisor's own kubernetes api, it does not depend on the namespace
# so there is no need for a targeted apply
provider "kubernetes" {
  host     = "https://${var.supervisor_endpoint}:6443"
  insecure = true
  token    = jsondecode(data.http.supervisor_login.response_body).session_id
}
