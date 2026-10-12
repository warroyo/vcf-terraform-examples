data "vsphere_storage_policy" "namespace" {
  name = var.storage_policy_name
}

# a supervisor namespace made directly in vCenter, VCF Automation is not involved.
# no network is set so it gets the supervisor's default workload network
resource "vsphere_namespace" "namespace" {
  name       = var.namespace_name
  supervisor = var.supervisor_id

  storage_policies = [data.vsphere_storage_policy.namespace.id]
}

resource "kubernetes_config_map_v1" "example" {
  metadata {
    name      = "example"
    namespace = vsphere_namespace.namespace.name
  }

  data = {
    "created-by" = "terraform"
    "message"    = "hello from the supervisor"
  }
}
