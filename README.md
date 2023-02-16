# aws-infra

# Terraform AWS VPC Module

This Terraform module creates a Virtual Private Cloud (VPC) in Amazon Web Services (AWS), with 2 subnets (public and private) in each of 2 availability zones. It also creates internet gateways and route tables to allow the subnets to communicate with each other and the internet.

## Prerequisites

    1. AWS account
    2. Terraform installed

## Usage

Set the required variables in a separate file or pass them via CLI. Refer to variables.tf for a list of variables and their descriptions.

1. Run **terraform init** to initialize the project.
2. Run **terraform plan** to see the changes to be applied.
3. Run **terraform apply** to apply the changes.

## Terraform AWS Provider Configuration

This code snippet is a configuration for the Terraform AWS provider. Terraform is an open-source infrastructure as code software tool that allows users to define and provision a data center infrastructure using a high-level configuration language. The AWS provider allows Terraform to interact with resources in Amazon Web Services (AWS) such as EC2 instances, VPCs, and S3 buckets.

The configuration sets the region and profile values for the AWS provider. The region parameter specifies the AWS region to operate in, and the profile parameter specifies the named profile to use for AWS credentials. The values for var.aws_region and var.aws_profile are expected to be provided by the user.

To use this configuration, you will need to have Terraform installed on your local machine and an AWS account set up. You can copy this code into a file with a .tf extension and use the terraform init command to initialize the AWS provider, followed by terraform plan to preview the resources to be created, and terraform apply to create the resources.

## Terraform AWS Data Source Configuration

This code snippet is a Terraform configuration block used to fetch data about the available AWS availability zones. The data source block begins with the data keyword, followed by the data source name, which in this case is "aws_availability_zones". The data source block then includes one argument:

state: this is an optional argument that filters the availability zones based on their state. In this example, the value "available" is used to fetch only the availability zones that are currently available.
The data source block fetches information about the availability zones that can be used to configure other Terraform resources in the same module or configuration file. For example, this data source can be used to configure an auto-scaling group to launch instances in multiple availability zones for better resiliency and fault tolerance.

## Terraform AWS Resource Configuration

This code snippet is a Terraform configuration block used to create an Amazon Virtual Private Cloud (VPC) resource in AWS. The aws_vpc resource block begins with the resource keyword, followed by the resource name, which in this case is "aws_vpc". The resource block then includes two arguments:

cidr_block: this is a required argument that specifies the IP address range for the VPC. The value for this argument is obtained from the vpc_cidr variable, which is an array of IP address ranges.
tags: this is an optional argument that allows you to assign metadata to the VPC resource in the form of key-value pairs. In this example, the VPC is assigned a Name tag with the value "vpc_1".
The resource block creates an AWS VPC resource using the specified IP address range and metadata. Once the VPC is created, it can be used to launch EC2 instances, RDS instances, and other AWS resources within the VPC.
