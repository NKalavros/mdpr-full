echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt-get -y install apt-transport-https ca-certificates
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update 
sudo apt-get -y install google-cloud-sdk
sudo gcloud init
sudo gcloud auth login
sudo gcloud beta compute --project=igem-athens-2019 instances create instance-1 --zone=europe-west1-b --machine-type=n1-standard-16 --subnet=default --network-tier=PREMIUM --maintenance-policy=MIGRATE --service-account=1047569363731-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/cloud-platform --tags=http-server,https-server --image=ubuntu-1804-bionic-v20190813a --image-project=ubuntu-os-cloud --boot-disk-size=100GB --boot-disk-type=pd-standard --boot-disk-device-name=instance-1 --reservation-affinity=any
sudo gcloud beta compute --project "igem-athens-2019" ssh --zone "europe-west1-b" "instance-1" #Key is sandra
#A second, higher end preemptible instance to run some more tests
sudo gcloud beta compute --project=igem-athens-2019 instances create instance-2 --zone=europe-west1-b --machine-type=custom-80-307200 --subnet=default --network-tier=PREMIUM --no-restart-on-failure --maintenance-policy=TERMINATE --preemptible --service-account=1047569363731-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --tags=http-server,https-server --image=ubuntu-1804-bionic-v20190813a --image-project=ubuntu-os-cloud --boot-disk-size=200GB --boot-disk-type=pd-standard --boot-disk-device-name=instance-2 --reservation-affinity=any
