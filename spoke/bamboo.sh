#!/bin/bash
#######################################################################################################################
# Summary:
#   Deployment script to be executed as part of the 04-child-network solution
# Usage:
#   Run as a script file within the aws-child-network Bamboo pipeline
# Notes:
#   - Critical input variable is Account ID
#######################################################################################################################

#############
# VARIABLES #
#############

export AWS_ACCESS_KEY_ID=${bamboo_aws_access_key_id}
export AWS_SECRET_ACCESS_KEY=${bamboo_aws_secret_access_key}
export http_proxy=http://ceala05956.emea.zurich.corp:8080
export https_proxy=http://ceala05956.emea.zurich.corp:8080
export TAGS="{ owneremail = \"${bamboo_owneremail}\", \
creatoremailaddress = \"${bamboo_creatoremailaddress}\", \
ccoesupported = \"${bamboo_ccoesupported}\", \
env = \"${bamboo_environment}\", \
bu = \"${bamboo_bu}\", \
bucode = \"${bamboo_bucode}\", \
terraform = \"true\", \
dataclassification = \"${bamboo_dataclassification}\", \
cloudgovernanceid = \"${bamboo_cloudgovernanceid}\", \
financecontactforalerts = \"${bamboo_financecontactforalerts}\", \
costcenter = \"${bamboo_cost_center}\", \
appid = \"${bamboo_appid}\", \
appname = \"${bamboo_appname}\", \
country = \"${bamboo_country}\", \
orderid = \"${bamboo_jira_issue_key}\", \
project = \"${bamboo_project}\", \
}"

#Work out vpc_size
case ${bamboo_number_of_ip_hosts} in
'27')
    vpc_size='32'
    ;;
'59')
    vpc_size='64'
    ;;
'123')
    vpc_size='128'
    ;;
'251')
    vpc_size='256'
    ;;
esac
echo ${vpc_size}

####################
# JiraSD functions #
####################
function commentJiraSD() {
    comment=${1}
    curl -D- -u ${bamboo_api_user}:${bamboo_apipassword} \
        -X POST --data '{"body": "'"$comment"'"}' -H "Content-Type: application/json" \
        https://jira.zurich.com/rest/api/2/issue/${bamboo_jira_issue_key}/comment
}

function transitionJiraSD() {
    transition=${1}
    curl -D- -u ${bamboo_api_user}:${bamboo_apipassword} \
        -X POST --data '{"transition": {"id": "'"$transition"'"}}' -H "Content-Type: application/json" \
        https://jira.zurich.com/rest/api/2/issue/${bamboo_jira_issue_key}/transitions
    if [[ $transition -eq 1001 ]]; then
        exit 1
    fi
}
####################

rm -rf .terraform plan.out plan.out.json terraform.tfstate delete-eip.zip

echo ""
echo "TERRAFORM INIT"
echo ""
terraform init -no-color -input=false \
    -backend-config="key=${bamboo_account_id}/${bamboo_region}/${bamboo_bucode}-${bamboo_project}-${bamboo_environment}-${bamboo_vpc_name}.tfstate" \
    -backend-config="bucket=ccoe-ccp-sharedservices-terraform-state" \
    -backend-config="region=eu-west-1" -backend-config="encrypt=true" \
    -backend-config="role_arn=arn:aws:iam::762167912344:role/terraform-state"

echo "backend-config:"
echo "bucket=ccoe-ccp-sharedservices-terraform-state"
echo "key=${bamboo_account_id}/${bamboo_region}/${bamboo_bucode}-${bamboo_project}-${bamboo_environment}-${bamboo_vpc_name}.tfstate"
echo "region=eu-west-1"
echo "encrypt=true"
echo "role_arn=arn:aws:iam::762167912344:role/terraform-state"

echo "Terraform destroy = "${bamboo_DESTROY}
if [[ "${bamboo_DESTROY}" != "true" ]]; then
    if [[ "${bamboo_tf_action}" == "plan" ]]; then
        echo ""
        echo "TERRAFORM PLAN"
        echo ""
        terraform plan -no-color -input=false -out=plan.out \
            --var role_to_assume_arn=arn:aws:iam::${bamboo_account_id}:role/TransitGatewayRole \
            --var=region=${bamboo_region} \
            --var=customer=${bamboo_bucode} \
            --var=project=${bamboo_project} \
            --var=environment=${bamboo_environment} \
            --var="tags=$TAGS" \
            --var=bam_username=${bamboo_bam_username} \
            --var=bam_password=${bamboo_bam_password} \
            --var=bam_base_url=${bamboo_bam_base_url} \
            --var=vpc_size=${vpc_size} \
            --var=vpc_suffix=${bamboo_vpc_name}

    #terraform-compliance -f ../../tests -p plan.out

    elif [[ "${bamboo_tf_action}" == "apply" ]]; then
        echo ""
        echo "TERRAFORM APPLY"
        echo ""
        terraform apply --auto-approve -no-color -input=false \
            --var role_to_assume_arn=arn:aws:iam::${bamboo_account_id}:role/TransitGatewayRole \
            --var=region=${bamboo_region} \
            --var=customer=${bamboo_bucode} \
            --var=project=${bamboo_project} \
            --var=environment=${bamboo_environment} \
            --var="tags=$TAGS" \
            --var=bam_username=${bamboo_bam_username} \
            --var=bam_password=${bamboo_bam_password} \
            --var=bam_base_url=${bamboo_bam_base_url} \
            --var=vpc_size=${vpc_size} \
            --var=vpc_suffix=${bamboo_vpc_name}
        export RETURN_CODE=$?

        ##########################
        # Update JiraSD status   #
        ##########################
        if [[ $RETURN_CODE -ne 0 ]]; then
            echo "Terraform failed"
            commentJiraSD "Terraform failed, please investigate."
            transitionJiraSD 1001
        else
            echo "SUCCESS!"
            commentJiraSD "Terraform succeeded for account '$bamboo_account_id'"
            transitionJiraSD 1011
            sleep 5
            commentJiraSD "Network config has been applied."
        fi
    fi
elif [[ "${bamboo_DESTROY}" == "true" ]]; then
    terraform destroy --auto-approve -no-color -input=false -lock=true \
        --var role_to_assume_arn=arn:aws:iam::${bamboo_account_id}:role/TransitGatewayRole \
        --var=region=${bamboo_region} \
        --var=customer=${bamboo_bucode} \
        --var=project=${bamboo_project} \
        --var=environment=${bamboo_environment} \
        --var="tags=$TAGS" \
        --var=bam_username=${bamboo_bam_username} \
        --var=bam_password=${bamboo_bam_password} \
        --var=bam_base_url=${bamboo_bam_base_url} \
        --var=vpc_size=${vpc_size} \
        --var=vpc_suffix=${bamboo_vpc_name}
    export RETURN_CODE=$?
    ##########################
    # Update JiraSD status   #
    ##########################
    if [[ $RETURN_CODE -ne 0 ]]; then
        echo "[ERROR] Terraform destroy failed"
        commentJiraSD "Terraform destroy failed, please investigate."
        transitionJiraSD 1001
    else
        echo "SUCCESS!"
        commentJiraSD "Terraform destroy succeeded for account '$bamboo_account_id'"
        transitionJiraSD 1011
        sleep 5
        commentJiraSD "Network config has been removed."
        exit 0
    fi
else
    echo "Terraform failed"
    commentJiraSD "Terraform failed, please investigate."
    transitionJiraSD 1001
fi
