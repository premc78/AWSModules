#!/bin/bash

eval "$(jq -r '@sh "export base_url=\(.bam_base_url) payload=\(.bam_auth_payload) location=\(.bam_region) environment=\(.bam_environment) name=\(.vpc_name) size=\(.vpc_size)"')"

auth_response=$(curl -X POST ${base_url}/rest_login -H "Content-Type: application/json" -d "${payload}" -s -w '\n%{http_code}' )

auth_http_code=$(tail -n1 <<< "$auth_response")  
auth_content=$(sed '$ d' <<< "$auth_response")   

if [[ ${auth_http_code} != "200" ]]; then
    >&2 echo Failed to obtain BAM access token: ${auth_content}
    exit 1
fi

token=$(echo ${auth_content} | jq -r '.access_token')

response=$(curl -X GET -H "Auth: Basic ${token}" -G "${base_url}/CCoE_IPAM_Add/CCoE_IPAM_Add_endpoint" \
    -d location=${location} -d env=${environment} -d name=${name} -d size=${size}  \
    -s -w '\n%{http_code}')

http_code=$(tail -n1 <<< "$response")  
content=$(sed '$ d' <<< "$response")   

if [[ ${http_code} != "200" ]]; then
    >&2 echo BAM API call failed: ${content}
    exit 1
fi

jq -n --arg content "${content}" '{ip_cidr: $content}'
