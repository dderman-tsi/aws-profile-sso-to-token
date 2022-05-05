# aws-profile-sso-to-token
This is a simple script that allows you to generate an AWS access key and secret access token from an AWS SSO profile and save it to a new AWS profile.  This is useful for some frameworks like Terraform and Serverless Framework where SSO authentication may not work.

This is largely based on these similar utilities written in python.

https://github.com/claytonsilva/aws-sso-cred-restore
https://github.com/linaro-its/aws2-wrap

However, those require users to have python/pip installed whereas this one can be downloaded and run with no external dependencies other than `curl`.

## Install
```bash
curl https://raw.githubusercontent.com/dderman-tsi/aws-profile-sso-to-token/main/aws-profile-sso-to-token.sh --output /usr/local/bin/aws-profile-sso-to-token.sh && chmod +x /usr/local/bin/aws-profile-sso-to-token.sh
```

## How to Run
```bash
aws-profile-sso-to-token.sh <source-aws-sso-profile> <destination-token-based-profile>
```

## Example
```bash
aws-profile-sso-to-token.sh my_sso_profile my_token_based_profile
AWS_PROFILE=my_token_based_profile aws s3 ls
```
