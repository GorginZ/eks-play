FROM python:3.13.0a2-alpine3.19 as ci-infra
#gcloud needs python 
RUN wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
RUN unzip terraform_1.6.6_linux_amd64.zip && rm terraform_1.6.6_linux_amd64.zip
RUN mv terraform /usr/bin/terraform

#install git for getting some tf modules
RUN apk add --no-cache git

#install aws-cli
RUN apk add --no-cache aws-cli
