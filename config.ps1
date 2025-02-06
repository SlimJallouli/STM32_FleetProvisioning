# Load the JSON configuration file
$config = Get-Content -Raw -Path "config.json" | ConvertFrom-Json

# Define the serial port and baud rate
$portName = $config.portName  # Read portName from the JSON configuration
$baudRate = 115200   # Replace with the appropriate baud rate

# Open the serial port
$serialPort = New-Object System.IO.Ports.SerialPort $portName, $baudRate, "None", 8, "One"
$serialPort.Open()

# Function to send a command over the serial port
function Send-Command {
    param (
        [string]$command
    )
    $serialPort.WriteLine($command)
    Start-Sleep 1
}

# Function to send file content over the serial port
function Send-FileContent {
    param (
        [string]$filePath
    )
    $content = Get-Content -Raw -Path $filePath
    $serialPort.WriteLine($content)
    Start-Sleep 3
}

# Send the specified commands from the JSON configuration
Write-Host "Setting mqtt_endpoint $($config.mqtt_endpoint)"
Send-Command "conf set mqtt_endpoint $($config.mqtt_endpoint)"

Write-Host "Setting mqtt_port $($config.mqtt_port)"
Send-Command "conf set mqtt_port $($config.mqtt_port)"

Write-Host "Setting provision_state $($config.provision_state)"
Send-Command "conf set provision_state $($config.provision_state)"

Write-Host "Setting wifi_ssid $($config.wifi_ssid)"
Send-Command "conf set wifi_ssid $($config.wifi_ssid)"

Write-Host "Setting wifi_credential $($config.wifi_credential)"
Send-Command "conf set wifi_credential $($config.wifi_credential)"

Write-Host "Setting thing_group_name $($config.thing_group_name)"
Send-Command "conf set thing_group_name $($config.thing_group_name)"

Write-Host "Setting certificateFile"
Send-Command "pki import cert fleetprov_claim_cert"
Send-FileContent $config.certificateFile

Write-Host "Setting privateKeyFile"
Send-Command "pki import key fleetprov_claim_key"
Send-FileContent $config.privateKeyFile

Write-Host "Setting root_ca_cert"
Send-Command "pki import cert root_ca_cert"
Send-FileContent $config.root_ca_cert

Write-Host "commit"
Send-Command "conf commit"

Write-Host "reset"
Send-Command "reset"

# Close the serial port
$serialPort.Close()
