source ../secrets/config-values.yml

mkdir -p gke/ci/$environment_name/gcp/
mkdir -p gke/secrets/$environment_name/.kube/
mkdir -p gke/tas-pipelines-config/$environment_name/terraform/gcp/certmanager
mkdir -p gke/tas-pipelines-config/$environment_name/terraform/gcp/cluster
mkdir -p gke/tas-pipelines-config/$environment_name/terraform/gcp/dns
mkdir -p gke/tas-pipelines-config/$environment_name/terraform/gcp/external-dns
mkdir -p gke/tas-pipelines-config/$environment_name/terraform/k8s/harbor
mkdir -p gke/tas-pipelines-config/$environment_name/terraform/k8s/nginx
mkdir -p gke/tas-pipelines-config/$environment_name/terraform/k8s/tas4k8s
mkdir -p gke/tas-pipelines-config/$environment_name/terraform/k8s/tas4k8s/acme


cat << EOF > gke/tas-pipelines-config/$environment_name/terraform/gcp/certmanager/terraform.tfvars
project = "$gcp_project"
domain = "$environment_name.$domain"
acme_email = "$email"
dns_zone_name = "$environment_name-zone"
gcp_service_account_credentials = "/tmp/build/put/gcloud-credentials/gcp-credentials.json"
kubeconfig_path = "/tmp/build/put/kubeconfig/config"
EOF

cat << EOF > gke/tas-pipelines-config/$environment_name/terraform/gcp/cluster/terraform.tfvars
gcp_project = "$gcp_project"
gcp_service_account_credentials = "/tmp/build/put/gcloud-credentials/gcp-credentials.json"
gcp_region = "$gcp_region"
gke_name = "k8s"
gke_nodes = 1
gke_preemptible = true
gke_node_type = "$gke_node_type"
all_inbound = true
EOF

cat << EOF > gke/tas-pipelines-config/$environment_name/terraform/gcp/dns/terraform.tfvars
project = "$gcp_project"
gcp_service_account_credentials = "/tmp/build/put/gcloud-credentials/gcp-credentials.json"
root_zone_name = "$gcp_root_zone"
environment_name = "$environment_name"
dns_prefix = "$environment_name"
EOF

cat << EOF > gke/tas-pipelines-config/$environment_name/terraform/gcp/external-dns/terraform.tfvars
domain_filter = "$environment_name.$domain"
gcp_project = "$gcp_project"
gcp_service_account_credentials = "/tmp/build/put/gcloud-credentials/gcp-credentials.json"
kubeconfig_path = "/tmp/build/put/kubeconfig/config"
EOF

cat << EOF > gke/tas-pipelines-config/$environment_name/terraform/k8s/harbor/terraform.tfvars
domain = "$environment_name.$domain"
ingress = "nginx"
kubeconfig_path = "/tmp/build/put/kubeconfig/config"
EOF

cat << EOF > gke/tas-pipelines-config/$environment_name/terraform/k8s/nginx/terraform.tfvars
kubeconfig_path = "/tmp/build/put/kubeconfig/config"
#extra_args_key = "enable-ssl-passthrough"
#extra_args_value = "true"
EOF

cat << EOF > gke/tas-pipelines-config/$environment_name/terraform/k8s/tas4k8s/terraform.tfvars
base_domain = "$environment_name.$domain"
registry_domain = "harbor.$environment_name.$domain"
repository_prefix = "harbor.$environment_name.$domain/library"
registry_username = "admin"
pivnet_registry_hostname = "registry.pivotal.io"
pivnet_username = "$pivnet_username"
pivnet_password = "$pivnet_password"
kubeconfig_path = "/tmp/build/put/kubeconfig/config"
path_to_certs_and_keys = "/tmp/build/put/ck/certs-and-keys.vars"
ytt_lib_dir = "/tmp/build/put/tas4k8s-repo/ytt-libs"
registry_password =  "D01Tddb7LYBEdrld"
EOF

cat << EOF > gke/tas-pipelines-config/$environment_name/terraform/k8s/tas4k8s/acme/terraform.tfvars
base_domain = "$environment_name.$domain"
project = "$gcp_project"
email = "$email"
path_to_certs_and_keys = "kifi/terraform/k8s/tas4k8s/certs-and-keys.vars"
EOF

cat << EOF > gke/secrets/$environment_name/gcp-credentials.json
$gcp_service_account_credentials
EOF

cat << EOF > gke/ci/$environment_name/gcp/common.yml
concourse_url: http://gini-web.default.svc.cluster.local:8080
concourse_username: $concourse_username
concourse_password: $concourse_password
environment_name: $environment_name
product_version: $product_version
tanzu_network_api_token: $tanzu_network_api_token
gcp_account_key_json: |
  $gcp_service_account_credentials
EOF

cat << EOF > gke/secrets/$environment_name/.kube/config
---
apiVersion: v1
kind: Config
preferences:
  colors: true
current-context: REPLACE_ME
contexts:
  - context:
      cluster: REPLACE_ME
      namespace: default
      user: REPLACE_ME
    name: REPLACE_ME
clusters:
  - cluster:
      server: REPLACE_ME
      certificate-authority-data: REPLACE_ME
    name: REPLACE_ME
users:
  - name: REPLACE_ME
    user:
      password: REPLACE_ME
      username: REPLACE_ME
      client-certificate-data:
      client-key-data:
EOF

gsutil rm -r gs://tas-creds-$environment_name
gsutil mb gs://tas-creds-$environment_name
gsutil versioning set on gs://tas-creds-$environment_name
gsutil cp -r gke/secrets/$environment_name gs://tas-creds-$environment_name

gsutil rm -r gs://tas-config-$environment_name
gsutil mb gs://tas-config-$environment_name
gsutil versioning set on gs://tas-config-$environment_name
gsutil cp -r gke/tas-pipelines-config/$environment_name gs://tas-config-$environment_name

gsutil rm -r gs://tas-state-$environment_name
gsutil mb gs://tas-state-$environment_name
gsutil versioning set on gs://tas-state-$environment_name
