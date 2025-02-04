
# Fleet Provisioning for AWS IoT and STM32 Microcontroller

## Overview
This project provides an automated setup for AWS IoT Fleet Provisioning for STM32 Microcontrollers devices. By using CloudFormation, claim certificates, and an IoT provisioning template, this project enables scalable, secure, and automated provisioning of IoT devices, allowing them to self-register and maintain secure communication through AWS IoT.

## Prerequisites
- **[B-U585I-IOT02A](https://www.st.com/en/evaluation-tools/b-u585i-iot02a.html)**
- **[AWS Account](https://aws.amazon.com/)**: Access to an AWS account with permissions to manage IAM, IoT, and CloudFormation stacks.
- **[AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)**: Install and [configure](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html) the AWS CLI on your local machine.
- **[Git Bash](https://git-scm.com/downloads)**: Required for Windows users to provide a Unix-like shell compatible with the scripts.

## Files

1. **createFleetProvisioningStack.sh**
   - Creates the required CloudFormation stack to provision resources in AWS for IoT Greengrass and Fleet Provisioning.

2. **updateConfig.sh**
   - Parses `template.yaml` and uses AWS CLI to collect and create required fields, automatically populating `config.json`.

3. **gen_csr.sh**
   - Generate a csr file.

4. **config.json**
   - Configuration file for AWS IoT Greengrass and Fleet Provisioning, holding AWS region, claim certificate paths, endpoints, and provisioning details.

5. **template.yaml**
   - CloudFormation template for provisioning Greengrass and Fleet Provisioning resources.

6. **deviceCleanup.sh**
   - Cleans up IoT resources by deleting the IoT Thing, its certificates.

---

## Setup Steps

### 1. Clone this Repository
On a PC with AWS CLI installed, clone this repository:

```bash
git clone https://github.com/stm32-hotspot/STM32_FleetProvisioning
cd STM32_FleetProvisioning
```
### 3. Clone stm32u585_aws_iot_reference
```bash
git clone https://github.com/SlimJallouli/aware_demo.git --recurse-submodules
```

### 2. Generate a CSR
use the gen_csr.sh to generate private-key.pem,  public-key.pem and a csr.pem file

### 3. Update config.json
open config.json with a text editor and update:
- StackName
- ThingGroupName
- provisioningTemplate

### 4. Generate Required Configuration
Run `updateConfig.sh` to parse `config.json` and populate `template.yaml` with required AWS endpoint and configuration data:

```bash
./updateConfig.sh
```
### 6. Create the CloudFormation Stack
Use `createFleetProvisioningStack.sh` to automte the setup of AWS IoT Fleet Provisioning by creating a CloudFormation stack, generating claim certificates, and attaching the necessary IoT policies.

createFleetProvisioningStack.sh reads the STACK_NAME from config.json

```bash
./createFleetProvisioningStack.sh
```
> Note: AWS CloudFormation Stack template can be modified in `template.yaml` 

### 7. Rebuild the project
- open the aware_demo with STM32CubeIDE
- open **B-U585I-IOT02A\Common\app\FleetProvisioning\fleet_provisioning_config.h** 
- replace the ***#define democonfigPROVISIONING_TEMPLATE_NAME "ProvisionTemplate"*** with your provision template name
- rebuild, flash and run the project

### 8. Upload the certificate to STM32 
- open claim.pem.crt on text editor

- construct the command as following and then se serial terminal to send it to STM32
```
pki import key fleetprov_claim_cert
-----BEGIN CERTIFICATE-----
MIIEpAIBAAKCAQEA1WUKouJ2A6kTUkFKTyydStQ78zSsYMZK13SbnkcyPl8e5tiU
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
PFSoDLLTuqihG33SKAGGJVdARcCAQNYgycVe6ZpPLVzR+feZu3G5Vg==
-----END CERTIFICATE-----
```
### 9. Upload the private key on to STM32
- open private-key.pem on text editor

- construct the command as following and then se serial terminal to send it to STM32
```
pki import key fleetprov_claim_key
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA1WUKouJ2A6kTUkFKTyydStQ78zSsYMZK13SbnkcyPl8e5tiU
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
PFSoDLLTuqihG33SKAGGJVdARcCAQNYgycVe6ZpPLVzR+feZu3G5Vg==
-----END RSA PRIVATE KEY-----
```
### Set Config

```
conf set provision_state 0
conf set wifi_ssid <Your Wi-Fi SSID>
conf set wifi_credential <Your Wi-Fi Password>
conf set thing_group_name <Yout ThingGroupName>
conf commit
```
