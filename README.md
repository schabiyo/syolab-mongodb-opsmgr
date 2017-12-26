# syolab-mongodb-opsmgr
Concourse pipeline for automatic deployment (including configuration) &amp;  upgrade of Mongo DB Ops Manager on Azure

## Use a local Concourse 

### Step 1 - Install concourse

` $ vagrant init concourse/lite # creates ./Vagrantfile `

` $ vagrant up                  # downloads the box and spins up the VM `

The web server will be running at 192.168.100.4:8080.

### Step 2 - Download the fly CLI

Next step would be to download the fly CLI. Open a brower and point it to: 192.168.100.4:8080. From the page downoad the fly tool and save it locally. Then make sure it is executable by running the following command:

` $ chmod +x fly `

### Step 3 - Target the concourse instance 

` $ fly -t myci login -c http://192.168.100.4:8080 `



## Usage

Coming soon

            
