#requires -Version 5.0
$java_folder = "$env:ProgramFiles\Java"
$jdk_folder = "$java_folder\jdk-18"
$bin_folder = "$jdk_folder\bin"



# Prevent script from running on 32-bit systems as Java does not support them.
if (![Environment]::Is64BitProcess) {
  Write-Error -Message 'The latest version of Java requires a 64-bit version of Windows.'
  $host.EnterNestedPrompt()
  return
}



# Create Java folder.
New-Item -ItemType directory -Path $java_folder -Force
Set-Location $java_folder



# Download JDK ZIP & SHA256 Files
$jdk_url = 'https://download.java.net/java/GA/jdk18.0.1.1/65ae32619e2f40f3a9af3af1851d6e19/2/GPL/openjdk-18.0.1.1_windows-x64_bin.zip'
$jdk_sha_url = 'https://download.java.net/java/GA/jdk18.0.1.1/65ae32619e2f40f3a9af3af1851d6e19/2/GPL/openjdk-18.0.1.1_windows-x64_bin.zip.sha256'

$jdk_zip_file = 'jdk.zip'
$jdk_sha_file = 'sha.sha256'

Invoke-WebRequest -Uri $jdk_url -OutFile $jdk_zip_file
Invoke-WebRequest -Uri $jdk_sha_url -OutFile $jdk_sha_file



# Compare JDK Zip Checksum to SHA256 File
$computed_hash = (Get-FileHash -Algorithm SHA256 -Path $jdk_zip_file).Hash
$existing_hash = Get-Content -Path $jdk_sha_file

if ($computed_hash -ne $existing_hash) {
  Remove-Item -Path $jdk_zip_file
  Remove-Item -Path $jdk_sha_file

  Write-Error -Message 'The checksum of the downloaded JDK is incorrect. The file may be corrupt.'
  Write-Error -Message 'This might be resolved by re-running this script.'
  $host.EnterNestedPrompt()
  return
}



# Extract Archive
Expand-Archive -Path $jdk_zip_file
Remove-Item -Path $jdk_zip_file
Remove-Item -Path $jdk_sha_file



# Set Environment Variables
$path = [Environment]::GetEnvironmentVariable('Path', 'Machine')
[Environment]::SetEnvironmentVariable('Path', $path + ';' + $bin_folder, 'Machine')

[Environment]::SetEnvironmentVariable('JAVA_HOME', $jdk_folder, 'Machine')
[Environment]::SetEnvironmentVariable('JDK_HOME', '%JAVA_HOME%', 'Machine')
[Environment]::SetEnvironmentVariable('JRE_HOME', '%JAVA_HOME', 'Machine')



Write-Host -Object 'Success! Java has been installed.'
$host.EnterNestedPrompt()
