echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt-get -y install apt-transport-https ca-certificates
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update 
sudo apt-get -y install google-cloud-sdk
sudo gcloud auth login #Log in as the user that you want to create your VM with
sudo gcloud init #Initialization procedure, the explanations given are pretty good, so I will not add further documentation here
#Create your VM with firewall rules to allow traffic. This is only sample code, as your project name and zone might be different and 96 quotes require a quota increase. RAM is not important for this kind of project. Cost for this instance is 0.88$/hour.
sudo gcloud beta compute --project=the-best-project-ever-251714 instances create instance-1 --zone=europe-west1-b --machine-type=custom-96-88576 --subnet=default --network-tier=PREMIUM --no-restart-on-failure --maintenance-policy=TERMINATE --preemptible --service-account=170239206144-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --min-cpu-platform="Intel Skylake" --tags=http-server,https-server --image=ubuntu-1804-bionic-v20190918 --image-project=ubuntu-os-cloud --boot-disk-size=200GB --boot-disk-type=pd-ssd --boot-disk-device-name=instance-1 --reservation-affinity=any
sudo gcloud compute --project=the-best-project-ever-251714 firewall-rules create default-allow-http --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:80 --source-ranges=0.0.0.0/0 --target-tags=http-server
sudo gcloud compute --project=the-best-project-ever-251714 firewall-rules create default-allow-https --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:443 --source-ranges=0.0.0.0/0 --target-tags=https-server
#Now, create a Google Cloud bucket to store all your results! This buckets name is mdpr. Results will be uploaded here at the end of each generation.
sudo gsutil mb gs://mdpr-bucket/
#SSH into your instance now. Once again, this is sample code. For this instance, the key is igemrocks! (with the exclamation point)
sudo gcloud beta compute --project "the-best-project-ever-251714" ssh --zone "europe-west1-b" "instance-1"
#When in your instance, login to your google cloud account (installed by default). You need to do this to upload your files
sudo gcloud auth login
#Clone this repository (git is installed by default)
git clone https://github.com/NKalavros/mdpr-full
#Move everything to the top level and delete that folder
mv mdpr-full/* .
rm -r mdpr-full
#While the quality of life changes are not implemented, change the password to my own in order to obtain access to HADDOCK's dependencies
nano install_all_fast.sh
#Install everything, this script takes about 15 minutes to run
sudo bash install_all_fast.sh
#Source the files needed, mod them too
chmod 777 ~/.bashrc
chmod 777 ~/.bash_profile
source ~/.bashrc
source ~/.bash_profile
#Run the mutate_seqs.py script in your VM.
python3 mutate_seqs.py
#If you've already started, then you need something different
#Get the previous files
gsutil -m cp gs://mdpr-bucket/* .
#Start new generations
python3 mutate_seqs.py -cont 1
#Code for non preemptible instance
gcloud beta compute --project=the-best-project-ever-251714 instances create instance-2 --zone=europe-west1-b --machine-type=n1-highcpu-96 --subnet=default --network-tier=PREMIUM --maintenance-policy=MIGRATE --service-account=170239206144-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/cloud-platform --tags=http-server,https-server --image=ubuntu-1804-bionic-v20190918 --image-project=ubuntu-os-cloud --boot-disk-size=200GB --boot-disk-type=pd-ssd --boot-disk-device-name=instance-2 --reservation-affinity=any
