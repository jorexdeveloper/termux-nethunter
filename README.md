# Install NetHunter Termux

Install Kali NetHunter in Termux.

## Contents

- [Contents](#contents)
  - [Improvements](#improvements)
  - [Installation](#installation)
  - [How to Login](#how-to-login)
    - [Login Information](#login-information)
    - [How to Login as Root User](#how-to-login-as-root-user)
  - [How to Start VNC Server](#how-to-start-vnc-server)
  - [How to Install XFCE and VNC Server for Mini and Nano Installations](#how-to-install-xfce-and-vnc-server-for-mini-and-nano-installations)
  - [How to Uninstall NetHunter](#how-to-uninstall-nethunter)
  - [Fixed Issues in the File System](#fixed-issues-in-the-file-system)
    - [Fix Sudo](#fix-sudo)
    - [Fix Bash Profile](#fix-bash-profile)
    - [Fix Display](#fix-display)
    - [Fix Audio](#fix-audio)
    - [Fix DNS](#fix-dns)
    - [Fix JDK](#fix-jdk)
    - [Fix Zshrc](#fix-zshrc)
    - [Fix UID and GID](#fix-uid-and-gid)
    - [Set Default Shell](#set-default-shell)
    - [Set Zone Information](#set-zone-information)
- [License](#license)

### Improvements

 - Shows progress during extraction
 - Color output for supported terminals. (256-color terminals)
 - You can now install Kali Nethunter in a directory of your choice.
 - Automatically fixes some issues with the file system. (see [here](#fixed-issues-in-the-file-system))
 - Customize default shell before startup.
 - Set Time Zone before startup.
 - Fixed issues [#1][i1] [#2][i2] [#3][i3] [#4][i4].
 - Other improvements.

### Installation

Download and execute the installer script (**install-nethunter.sh**) or copy and paste below commands in **Termux**.

```
apt update -y && apt upgrade -y && apt install wget -y && wget --output-document=install-nethunter.sh https://raw.githubusercontent.com/jorexdeveloper/Install-NetHunter-Termux/main/install-nethunter.sh && bash install-nethunter.sh
```

The program also displays below help information with option (`-h | --help`) to guide you further.

```
Usage: nethunter.sh [option]... [DIRECTORY]

Install Kali NetHunter in the specified directory or ~/kali-<sys_arch> if unspecified.
The specified directory MUST be within Termux or the default directory is used.

Options:
  --no-check-certificate
          This option is passed to 'wget' while downloading files.
  -h, --help
          Print this message and exit.
  -v. --version
          Print version and exit.

For more information, visit <https://github.com/jorexdeveloper/Install-NetHunter-Termux>.
```

### How to Login

After successful installation, run command `nh` or `nethunter` to start Kali NetHunter.

#### Login Information

|                   |          |
|-------------------|----------|
| User/Login        | **kali** |
| Password          | **kali** |

i.e

```
localhost login: kali
Password: kali
┌──(kali㉿localhost)-[~]
└─$
```

#### How to login as root user

Before you login as root user **for the first time**, you need to **set a password for the root user**. To do that, login as normal user (kali as shown above) then run the command below to set a password for the root user.

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

### How to Start VNC Server

After starting nethunter, as shown above, use command `vnc` in NetHunter to start VNC server. The server is started at localhost (`127.0.0.1`) on display and port shown below.

| User  | Display  | Port |
|-------|----------|------|
| Root  | :0       | 5900 |
| Other | :1       | 5901 |

The program also displays below help information with option (`-h | --help`) to guide you further.

```
Usage: vnc [option]...

Start VNC Server.

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

  > Note: For **Mini** and **Nano** intallations, the **VNC server** and a **Desktop Environment** may not be pre-installed. You can install them as shown [below](#install-xfce-and-vnc-server-for-mini-and-nano-installations).

After starting the VNC server, install [NetHunter KeX](https://store.nethunter.com/en/packages/com.offsec.nethunter.kex/), or a VNC viewer of your choice and login. (Use current user name and **VNC password** which is set on first run of `vnc`)

### How to Install XFCE and VNC Server for Mini and Nano Installations

Copy and paste below commands in **NetHunter**.

```
sudo apt install -y xfce* tightvncserver dbus-x11
```

### How to Uninstall NetHunter

To uninstall Kali Nethunter, copy and paste below commands in **Termux**. Replace `$HOME/kalifs-{armhf,arm64}` with the directory where you installed the File System. (if custom directory was used)

```
rm -rf $PREFIX/bin/nh $PREFIX/bin/nethunter $HOME/kali-{armhf,arm64}
```

### Fixed Issues in the File System

#### Fix Sudo

 - Fixes sudo on start.
 - Adds user **kali** to sudoers list.
 - Fixes issue [here](https://bugzilla.redhat.com/show_bug.cgi?id=1773148)

#### Fix Bash Profile

 - Prevents creation of links in read only file system

#### Fix Display

 - Sets a static display across the system. (see [here](#how-to-start-vnc-server))

#### Fix Audio

 - Sets the pulse audio server at (`127.0.0.1`) to enable audio output.

#### Fix DNS

 - Sets DNS Settings below.

```
nameserver 8.8.8.8
nameserver 8.8.4.4
```

#### Fix JDK

 - Sets **JAVA_HOME** and adds it to **PATH**.

#### Fix Zshrc

 - Sets `~/.zshrc` file to `/etc/skel/.zshrc`.

#### Fix UID and GID

 - Changes **UID** and **GID** of user **kali** to that of Termux.

#### Set Default Shell

 - Sets the default shell for user **kali** if one of;

```
"bash" "zsh" "fish" "dash" "tcsh" "csh" "ksh"
```

#### Set Zone Information

 - Sets zone information as required (possibly to match device time). It must be in format `COUNTRY/CITY` i.e `America/New_York`.

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

[i1]: https://github.com/jorexdeveloper/Install-NetHunter-Termux/issues/1
[i2]: https://github.com/jorexdeveloper/Install-NetHunter-Termux/issues/2
[i3]: https://github.com/jorexdeveloper/Install-NetHunter-Termux/issues/3
[i4]: https://github.com/jorexdeveloper/Install-NetHunter-Termux/issues/4
