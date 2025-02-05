
# Fleet Provisioning for AWS IoT and STM32 Microcontroller

## 1. Overview
This project provides an automated setup for AWS IoT Fleet Provisioning for STM32 Microcontrollers devices. By using CloudFormation, claim certificates, and an IoT provisioning template, this project enables scalable, secure, and automated provisioning of IoT devices, allowing them to self-register and maintain secure communication through AWS IoT.

## 2. Prerequisites
- **[B-U585I-IOT02A](https://www.st.com/en/evaluation-tools/b-u585i-iot02a.html)**
- **[AWS Account](https://aws.amazon.com/)**: Access to an AWS account with permissions to manage IAM, IoT, and CloudFormation stacks.
- **[AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)**: Install and [configure](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html) the AWS CLI on your local machine.
- **[Git Bash](https://git-scm.com/downloads)**: Required for Windows users to provide a Unix-like shell compatible with the scripts.
- **OpenSSL**: Required to generate keys and CSR file

## 3. Files
Description of the files on this repository
1. **config.json**
   - Configuration file for Fleet Provisioning.

2. **gen_csr.sh**
   - Uses OpenSSL to generate a private key, public key, and a CSR (Certificate Signing Request) file.

3. **createFleetProvisioningStack.sh**
   - Creates the necessary CloudFormation stack to provision resources in AWS for IoT Fleet Provisioning. It utilizes the CSR file generated by `gen_csr.sh` and the configuration specified in `config.json`.

5. **template.yaml**
   - CloudFormation template for Fleet Provisioning resources. This file is updated by the createFleetProvisioningStack.sh

6. **deviceCleanup.sh**
   - Cleans up IoT resources by deleting the IoT Thing and its certificates.

---

## 4. Setup Steps

### 4.1. Clone the Repositories
Clone these two repositors:

```bash
git clone https://github.com/SlimJallouli/aware_demo.git --recurse-submodules
```
```bash
git clone https://github.com/SlimJallouli/STM32_FleetProvisioning
```

### 4.2. Generate a CSR
```bash
cd STM32_FleetProvisioning
```

use the gen_csr.sh to generate private-key.pem,  public-key.pem and a csr.pem file

```bash
./gen_csr.sh
```

this will create `claim-certs` folder that contains `public.pem.key`, `private.pem.key` and `csr.pem`

### 4.3. Update config.json
open `config.json` with a text editor and update:
- StackName
- ThingGroupName
- provisioningTemplate

### 4.4. Create the CloudFormation Stack
Use `createFleetProvisioningStack.sh` to automte the setup of AWS IoT Fleet Provisioning by creating a CloudFormation stack, generating claim certificates, and attaching the necessary IoT policies.

`createFleetProvisioningStack.sh` reads the `STACK_NAME` and `PROVISION_TEMPLATE_NAME` from `config.json`, use the `claim-certs/csr.pem` file to generate the claim certificate and use the `template.yaml` to for the CloudFormation

```bash
./createFleetProvisioningStack.sh
```
> Note: AWS CloudFormation Stack template can be modified in `template.yaml` 

### 4.5. Rebuild the project
- open the `aware_demo` with STM32CubeIDE
- open `\Common\app\FleetProvisioning\fleet_provisioning_config.h` 
- replace the ***#define democonfigPROVISIONING_TEMPLATE_NAME "ProvisionTemplate"*** with your provision template name
- rebuild, flash and run the project

### 4.6. Upload the certificate to STM32 
- open `claim-certs\claim.pem.crt` on text editor

- construct the command as following and then use serial terminal to send it to STM32
```
pki import cert fleetprov_claim_cert
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
### 4.7. Upload the private key on to STM32
- open `claim-certs\private-key.pem` on text editor

- construct the command as following and then use serial terminal to send it to STM32
```
pki import key fleetprov_claim_key
-----BEGIN EC PRIVATE KEY-----
MHXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX49
AwXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX4r
3CSXXXXXXXXXXXXXXXXXiUQ==
-----END EC PRIVATE KEY-----
```
### 4.8. Set Config

```
conf set provision_state 0
conf set wifi_ssid <Your Wi-Fi SSID>
conf set wifi_credential <Your Wi-Fi Password>
conf set thing_group_name <Your ThingGroupName>
conf commit
reset
```
