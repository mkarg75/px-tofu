terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.23.0"
    }
    kubectl = {
      source = "alekc/kubectl"
      version = ">= 2.0.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/Development/SDAIA/mkarg-tofu.1"
}

provider "kubectl" {
  config_path = "~/Development/SDAIA/mkarg-tofu.1"

}

# 1. Install the operator

data "kubectl_file_documents" "docs" {
  content = file("./operator.yaml")
}

resource "kubectl_manifest" "operator-test" {
  for_each = data.kubectl_file_documents.docs.manifests
  yaml_body = each.value
}

# 2. Label the px-nodes (future: get nodes via ENV variable)

variable "px-nodes" {
  type = list(string)
  default = ["node-1-4", "node-1-5"]
}

resource "kubernetes_labels" "px-enabled" {
  for_each = toset(var.px-nodes)
  api_version = "v1"
  kind = "Node"
  metadata {
    name = each.value
  }
  labels = {
    "px/enabled" = "false"
  }
}

# 3. Install the StorageCluster (future: templatize the STC so that we fill in device specs from ENV variables)

resource "kubectl_manifest" "storagecluster-test" {
  yaml_body = file("./storagecluster.yaml")
}