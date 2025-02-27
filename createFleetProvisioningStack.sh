#!/bin/bash

#******************************************************************************
# * @file           : FleetProvisioning.sh
# * @brief          : 
# ******************************************************************************
# * @attention
# *
# * <h2><center>&copy; Copyright (c) 2022 STMicroelectronics.
# * All rights reserved.</center></h2>
# *
# * This software component is licensed by ST under BSD 3-Clause license,
# * the "License"; You may not use this file except in compliance with the
# * License. You may obtain a copy of the License at:
# *                        opensource.org/licenses/BSD-3-Clause
# ******************************************************************************

# Define the CloudFormation stack name
# Define the YAML file
TEMPLATE_FILE="template.yaml"
CONFIG_FILE="config.json"

# Define output file paths
CERT_DIR="claim-certs"
CERT_PEM_OUTFILE="$CERT_DIR/claim.pem.crt"
CSR_FILE="$CERT_DIR/csr.pem"

# Create the directory if it doesn't exist
mkdir -p "$CERT_DIR"

# URL to download the certificate
AWS_CA_CERT_URL="https://www.amazontrust.com/repository/SFSRootCAG2.pem"

# Download the certificate and save it to the specified directory
curl -o "$CERT_DIR/SFSRootCAG2.pem" "$AWS_CA_CERT_URL"
echo "AWS CA Certificate downloaded and saved to $CERT_DIR/SFSRootCAG2.pem"

# Read provisioningTemplateName from config.json
STACK_NAME=$(grep -oP '(?<="StackName": ")[^"]*' "$CONFIG_FILE")
PROVISION_TEMPLATE_NAME=$(grep -oP '(?<="provisioningTemplateName": ")[^"]*' "$CONFIG_FILE")
THING_GROUP_NAME=$(grep -oP '(?<="thing_group_name": ")[^"]*' "$CONFIG_FILE")

if [ -z "$STACK_NAME" ]; then
    echo "Error: provisioningTemplateName not found in $CONFIG_FILE"
    exit 1
fi

echo "Using STACK_NAME: $STACK_NAME"
echo "Thing Group Name: $THING_GROUP_NAME"

# Check that the stack name argument is provided
if [ -z "$STACK_NAME" ]; then
    usage
fi

aws iot create-thing-group  --thing-group-name "$THING_GROUP_NAME"

# Update the Default value in template.yaml
TEMPLATE_FILE="template.yaml"
sed -i.bak "s/Default: 'DEFULT_FP_TemplateName'/Default: '$PROVISION_TEMPLATE_NAME'/" "$TEMPLATE_FILE"

echo "Updated DEFULT_FP_TemplateName value to $PROVISION_TEMPLATE_NAME in $TEMPLATE_FILE"

# Create the CloudFormation stack
echo "Creating CloudFormation stack: $STACK_NAME..."
aws cloudformation create-stack --stack-name $STACK_NAME --template-body file://$TEMPLATE_FILE --capabilities CAPABILITY_NAMED_IAM

# Check the creation status
echo "Waiting for CloudFormation stack creation to complete..."
aws cloudformation wait stack-create-complete --stack-name $STACK_NAME

# Verify the stack status
STATUS=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query "Stacks[0].StackStatus" --output text)
if [ "$STATUS" == "CREATE_COMPLETE" ]; then
    echo "CloudFormation stack $STACK_NAME created successfully."
else
    echo "Error: Stack $STACK_NAME creation failed with status: $STATUS"
    exit 1
fi

# Create the claim-certs directory if it doesn't exist
mkdir -p $CERT_DIR

# Step 1: Create the certificate and keys
echo "Creating certificate and keys..."
CERT_ARN=$(aws iot create-certificate-from-csr \
  --certificate-signing-request file://$CSR_FILE \
  --certificate-pem-outfile "$CERT_PEM_OUTFILE" \
  --set-as-active \
  --query 'certificateArn' \
  --output text)

if [ -z "$CERT_ARN" ]; then
    echo "Error: Failed to create certificate."
    exit 1
else
    echo "Certificate created successfully with ARN: $CERT_ARN"
fi

# Extract the default values for ProvisioningTemplateName and GGTokenExchangeRoleName from template.yaml
POLICY_NAME=$(grep -A 2 "GGProvisioningClaimPolicyName:" $TEMPLATE_FILE | grep "Default:" | awk '{print $2}' | tr -d "'")

echo "POLICY_NAME : "$POLICY_NAME

# Check if values were found
if [ -z "$POLICY_NAME" ]; then
    echo "Failed to extract Policy Name from $TEMPLATE_FILE."
    exit 1
fi

# Step 2: Attach the IoT policy to the claim certificate
echo "Attaching policy $POLICY_NAME to the certificate..."
aws iot attach-policy --policy-name "$POLICY_NAME" --target "$CERT_ARN"

if [ $? -eq 0 ]; then
    echo "Policy $POLICY_NAME successfully attached to certificate."
else
    echo "Error: Failed to attach policy."
    exit 1
fi

echo "Certificate and policy setup completed."

