# TERMUX NETHUNTER

Install Kali NetHunter in Termux.

 > Author: Jore

 > Version: 2023.3b

## CONTENTS

 * [FEATURES](#features "List of available features.")
 * [INSTALLATION](#installation "Steps for installation.")
 * [COMMAND LINE OPTIONS](#command-line-options "Available command line options.")
 * [HOW TO LOGIN](#how-to-login "Steps on how to login.")
     * [LOGIN INFORMATION](#login-information "User name and password for logging in.")
 * [HOW TO START THE VNC SERVER](#how-to-start-the-vnc-server "Steps on how to start the VNC server.")
     * [REQUIREMENTS](#requirements "Requirements for starting the VNC server.")
     * [PROCEDURE](#procedure "Procedure for starting the VNC server.")
 * [HOW TO INSTALL XFCE AND VNC SERVER](#how-to-install-xfce-and-vnc-server "Steps on how to install a Desktop Environment and a VNC server.")
 * [HOW TO UNINSTALL KALI NETHUNTER](#how-to-uninstall-kali-nethunter "Steps on how to uninstall Kali NetHunter.")
 * [BUGS](#bugs "Bug information")
 * [LICENSE](#license "Program license.")

## FEATURES

  * Anti-root fuse.
  * Interactive Installation.
  * Color output. (if supported)
  * Command line options. (see [here](#command-line-options "Available command line options."))
     * Install in custom directory.
     * Install only i.e no configurations. (**use with caution**)
     * Configurations only (**if already installed**)
     * Modify color output.
     * Uninstall.
  * Creates a VNC wrapper (see [here](#how-to-start-the-vnc-server "Steps on how to start the VNC server."))
  * Automatic configurations. (i.e binding necessary directories)
  * Access System and Termux commands. (i.e termux-api commands)
  * Customize default shell and zone information before startup.
  * Other optimizations and improvements.

## INSTALLATION

 1. Update installed packages by executing the following commands.

 ```bash
 pkg update && pkg upgrade
 ```

 2. Install `wget`. (`curl` is an alternative)

 ```bash
 pkg install wget
 ```

 3. Download the installer script. (**install-nethunter.sh**)

```bash
wget -O install-nethunter.sh https://raw.githubusercontent.com/jorexdeveloper/termux-nethunter/main/install-nethunter.sh
```

 4. Now execute the installer script.

```bash
bash install-nethunter.sh --help
```

If you are lazy like me, just copy and paste the below commands in Termux.

```bash
pkg update -y && pkg upgrade -y && pkg install -y wget && wget -O install-nethunter.sh https://raw.githubusercontent.com/jorexdeveloper/termux-nethunter/main/install-nethunter.sh && bash install-nethunter.sh --help
```

## COMMAND LINE OPTIONS

Execute the installer script with `--help` to see available command line options.

```bash
bash install-nethunter.sh --help
```

## HOW TO LOGIN

After successful installation, run command `nh` or `nethunter` to start Kali NetHunter.

### LOGIN INFORMATION

| Login              | Password |
|--------------------|----------|
| root (super user)  | **root** |
| kali (normal user} | **kali** |

## HOW TO START THE VNC SERVER

#### REQUIREMENTS:

 1. Make sure you have a **VNC server** and **Desktop environment** installed. (The **full installation** has them pre-installed, see [here](#how-to-install-xfce-and-vnc-server "Steps on how to start the VNC server."))

 2. Install [NetHunter KeX](https://store.nethunter.com/en/packages/com.offsec.nethunter.kex/ "Kali NetHunter Store"), or a **VNC viewer** of your choice.

#### PROCEDURE:

 1. [Login in Kali NetHunter](#how-to-login "Steps on how to login.") and run command `vnc` to start the VNC server. The server will be started at **localhost** (`127.0.0.1`).

 > **Tip:** The program also displays help information with option `-h` or `--help` to guide you further.

 2. On the first run, you will be prompted for a password. You will use this password to login and connect to the VNC server.

 3. Now open NetHunter KeX and login with the password in step 2.

| User  | Display  | Port | Address     |
|-------|----------|------|-------------|
| Root  | :0       | 5900 | localhost:0 |
| Other | :1       | 5901 | localhost:1 |

## HOW TO INSTALL XFCE AND VNC SERVER

 1. [Login in Kali NetHunter](#how-to-login "Steps on how to login.").

 2. Make a full upgrade of your system.

```bash
sudo apt update && sudo apt full-upgrade
```

 3. Run the following commands.

```bash
sudo apt install dbus-x11 tigervnc-standalone-server kali-desktop-xfce
```
 > **Tip:** This will take a while, just make sure you don't exit Termux during the installation or you might run into some problems later.

## HOW TO UNINSTALL KALI NETHUNTER

To uninstall Kali NetHunter, run the installer script (**install-nethunter.sh**) with option `--uninstall`.

**NOTE:** If you installed Kali NetHunter in a custom directory, also supply the path to the directory as an argument.

```bash
bash install-nethunter.sh --uninstall
```

## BUGS

All currently known bugs are fixed.

Please let me know in the [issues section](https://github.com/jorexdeveloper/termux-nethunter/issues "The issues section.") if you find any.

## LICENSE

```txt
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
