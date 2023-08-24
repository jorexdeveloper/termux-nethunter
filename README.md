# Install-NetHunter-Termux

Install Kali NetHunter in Termux.

## Installation

Download and execute the installer script (`install-nethunter.sh`) or copy and paste below commands in **Termux**.

```
apt update -y && apt upgrade -y && apt install wget -y && wget https://raw.githubusercontent.com/jorexdeveloper/Install-NetHunter-Termux/main/install-nethunter.sh && bash install-nethunter.sh
```

The program also displays help information with option (`-h | --help`) to guide you further.

```
Usage: install-nethunter.sh [--no-check-certificate] [-h,--help] [-v,--version]
Options:
  --no-check-certificate
          This option is passed to 'wget' while downloading files.
  -h, --help
          Print this message and exit.
  -v. --version
          Print version and exit.
```

## How to start NetHunter

Once NetHunter has been succesfully downloaded from above, use below commands.

 - `nethunter`              To start NetHunter CLI.
 - `nethunter -r | --root`  To run NetHunter as root user.
 - `nh`                     Shortcut for nethunter command.
 
## How to start VNC server

After starting nethunter, as shown above, use command `vnc` in NetHunter to start vnc server. The server is started at localhost(**127.0.0.1**) with;

| User  | Display | Port |
|-------|---------|------|
| Root  | 0       | 5900 |
| Other | 1       | 5901 |

The program also displays help information with option (`-h | --help`) to guide you further.

```
Usage: vnc [--potrait] [--landscape] [-p,--password] [-s,--start] [-k,--kill]
Options:
  --potrait
          Use potrait orientation.
  --landscape
          Use landscape orientation. (default)
  -p, --password
          Set or change password.
  -s, --start
          Start vncserver. (default if no options supplied)
  -k, --kill
          Kill vncserver.
  -h, --help
          Print this message and exit.
```

***Note:** For *Mini* and *Nano* intallations, a desktop environment may not be pre-installed. You can install a DE of your choice.*

## Install XFCE for Mini and Nano installations

Copy and paste below commands in **NetHunter**.

```
sudo apt install -y xfce* tightvncserver dbus-x11
```

### LICENSE

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
