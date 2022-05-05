#!/bin/bash
set -e

exit_error() {
  RED='\033[0;31m'
  echo -e "${RED}$1"
  exit 1
}

print_message() {
  GREEN='\033[0;32m'
  NC='\033[0m'
  echo -e "${GREEN}$(date '+%Y-%m-%d %T')${NC} $1"
}

empty_string=""

source_profile="$1"
dest_profile="$2"

if [ "$source_profile" = "$empty_string" ]; then exit_error "Source and destination profile must be supplied:\n./aws_profile_get_keys.sh <source_profile> <destination_profile>"; fi

print_message "Login with sso profile"
aws sso login --profile $source_profile

# Get source profile sso variables needed to generate access key credentials
print_message "Loading source profile ($source_profile) variables"
sso_start_url=$(aws configure get sso_start_url --profile $source_profile)
sso_region=$(aws configure get sso_region --profile $source_profile)
sso_account_id=$(aws configure get sso_account_id --profile $source_profile)
sso_role_name=$(aws configure get sso_role_name --profile $source_profile)
region=$(aws configure get region --profile $source_profile)
output="json"

# I intentionally use grep instead of jq here since some people may not have jq installed

# Search for source profile access token
print_message "Search for source profile access token"
for file in ~/.aws/sso/cache/*.json; do
  json=$(cat $file || $empty_string)
  json=$(echo "${json//[,]/\n}" || $empty_string)
  token=$(echo $json | grep -o '"accessToken": "[^"]*' | grep -o '[^"]*$' || $empty_string)
  startUrl=$(echo $json | grep -o '"startUrl": "[^"]*' | grep -o '[^"]*$' || $empty_string)
  if [ "$startUrl" = "$sso_start_url" ]; then
    sso_access_token=$token
    break
  fi
done

if [ "$sso_access_token" = "$empty_string" ]; then exit_error "The access token for profile ($source_profile) could not be found"; fi

# Generate role credentials
print_message "Generate role credentials"
creds_json=$(aws sso get-role-credentials \
  --profile $source_profile \
  --role-name $sso_role_name \
  --account-id $sso_account_id \
  --access-token $sso_access_token \
  --region $sso_region \
  --output $output)
creds_json=$(echo "${creds_json//[,]/\n}")
access_key_id=$(echo $creds_json | grep -o '"accessKeyId": "[^"]*' | grep -o '[^"]*$')
secret_access_key=$(echo $creds_json | grep -o '"secretAccessKey": "[^"]*' | grep -o '[^"]*$')
session_token=$(echo $creds_json | grep -o '"sessionToken": "[^"]*' | grep -o '[^"]*$')

# Congigure destination profile using access keys
print_message "Configure destination profile using access keys"
aws configure --profile $dest_profile set aws_access_key_id $access_key_id
aws configure --profile $dest_profile set aws_secret_access_key $secret_access_key
aws configure --profile $dest_profile set region $region
aws configure --profile $dest_profile set output $output
aws configure --profile $dest_profile set aws_session_token $session_token

# Test the destination profile
# print_message "Test the destination profile"
# aws s3 ls --profile $dest_profile

print_message "Destination profile ($dest_profile) successfully updated."
