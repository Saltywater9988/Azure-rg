# Login to Azure Subscription
echo
echo "Logging in to Azure Subscription"
az login > /dev/null
az account set --subscription "Cloud Services Shared Serv Dev"
echo "Logged in to Azure Subscription successfully"

# Login via Service Principal
echo
echo "Logging in via Service Principal"
SPN_APP_ID=$(az keyvault secret show --vault-name "kv-dwp-cds-dev-ss" --name "prdSsDeploymentspnAppId" --query value | sed -e 's/^"//' -e 's/"$//')
SPN_CLIENT_SECRET=$(az keyvault secret show --vault-name "kv-dwp-cds-dev-ss" --name "prdSsDeploymentspnClientSecret"  --query value | sed -e 's/^"//' -e 's/"$//')
az login --service-principal -u $SPN_APP_ID -p $SPN_CLIENT_SECRET --tenant "96f1f6e9-1057-4117-ac28-80cdfe86f8c3" > /dev/null
az account set --subscription "Shared Services Non-Production"
echo "Logged in via Service Principal Successfully"

# Set Terraform Environment Variables
export ARM_CLIENT_ID=$SPN_APP_ID
export ARM_CLIENT_SECRET=$SPN_CLIENT_SECRET
export ARM_SUBSCRIPTION_ID=$(az account show --query id | sed -e 's/^"//' -e 's/"$//')
export ARM_TENANT_ID=$(az account show --query tenantId | sed -e 's/^"//' -e 's/"$//')
az account show

# install correct terraform version
TF_VERSION=$(cat .tf_version | awk '{$1=$1};1')
rm /usr/local/bin/terraform
wget https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip --no-check-certificate && \
unzip ./terraform_${TF_VERSION}_linux_amd64.zip -d /usr/local/bin/
rm ./terraform_${TF_VERSION}_linux_amd64.zip

# Deploy Terraform Solution
echo "Initialising Terraform"
terraform init
echo "Terraform Initialization Completed"
echo "Progressing you to select your next action from an array of options below"
PS3='Choose your option: '
actions=("terraform plan module" "terraform apply module" "terraform plan everything" "terraform apply everything" "quit")
select act in "${actions[@]}"; do
    case $act in 
        "terraform plan module")
            echo "enter module name"
            read input
            echo "Generating Infrastructure Plan For $input module"
            terraform plan -target module.$input
            ;;
        "terraform apply module")
            echo "enter module name"
            read input
            echo "Deploying Infrastructure For $input module"
            terraform apply -target module.$input
            ;;
        "terraform plan everything")
            echo "generating infrastructure plan"
            # echo "Initialising Terraform Deployment"
            # terraform init
            terraform plan
            # echo "init completed"
            echo "plan completed"
            ;;
        "terraform apply everything")
            echo "generating infrastructure plan"
            # echo "Initialising Terraform Deployment"
            # terraform init
            terraform plan
            # echo "init completed"
            echo "plan completed"
            ;;
        "quit")
            echo "exit upon user request"
            exit
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
# terraform plan
# echo "Deploying Production DR Shared Services Resources"
# terraform apply
# echo
# echo "Terraform Deployment Complete"
