#
# Deploy Cloud SQL database and GCE instance
#

$terraformloc = "C:\Terraform\terraform"
$tfvars_file = "${PSScriptRoot}\variables.tfvars"
$apply = $args[0]

# set current project in the SDK
$vars = convertfrom-stringdata (get-content ./variables.tfvars -raw)
$project = $vars.project

Write-Output "Current project is ${project}"

$cmd = "gcloud config set project ${project}"
Invoke-Expression $cmd

# destroy
if ($apply -eq "destroy") {
	$cmd = "${terraformloc} destroy -var-file=${tfvars_file}"
	Write-Output "Running terraform destroy..."
	Invoke-Expression $cmd
	exit
}	

# init module
$cmd = "${terraformloc} init"
Write-Output "Running terraform init..."
Invoke-Expression $cmd

# plan module
$cmd = "${terraformloc} plan -var-file=${tfvars_file}"
Write-Output "Running terraform plan..."
Invoke-Expression $cmd

# apply module
if ($apply -eq "apply") {
	$cmd = "${terraformloc} apply -var-file=${tfvars_file}"
	Write-Output "Running terraform apply..."
	Invoke-Expression $cmd
} else {
	Write-Output "Apply not selected, planning only"
}