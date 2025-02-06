#!/bin/bash

# Load the JSON configuration file
config_file="config.json"

# Check if the configuration file exists
if [[ ! -f "$config_file" ]]; then
    echo "Error: Configuration file $config_file does not exist."
    exit 1
fi

# Parse the JSON configuration file using grep and awk
mqtt_endpoint=$(grep -Po '"mqtt_endpoint":.*?[^\\]",' "$config_file" | awk -F ': "' '{print $2}' | tr -d '",')
mqtt_port=$(grep -Po '"mqtt_port":\s*[0-9]+' "$config_file" | awk -F ': ' '{print $2}')
provision_state=$(grep -Po '"provision_state":.*?[^\\],?' "$config_file" | awk -F ': ' '{print $2}' | tr -d ',')
wifi_ssid=$(grep -Po '"wifi_ssid":.*?[^\\]",' "$config_file" | awk -F ': "' '{print $2}' | tr -d '",')
wifi_credential=$(grep -Po '"wifi_credential":.*?[^\\]",' "$config_file" | awk -F ': "' '{print $2}' | tr -d '",')
thing_group_name=$(grep -Po '"thing_group_name":.*?[^\\]",' "$config_file" | awk -F ': "' '{print $2}' | tr -d '",')
portName=$(grep -Po '"portName":.*?[^\\]",' "$config_file" | awk -F ': "' '{print $2}' | tr -d '",')
certificateFile=$(grep -Po '"certificateFile":.*?[^\\]",' "$config_file" | awk -F ': "' '{print $2}' | tr -d '",')
privateKeyFile=$(grep -Po '"privateKeyFile":.*?[^\\]",' "$config_file" | awk -F ': "' '{print $2}' | tr -d '",')
rootCa=$(grep -Po '"root_ca_cert":.*?[^\\]+"' "$config_file" | awk -F ': "' '{print $2}' | tr -d '"')

# Check if portName is specified and valid
if [[ -z "$portName" || ! -e "$portName" ]]; then
    echo "Error: Invalid or missing serial port: $portName"
    exit 1
fi

# Function to send a command over the serial port
send_command() {
    echo -e "$1\r" > "$portName"
    sleep 0.1  # Wait for 100 milliseconds between commands
}

# Function to send file content over the serial port
send_file_content() {
    while IFS= read -r line; do
        echo -e "$line\r" > "$portName"
    done < "$1"
    sleep 0.1  # Wait for 100 milliseconds between commands
}

# Send the specified commands from the JSON configuration
send_command "conf set mqtt_endpoint $mqtt_endpoint"
send_command "conf set mqtt_port $mqtt_port"
send_command "conf set provision_state $provision_state"
send_command "conf set wifi_ssid $wifi_ssid"
send_command "conf set wifi_credential $wifi_credential"
send_command "conf set thing_group_name $thing_group_name"

# Import certificates and keys
send_command "pki import cert fleetprov_claim_cert"
send_file_content "$certificateFile"

send_command "pki import key fleetprov_claim_key"
send_file_content "$privateKeyFile"

send_command "pki import cert root_ca_cert"
send_file_content "$rootCa"

# Commit the configuration and reset
send_command "conf commit"
send_command "reset"
