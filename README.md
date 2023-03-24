# 🐶 Image data retriever

This proof of concept downloads image data from multiple public clouds, performs minimal processing, and stores the data in AWS S3.
Other processes can download this raw data quickly without requiring any authentication credentials for the clouds.

## Authentication

GitHub's OpenID authentication is used for each cloud to avoid storing credentials in GitHub secrets.
Refer to the documentation at GitHub to set this up for [AWS](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services), [Azure](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure), and [GCP](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-google-cloud-platform)

For AWS, no additional variables are required other than what appears in the workflow file.

Azure needs `AZURE_CLIENT_ID`, `AZURE_SUBSCRIPTION_ID`, and `AZURE_TENANT_ID`.
These appear during the OpenID configuration process within Azure's portal.

Google needs `GCP_SERVICE_ACCOUNT` and `GCP_WORKLOAD_IDENTITY_PROVIDER`.
These appear during the OpenID configuration process.

## Detailed overview

The GitHub Actions in this repository start by downloading image data from AWS, Azure, and GCP.
Minimal processing is done for each cloud provider:

* AWS
  * Remove `Images` key from each region's JSON data
  * Join all regions together into one JSON list (and add a `Region` field to each record)
* Azure
  * No processing other than compacting the JSON
* GCP
  * No processing other than compacting the JSON

Once the job finishes downloading data, the data is compressed with `zstd` and stored in a GitHub artifact.
The next step of the workflow uploads the data to a bucket in S3.
