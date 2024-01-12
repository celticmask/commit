# Commit application (cronjob)

## Prerequisites
The following are needed to run locally:
* python ver.3.9
* pip

## Building and deploying docker
- Build image
    `sudo docker build -t <aws_account_id>.dkr.ecr.eu-central-1.amazonaws.com/commit:latest ./`
- Login to ECR
    `aws ecr get-login-password | sudo docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.eu-central-1.amazonaws.com`
- Push image to the ECR
    `sudo docker push <aws_account_id>.dkr.ecr.eu-central-1.amazonaws.com/commit:latest`

## Running app locally
`pip install --no-cache-dir --upgrade -r /app-code/requirements.txt`
`python main.py --url=<https://website.com/...> --bucket=<bucket_name>`

## Running docker locally
`sudo docker run --rm -e SERVER_URL=<website.com/...> -e BUCKET_NAME=<bucket_name> <aws_account_id>.dkr.ecr.eu-central-1.amazonaws.com/commit:latest`

