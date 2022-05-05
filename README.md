# aws-profile-sso-to-token
This is a simple script that allows you to generate an AWS access key and secret access token from an AWS SSO profile and save it to a new AWS profile.  This is useful when using certain frameworks like Terraform or Serverless Framework where SSO profiles may not work.

This is largely based on these similar utilities:

[linaro-its/aws2-wrap](https://github.com/linaro-its/aws2-wrap)  
[claytonsilva/aws-cred-restore](https://github.com/claytonsilva/aws-sso-cred-restore)  


However, those require users to have python/pip installed whereas this one can be downloaded and run with no external dependencies.

## Install
```bash
curl https://raw.githubusercontent.com/dderman-tsi/aws-profile-sso-to-token/HEAD/aws-profile-sso-to-token.sh \
  --output /usr/local/bin/aws-profile-sso-to-token.sh && chmod +x /usr/local/bin/aws-profile-sso-to-token.sh
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
