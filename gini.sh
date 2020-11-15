
echo "Creating GINI CLUSTER with one node with e2-standard-4 machine in us-west region."
gcloud container clusters create gini --num-nodes=1 -m e2-standard-4

echo "Getting GINI NODES.. looking good "
kubectl get no

echo "GINI Install VMware Concourse. "
helm repo add concourse https://concourse-charts.storage.googleapis.com/
helm install gini concourse/concourse

echo "Install Completed "

while [[ $(kubectl get pods -l app=gini-web -l release=gini  -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True True True" ]]; do echo "Checking for concourse pod" && sleep 1; done
while [[ $(kubectl get pod gini-postgresql-0 -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for postgresql" && sleep 1; done

echo "Concouse is up and running.. Ready to FLY .. "
kubectl get po

echo "Creating Concourse vars as Kubernetes Secets and will be used in our Launch Pod"
#path to concouse var files. in this case i am running form tf4k8s-pipeline folder

kubectl create secret generic concourse-create-vars \
--from-file=../secrets/create-cluster.yml \
--from-file=../secrets/install-external-dns.yml \
--from-file=../secrets/install-certmanager.yml \
--from-file=../secrets/create-dns.yml \
--from-file=../secrets/install-harbor.yml \
--from-file=../secrets/install-nginx-ingress-controller.yml \
--from-file=../secrets/install-tas4k8s.yml

echo "Getting pods state. Looking good"
kubectl get po

echo "Lauching TAS3 pipelines via kubernetes pod.... "
kubectl apply -f launch-pod.yml

#while [[ $(kubectl get pods -l app=launch-pod  -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True True True" ]]; do echo "Checking for concourse pod" && sleep 1; done

echo " Lets check concourse"

export POD_NAME=$(kubectl get pods --namespace default -l "app=gini-web" -o jsonpath="{.items[0].metadata.name}")
echo "Visit http://127.0.0.1:8080 to use Concourse"
kubectl port-forward --namespace default $POD_NAME 8080:8080
