dse-jenkins-tf

Repo for DevOps to create jenkins server in AWS.
-------------------------------------------------

Assuming that, no network is designed in the aws region on which we are installing jenkins.

server needs to connect to internet and get required packages to install jenkins

Resources that are being created as part of this:

VPC 

Subnet - In created VPC

Securitygroup - Allowing traffic on ports 22 and 8080

InternetGateway - Attached to created subnet

Route table - Default route to outside traffic

Create instance and install Jenkins in created network

Module managed by Atmecs 