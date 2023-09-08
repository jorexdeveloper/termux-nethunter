# Install Kali NetHunter in Termux

Script to install Kali NetHunter in Termux.

## Contents

- [Contents](#contents)
  - [Features](#features)
  - [Installation](#installation)
  - [How to Login](#how-to-login)
    - [Login Information](#login-information)
  - [How to Start a VNC Server](#how-to-start-a-vnc-server)
    - [How to Connect to the VNC Server](#how-to-connect-to-the-vnc-server)
  - [How to Install XFCE and VNC Server for Mini and Nano Installations](#how-to-install-xfce-and-vnc-server-for-mini-and-nano-installations)
  - [How to Uninstall Kali NetHunter](#how-to-uninstall-kali-nethunter)
  - [Bugs](#bugs)
- [License](#license)

### Features

 - Interactive Installation.
 - Color output (256-color terminals).
 - Shows progress during extraction.
 - Install Kali Nethunter in custom directory (**Experimental**).
 - Automatic configuration (i.e set root password).
 - Customize default shell before startup.
 - Set zone information before startup (Match local time).
 - Fixed issues [#1][i1] [#2][i2] [#3][i3] [#4][i4].
 - Other optimizations and improvements.

### Installation

Download and execute the installer script (**install-nethunter.sh**) or copy and paste below commands in **Termux**.

```
apt-get update -y && apt-get install wget -y && wget -O install-nethunter.sh https://raw.githubusercontent.com/jorexdeveloper/termux-nethunter/main/install-nethunter.sh && bash install-nethunter.sh
```

The program also displays help information with option `-h` or `--help` to guide you further.

### How to Login

After successful installation, run command `nh` or `nethunter` to start Kali NetHunter.

#### Login Information

| User/Login         | Password |
|--------------------|----------|
| root (super user)  | **root** |
| kali (normal user} | **kali** |

### How to Start a VNC Server

Start Kali NetHunter and run command `vnc` to start the VNC server. The server will be started at localhost (`127.0.0.1`).

The program also displays help information with option `-h` or `--help` to guide you further.

##### Note: For **Mini** and **Nano** intallations, a **VNC server** and **Desktop Environment** may not be pre-installed. You can install them as shown [below](#install-xfce-and-vnc-server-for-mini-and-nano-installations).

#### How to Connect to the VNC Server

After starting the VNC server, install [NetHunter KeX](https://store.nethunter.com/en/packages/com.offsec.nethunter.kex/), or a **VNC viewer** of your choice and login with below information. (Use current user name and **VNC password** which is set on first run of `vnc`)

| User  | Display  | Port | Address     |
|-------|----------|------|-------------|
| Root  | :0       | 5900 | localhost:0 |
| Other | :1       | 5901 | localhost:1 |

### How to Install XFCE and VNC Server for Mini and Nano Installations

Copy and paste below commands in **NetHunter**.

```
sudo apt install -y tigervnc-standalone-server kali-desktop-xfce
```

### How to Uninstall Kali NetHunter

To uninstall Kali Nethunter, copy and paste below commands in **Termux**. Replace `$HOME/kali-{armhf,arm64}` with the directory where you installed the rootfs if custom directory was specified.

```
rm -rI $PREFIX/bin/nh $PREFIX/bin/nethunter $HOME/kali-{armhf,arm64}
```

### Bugs

Currently, **changing the name of the rootfs directory** causes some programs to fail with error message;

```
<command>: cannot execute: required file not found
```

You are welcome to join and fix available bugs. Please let me know in the [issues section][i0] if you find any other bugs.

## LICENSE

```
    Copyright (C) 2023  Jore

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
```


[i0]: https://github.com/jorexdeveloper/termux-nethunter/issues
[i1]: https://github.com/jorexdeveloper/termux-nethunter/issues/1
[i2]: https://github.com/jorexdeveloper/termux-nethunter/issues/2
[i3]: https://github.com/jorexdeveloper/termux-nethunter/issues/3
[i4]: https://github.com/jorexdeveloper/termux-nethunter/issues/4
