# Install NetHunter Termux

Install Kali NetHunter in Termux.

## Installation

Download and execute the installer script (**install-nethunter.sh**) or copy and paste below commands in **Termux**.

```
apt update -y && apt upgrade -y && apt install wget -y && wget --output-document=install-nethunter.sh https://raw.githubusercontent.com/jorexdeveloper/Install-NetHunter-Termux/main/install-nethunter.sh && bash install-nethunter.sh
```

## How to login

After successful installation, run command `nh` or `nethunter` to start kali nethunter. Login as user **kali** with password **kali** i.e

```
localhost login: kali
Password: kali
┌──(kali㉿localhost)-[~]
└─$
```

## How to login as root user

Before you login as root user **for the first time**, you need to **set a password for the root user**. To do that, login as normal user (kali as shown above) then enter the below command and set a password for the root user.

```
sudo passwd root
```

i.e

```
┌──(kali㉿localhost)-[~]
└─$ sudo passwd root
New password: <your_password>
Retype new password: <your_password>
passwd: password updated successfully

┌──(kali㉿localhost)-[~]
└─$
```

Now on the next login, login as user **root** and password **<your_password>**.

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

### Note: *For *Mini* and *Nano* intallations, the vnc server and a desktop environment may not be pre-installed. You can install them as shown below.*

## Install XFCE and VNC Server for Mini and Nano installations

Copy and paste below commands in **NetHunter**.

```
sudo apt install -y xfce* tightvncserver dbus-x11
```

## How to Uninstall NetHunter

To uninstall Kali Nethunter, copy and paste below commands.

```
rm -ri $PREFIX/bin/nh $PREFIX/bin/nethunter $HOME/kali-{armhf,arm64}
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
