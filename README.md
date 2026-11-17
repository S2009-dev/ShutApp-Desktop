# ⚠️ Archived Project

This repository is archived as I'm currently moving it to Gitlab.  
New repo: https://gitlab.com/S2009/ShutApp-Desktop  
⚠️ This link will be active as soon as possible, when the v2 of the app will be released.

## 💻 ShutApp Desktop

This is the desktop version of ShutApp that allows you to control your PC remotely with an Android device. It will open a WebSocket server on port `7421`.  
**⚠️ I didn't implement any security measures, so don't use this in a public network.**

📱 Don't forget to download the [Android app](https://github.com/S2009-dev/ShutApp) too !

## ⚙️ Installation

ShutApp is available for [Windows](#️-windows) and [Linux](#-linux) only.

### 🖥️ Windows

Open command prompt and run the following command to install ShutApp Desktop:

```bash
curl -s -o %TEMP%\windows.bat "https://raw.githubusercontent.com/S2009-dev/ShutApp-Desktop/refs/heads/main/installers/windows.bat" && %TEMP%\windows.bat
```

This will install ShutApp Desktop in your `shell:startup` (in order to run it on startup) and open the TCP port `7421` for remote connections.

### 🐧 Linux

Open terminal and run the following command to install ShutApp Desktop:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/S2009-dev/ShutApp-Desktop/refs/heads/main/installers/linux.sh)"
```

This will install ShutApp Desktop in `/usr/local/bin` and create a service to run it on startup.  
**⚠️ You need to open the TCP port `7421` for remote connections.**

## ❤️ Credits

This project was made thanks to the [basic_websocket](https://github.com/PenTaist/basic_websocket) project by [PenTaist](https://github.com/PenTaist).
