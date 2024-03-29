This repository contains a PowerShell script which downloads & installs Java from the OpenJDK site, and configures necessary environment variables.

## Requirements

To use this script, you must be running [PowerShell](https://github.com/PowerShell/PowerShell/releases) on a 64-bit version of windows.

## Usage

[Download](https://www.wikihow.com/Download-a-File-from-GitHub) the [PowerShell script](https://github.com/Valkryst/Install_Java/blob/main/install.ps1) and then run it either by double-clicking the file or by right-clicking and selecting "Run with PowerShell".

It may take some time to run. Depending on the speed of your computer and internet connection.

When the script completes, and if there are no error messages, you can open a new terminal and type `java --version`. If Java was successfully installed, you should see a message similar to the following:

```
openjdk 17 2021-09-14
OpenJDK Runtime Environment (build 17+35-2724)
OpenJDK 64-Bit Server VM (build 17+35-2724, mixed mode, sharing)
```

If you already had a version of Java installed, then you may need to manually edit your _Environment Variables_ and remove any old JDK paths from the `Path` variable.
