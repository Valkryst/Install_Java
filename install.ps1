# Prevent script from running on 32-bit systems as Java does not support them.
if (![Environment]::Is64BitProcess) {
  Write-Error -Message 'The latest version of Java requires a 64-bit version of Windows.'
  $host.EnterNestedPrompt()
  return
}



# Request Admin Privilieges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (!$isAdmin) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-File `"$PSCommandPath`""
    Exit
}



$openjdk = @(
    @{
        version = "20.0.2";
        zip_url = "https://download.java.net/java/GA/jdk20.0.2/6e380f22cbe7469fa75fb448bd903d8e/9/GPL/openjdk-20.0.2_windows-x64_bin.zip";
        sha_url = "https://download.java.net/java/GA/jdk20.0.2/6e380f22cbe7469fa75fb448bd903d8e/9/GPL/openjdk-20.0.2_windows-x64_bin.zip.sha256"
    },
    @{
        version = "19.0.2";
        zip_url = "https://download.java.net/java/GA/jdk19.0.2/fdb695a9d9064ad6b064dc6df578380c/7/GPL/openjdk-19.0.2_windows-x64_bin.zip";
        sha_url = "https://download.java.net/java/GA/jdk19.0.2/fdb695a9d9064ad6b064dc6df578380c/7/GPL/openjdk-19.0.2_windows-x64_bin.zip.sha256"
    },
    @{
        version = "18.0.2";
        zip_url = "https://download.java.net/java/GA/jdk18.0.2/f6ad4b4450fd4d298113270ec84f30ee/9/GPL/openjdk-18.0.2_windows-x64_bin.zip";
        sha_url = "https://download.java.net/java/GA/jdk18.0.2/f6ad4b4450fd4d298113270ec84f30ee/9/GPL/openjdk-18.0.2_windows-x64_bin.zip.sha256"
    },
    @{
        version = "17.0.2";
        zip_url = "https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_windows-x64_bin.zip";
        sha_url = "https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_windows-x64_bin.zip.sha256"
    },
    @{
        version = "16.0.2";
        zip_url = "https://download.java.net/java/GA/jdk16.0.2/d4a915d82b4c4fbb9bde534da945d746/7/GPL/openjdk-16.0.2_windows-x64_bin.zip";
        sha_url = "https://download.java.net/java/GA/jdk16.0.2/d4a915d82b4c4fbb9bde534da945d746/7/GPL/openjdk-16.0.2_windows-x64_bin.zip.sha256"
    },
    @{
        version = "15.0.2";
        zip_url = "https://download.java.net/java/GA/jdk15.0.2/0d1cfde4252546c6931946de8db48ee2/7/GPL/openjdk-15.0.2_windows-x64_bin.zip";
        sha_url = "https://download.java.net/java/GA/jdk15.0.2/0d1cfde4252546c6931946de8db48ee2/7/GPL/openjdk-15.0.2_windows-x64_bin.zip.sha256"
    },
    @{
        version = "14.0.2";
        zip_url = "https://download.java.net/java/GA/jdk14.0.2/205943a0976c4ed48cb16f1043c5c647/12/GPL/openjdk-14.0.2_windows-x64_bin.zip";
        sha_url = "https://download.java.net/java/GA/jdk14.0.2/205943a0976c4ed48cb16f1043c5c647/12/GPL/openjdk-14.0.2_windows-x64_bin.zip.sha256"
    },
    @{
        version = "13.0.2";
        zip_url = "https://download.java.net/java/GA/jdk13.0.2/d4173c853231432d94f001e99d882ca7/8/GPL/openjdk-13.0.2_windows-x64_bin.zip";
        sha_url = "https://download.java.net/java/GA/jdk13.0.2/d4173c853231432d94f001e99d882ca7/8/GPL/openjdk-13.0.2_windows-x64_bin.zip.sha256"
    },
    @{
        version = "12.0.2";
        zip_url = "https://download.java.net/java/GA/jdk12.0.2/e482c34c86bd4bf8b56c0b35558996b9/10/GPL/openjdk-12.0.2_windows-x64_bin.zip";
        sha_url = "https://download.java.net/java/GA/jdk12.0.2/e482c34c86bd4bf8b56c0b35558996b9/10/GPL/openjdk-12.0.2_windows-x64_bin.zip.sha256"
    },
    @{
        version = "11.0.2";
        zip_url = "https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_windows-x64_bin.zip";
        sha_url = "https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_windows-x64_bin.zip.sha256"
    }
)



# Determine which version to install.
Write-Host -Object "The following OpenJDK versions are available:`n"

for ($i = 0 ; $i -ne $openjdk.length ; $i++) {
    Write-Host -Object "`t$i) $($openjdk[$i].version)"
}

while (1) {
    $jdk_version = Read-Host "Enter a number to install the corresponding version"


    try {
        [int]::TryParse($jdk_version, [ref]$jdk_version)
    } catch [System.Management.Automation.PSInvalidCastException] {
        Write-Host -Object "You must enter an integer."
        continue
    }


    if(($jdk_version -lt 0) -or ($jdk_version -ige $openjdk.length)) {
        Write-Host -Object "The value must be within the range of 0 to $($openjdk.length - 1)."
        continue
    }

    $openjdk = $openjdk[$jdk_version]

    break
}



$java_folder = "$env:ProgramFiles\Java"

# Windows seems to auto-rename folders like "20.0.0" to "20".
$jdk_folder = "$java_folder\jdk\jdk-" + $openjdk.version
if ($jdk_folder.EndsWith(".0.0")) {
    $jdk_folder = $jdk_folder.Substring(0, $jdk_folder.Length - 4)
}

$bin_folder = "$jdk_folder\bin"



# Create Java folder.
New-Item -ItemType directory -Path $java_folder -Force
Set-Location $java_folder



# Download JDK ZIP & SHA256 Files
$jdk_zip_file = 'jdk.zip'
$jdk_sha_file = 'sha.sha256'

Invoke-WebRequest -Uri $openjdk.zip_url -OutFile $jdk_zip_file
Invoke-WebRequest -Uri $openjdk.sha_url -OutFile $jdk_sha_file



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
