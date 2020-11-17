
fly --target gini login --concourse-url http://gini-web.default.svc.cluster.local:8080 --username test --password test
#fly -t gini sync -c http://gini-web.default.svc.cluster.local:8080

fly -t gini sp -p create-dns  -c data/pipelines/gcp/create-dns.yml -l ci-vars/common.yml -n
fly -t gini sp -p create-gke-cluster -c data/pipelines/gcp/gke-cluster.yml -l ci-vars/common.yml -n
fly -t gini sp -p install-crt-mgr -c data/pipelines/gcp/install-crt-mgr.yml -l ci-vars/common.yml -n
fly -t gini sp -p install-nginx -c data/pipelines/gcp/install-nginx.yml -l ci-vars/common.yml -n
fly -t gini sp -p install-ext-dns -c data/pipelines/gcp/install-ext-dns.yml -l ci-vars/common.yml -n
fly -t gini sp -p install-harbor -c data/pipelines/gcp/install-harbor.yml -l ci-vars/common.yml -n
fly -t gini sp -p install-TAS3 -c data/pipelines/gcp/tas4k8s.yml -l ci-vars/common.yml -n
fly -t gini unpause-pipeline -p create-dns
