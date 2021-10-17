"""cloud formation template"""

#from troposphere import (
#  Base64,
#  ec2,
#  GetAtt,
#  Join,
#  Output,
#  Parameter,
#  Ref,
#  Template,
#)

from troposphere import Base64, FindInMap, GetAtt, Join
from troposphere import Parameter, Output, Ref, Template
from troposphere.iam import (
    AccessKey,
    Group,
    LoginProfile,
    PolicyType,
    User,
    UserToGroupAddition,
)
import troposphere.ec2 as ec2

ApplicationPort = "3000"

t = Template()

# t.add_description("Effective DevOps in AWS: HelloWorld web application")

t.add_parameter(Parameter(
  "KeyPair",
  Description="Name of an existing EC2 KeyPair to SSH",
  Type="AWS::EC2::KeyPair::KeyName",
  ConstraintDescription="must be the name of an existing EC2 KeyPair.",
))

t.add_mapping('RegionMap', {
    "us-east-1":      {"AMI": "ami-7f418316"},
    "us-west-1":      {"AMI": "ami-951945d0"},
    "us-west-2":      {"AMI": "ami-16fd7026"},
    "eu-west-1":      {"AMI": "ami-24506250"},
    "sa-east-1":      {"AMI": "ami-3e3be423"},
    "ap-southeast-1": {"AMI": "ami-74dda626"},
    "ap-northeast-1": {"AMI": "ami-dcfa4edd"}
})

t.add_resource(ec2.SecurityGroup(
    "SecurityGroup",
    GroupDescription="Allow SSH and TCP/{} access".format(ApplicationPort),
    SecurityGroupIngress=[
        ec2.SecurityGroupRule(
            IpProtocol="tcp",
            FromPort="22",
            ToPort="22",
            CidrIp="0.0.0.0/0",
        ),
        ec2.SecurityGroupRule(
            IpProtocol="tcp",
            FromPort=ApplicationPort,
            ToPort=ApplicationPort,
            CidrIp="0.0.0.0/0",
        ),
    ],
))

ud = Base64(Join('\n', [
    "#!/bin/bash",
    "sudo yum install --enablerepo=epel -y nodejs",
    "wget http://bit.ly/2vESNuc -O /home/ec2-user/helloworld.js",
    "wget http://bit.ly/2vVvT18 -O /etc/init/helloworld.conf",
    "start helloworld"
]))

ec2_instance = t.add_resource(ec2.Instance(
    "instance",
    ImageId="ami-0e4a9ad2eb120e054:",
    InstanceType="t2.micro",
    SecurityGroups=[Ref("SecurityGroup")],
    KeyName=Ref("KeyPair"),
    UserData=ud,
))


cfnuser = t.add_resource(
    # User("CFNUser", LoginProfile=LoginProfile(Password="Password"))
    User("dyheo", LoginProfile=LoginProfile(Password="Gjeodud@01"))
)

cfnusergroup = t.add_resource(Group("CFNUserGroup"))
cfnadmingroup = t.add_resource(Group("CFNAdminGroup"))

cfnkeys = t.add_resource(AccessKey("CFNKeys", Status="Active", UserName=Ref(cfnuser)))

users = t.add_resource(
    UserToGroupAddition(
        "Users",
        GroupName=Ref(cfnusergroup),
        Users=[Ref(cfnuser)],
    )
)

admins = t.add_resource(
    UserToGroupAddition(
        "Admins",
        GroupName=Ref(cfnadmingroup),
        Users=[Ref(cfnuser)],
    )
)

t.add_resource(
    PolicyType(
        "CFNUserPolicies",
        PolicyName="SecurityGroup",
        Groups=[Ref(cfnadmingroup)],
        PolicyDocument={
  "AWSTemplateFormatVersion" : "2010-09-09",
  "Resources" : {
    "instance" : {
      "Type" : "AWS::EC2::EC2Fleet",
      "DeletionPolicy" : "Retain"
    }
  }
},
    )
)

t.add_output(Output(
    "InstancePublicIp",
    Description="Public IP of our instance.",
    Value=GetAtt("instance", "PublicIp"),
))

t.add_output([
    Output(
        "InstanceId",
        Description="InstanceId of the newly created EC2 instance",
        Value=Ref(ec2_instance),
    ),
    Output(
        "AZ",
        Description="Availability Zone of the newly created EC2 instance",
        Value=GetAtt(ec2_instance, "AvailabilityZone"),
    ),
    Output(
        "PublicIP",
        Description="Public IP address of the newly created EC2 instance",
        Value=GetAtt(ec2_instance, "PublicIp"),
    ),
    Output(
        "PrivateIP",
        Description="Private IP address of the newly created EC2 instance",
        Value=GetAtt(ec2_instance, "PrivateIp"),
    ),
    Output(
        "PublicDNS",
        Description="Public DNSName of the newly created EC2 instance",
        Value=GetAtt(ec2_instance, "PublicDnsName"),
    ),
    Output(
        "PrivateDNS",
        Description="Private DNSName of the newly created EC2 instance",
        Value=GetAtt(ec2_instance, "PrivateDnsName"),
    ),
])

t.add_output(Output(
    "WebUrl",
    Description="Application endpoint",
    Value=Join("", [
        "http://", GetAtt("instance", "PublicDnsName"),
        ":", ApplicationPort
    ]),
))

print(t.to_json())
