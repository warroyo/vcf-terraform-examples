# vSphere Namespace

This example creates a supervisor namespace directly in vCenter with the `vsphere` provider and deploys a simple `ConfigMap` into it. VCF Automation is not used at all, so the namespace has no project, no generated suffix and it will not show up in VCF Automation.

The namespace gets one storage policy and the supervisor's default workload network. No VM classes or limits are set.

### Pre-requisites

* a vCenter with a supervisor enabled
* a vCenter user that can create supervisor namespaces
* `vmware/vsphere` provider 2.17+

## Usage

1. create a terraform.tfvars file with the below contents

```
vcenter_server      = "vc01.your-domain.com"
vcenter_user        = "administrator@vsphere.local"
vcenter_password    = "your-password"
supervisor_endpoint = "10.0.0.10"
supervisor_id       = "00000000-0000-0000-0000-000000000000"
storage_policy_name = "vsan-default-storage-policy"

# optional, defaults to tf-example
# namespace_name = "tf-example"
```

The `supervisor_endpoint` is the control plane address of the supervisor, the same one used for `vcf context create`. The `supervisor_id` can be found with the vCenter API.

```bash
SESSION=$(curl -sk -X POST -u 'administrator@vsphere.local:your-password' https://vc01.your-domain.com/api/session | tr -d '"')
curl -sk -H "vmware-api-session-id: $SESSION" https://vc01.your-domain.com/api/vcenter/namespace-management/supervisors/summaries | jq '.items[] | {supervisor, name: .info.name}'
```

2. run terraform. unlike the VCF-A namespace based examples in this repo, this only needs a single apply. the kubernetes provider points at the supervisor itself and not at the new namespace, so it can be configured before the namespace exists.

```bash
terraform init
terraform apply
```

3. validate the config map

```bash
kubectl -n tf-example get configmap example -o yaml
```

## How the kubernetes login works

There is no kubeconfig needed on the machine running terraform. The supervisor will give out a session token for a vCenter login at `https://<supervisor>/wcp/login`, which is the same thing the `vcf` cli does. The `http` data source gets a new token on every run and passes it to the kubernetes provider.

## Things to know

* `vsphere_namespace` cannot be imported. A namespace with the same name that terraform did not create needs to be deleted first.
* the vCenter password and the supervisor session token end up in the terraform state. The `http` data source stores its request headers and response there. Treat the state as a secret and use an encrypted remote backend for anything real.
