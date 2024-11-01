<h1 align="center">TERMUX NETHUNTER</h1>

<div align="center";background-color:black;border:3px solid black;border-radius:6px;margin:5px 0;padding:2px 5px">
<img src="./logo.webp"
    alt="Image could not be loaded!"
    style="color:red;background-color:black;font-weight:bold"/>
</div>

Are you a linux fan or do you just love playing with the terminal and executing cool commands, just to look like a tech genius? Well, for whatever reason it is that you want to install linux on your phone, I got you covered.

Installing linux on your phone might not make you a hacker, but it will certainly make you look and feel like one.

With this guide, you will be able to run a full linux system, including every linux command you can think of and install different PC software, all on your phone! Wait that's not all, you can run a desktop environment and enjoy the pc graphical interface and probably try to hack into NASA using your phone like the guy in that one movie.

Did I mention that you do not require root access to do all this? All you have to do is follow these simple installation instructions and you are a few keystrokes away from running all the cool programs created by the linux community.

<details>
<summary>Contents</summary>

- [Installation](#installation "Installation process.")
  - [How to install](#how-to-install "How to install.")
- [Launch & set up](#launch--set-up "Launch and set up.")
  - [How to launch](#how-to-launch "How to launch.")
  - [How to install desktop and vnc server](#how-to-install-desktop-and-vnc-server "How to install desktop and vnc server.")
- [Login](#login "Login process.")
  - [How to start vnc server](#how-to-start-vnc-server "How to start vnc server.")
  - [How to connect to vnc server](#how-to-connect-to-vnc-server "How to connect to vnc server.")
- [Have fun](#have-fun "Congragulations!")
- [Uninstallation](#uninstallation "Uninstallation process.")
  - [How to uninstall](#how-to-uninstall "How to uninstall.")
- [FAQ](#faq "Frequently asked questions.")
- [License](#license "License")

</details>

## Installation

### How to install

Download and install the [termux app](https://fdroid.org/packages/com.termux "Download termux app") on your phone, then open it and execute the following commands.

1.  Upgrade termux packages

```bash
pkg update && pkg upgrade
```

2.  Install `wget`

```bash
pkg install wget
```

3.  Download install script

```bash
wget -O install-nethunter.sh https://raw.githubusercontent.com/jorexdeveloper/termux-nethunter/main/install-nethunter.sh
```

4.  Execute install script

```bash
bash install-nethunter.sh
```

> The install script displays usage information if parsed the `--help` option.

It's probably a good idea to inspect the install script from projects you don't yet know. You can do that by downloading the install script, looking through it so everything looks fine before running it.

If you are lazy like me, you can just copy and paste the commands below in termux.

```bash
pkg update -y && pkg upgrade -y && pkg install -y wget && wget -O install-nethunter.sh https://raw.githubusercontent.com/jorexdeveloper/termux-nethunter/main/install-nethunter.sh && bash install-nethunter.sh
```

<details>

<summary>Features</summary>

- anti-root fuse
- interactive installation
- color output (if supported)
- command line options
  - install in custom directory
  - install without configurations
  - apply configurations only
  - modify color output
  - uninstall
- creates vnc wrapper
- automatic configurations
- provides access to system and termux commands
- customize default shell and zone information during installation
- minor optimizations and tweaks

</details>

## Launch & set up

After successful installation, you need to launch the system and make a few set ups.

### How to launch

Launch the system by executing the following commands.

```bash
nethunter root
```

or with a shorter version

```bash
nh root
```

You shall be logged in as the **root user**. You can always login as another user by replacing **root** with their user name.

### How to install desktop and vnc server

Now you need to install a desktop environment, as it is not pre-installed and a vnc server which will be used for viewing and interacting with your desktop environment.

[Launch](#how-to-launch "How to launch.") the system and execute the following commands.

1.  Upgrade system packages

```bash
apt update && apt full-upgrade
```

2.  Install vnc server

```bash
apt install tigervnc-standalone-server dbus-x11 sudo
```

3. Install desktop

```bash
apt install kali-desktop-xfce
```

This command will take a while to complete, grab a coffee and make sure keep termux open during the installation or you might run into some problems later.

## Login

Now all that's left is to login into the system and start playing around with some commands. To do that, you need to start a vnc server in the system and connect to it through a vnc viewer.

### How to start vnc server

[Launch](#how-to-launch "How to launch.") the system and execute the following commands.

```bash
vnc
```

> The vnc command displays usage information if parsed the `help` option.

On the first run of the command above, you will be prompted for a **vnc password**. This is the password that will be used to securely connect to the vnc server, in the vnc viewer.

### How to connect to vnc server

To connect to the vnc server, you will need to download and install a vnc viewer app of your choice. I recommend [AVNC](https://f-droid.org/packages/com.gaurav.avnc "Download AVNC app.") in this case.

[Start the vnc server](#how-to-start-vnc-server "How to start vnc server.") and **minimize the termux app**.

Now open the vnc viewer app, click add server and fill in with the following details:

**Name**

```txt
Kali Desktop
```

**Host**

```txt
localhost
```

**Port**

The default display port differs for the **root user** and **other users**, don't ask me why, I just got here.

| user        | port |
| ----------- | ---- |
| root user   | 5900 |
| other users | 5901 |

**Password**

Enter the **vnc password** you set when [starting the vnc server](#how-to-start-vnc-server "How to start vnc server.") for the first time.

## Have fun

If you managed to get this far without any problems, congratulations! Linux now is installed on your phone and it's time to let you continue the exploration journey on your own.

The possibilities are endless and the only limits that exist are the ones you set up for yourself.

You might wan't to google for some cool commands and programs to execute or even when get you stuck, good luck.

## Uninstallation

If for some reason you need to uninstall the system from termux, just follow the steps below.

### How to uninstall

Simply execute the [install script](#how-to-install "How to install.") again in termux with the option `--uninstall`.

```bash
bash install-nethunter.sh --uninstall
```

If you installed the system in a custom directory, supply the path to the installation directory as an additional argument.

## FAQ

If you got some hickups during the installation or have some burning questions, you are probably not the first one. Feel free to document them in the [issues section](https://github.com/jorexdeveloper/termux-nethunter/issues "The issues section.")

However, a few frequently asked questions have been answered below.

### What happens if termux has root access?

This guide assumes that termux has no root access and the only root privileges that exist are those simulated in the installed system.

However, if you have tried following the steps above with root access in termux, then you have probably not succeeded because installing and running the system with root access in termux can have unintended effects, and should only be done when you are sure of what you are doing or you might end up **damaging your device**.

For that reason, I added an **anti-root fuse** to the install script that prevents the installation process if termux has root access.

There should not be a good enough reason to launch the system when termux has root access because harmless root privileges are still simulated in the system with help of proot.

#### Work around

If you **don't mind damaging your device** (probably making it unusable) and are **ready to get your hands dirty**, this section might resonate.

Disabling the anti-root fuse will require a deeper understanding of the install script and the installation process. You will need to edit the install script as follows:

- Find and comment the call to the function checking root access.

Not very helpful, is it? That because **this is definitely a bad idea and you are completely liable for any unintended effects of this action**.

Just remember, I am mostly lazy and would never implement an anti-root fuse for absolutely no reason.

## License

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
