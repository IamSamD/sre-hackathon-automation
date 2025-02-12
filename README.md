# Hackathon Automation Demo

This demo gives a simple example of a self healing automation. 

It uses Terraform to deploy an example application to AWS ECS.

The ECS task logs to AWS Cloudwatch Logs

An alarm triggers when an error log is seen from the example application

The alarm triggers a lambda that restarts the ECS task

## Usage

Once deployed via Terraform, the load balancers DNS name will be output by Terraform

You can use this DNS name to make a GET request to the `trigger-alert` endpoint.

This will trigger an error log which in turn will trigger the alarm. 

This allows us to easily demo a simple example of an automated self healing mechanism.

```
curl http:<LOAD_BALANCER_DNS_NAME>/trigger-alert
```