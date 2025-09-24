<h1 align="center">TERMUX NETHUNTER</h1>

<div align="center" style="background-color:black;border:3px solid black;border-radius:6px;margin:5px 0;padding:2px 5px">
	<img src="./logo.webp" alt="Image could not be loaded!" style="color:red;background-color:black;font-weight:bold" />
</div>

<p align="center">
	<a href="https://github.com/jorexdeveloper/termux-nethunter/stargazers">
		<img
			src="https://img.shields.io/github/stars/jorexdeveloper/termux-nethunter?colorA=23272a&colorB=007bff&style=for-the-badge">
	</a>
	<a href="https://github.com/jorexdeveloper/termux-nethunter/issues">
		<img
			src="https://img.shields.io/github/issues/jorexdeveloper/termux-nethunter?colorA=23272a&colorB=ff4500&style=for-the-badge">
	</a>
	<a href="https://github.com/jorexdeveloper/termux-nethunter/contributors">
		<img
			src="https://img.shields.io/github/contributors/jorexdeveloper/termux-nethunter?colorA=23272a&colorB=28a745&style=for-the-badge">
	</a>
	<a href="https://kali.download/nethunter-images/kali-2025.3/rootfs">
		<img
			src="https://img.shields.io/badge/dynamic/json?label=Status%20&query=$.status&url=https%3A%2F%2Fraw.githubusercontent.com%2Fjorexdeveloper%2Ftermux-nethunter%2Fmain%2Fstatus.json&color=lightgray&logo=kalilinux&logoColor=white&logoSize=auto&style=for-the-badge">
	</a>
</p>

Are you a Linux enthusiast, or do you enjoy experimenting with the terminal and running commands to feel like a tech genius? Well, whatever your reason for wanting to install Linux on your phone, I've got you covered.

Installing Linux on your phone might not make you a hacker, but it will certainly make you look and feel like one.

With this guide, you will be able to run a full Linux system, including every Linux command you can think of, and install different PC software—all on your phone! That's not all—you can run a desktop environment, enjoy a PC-like graphical interface, and perhaps feel like a hacker from a movie.

Did I mention that you do not require root access to do all this? All you have to do is follow these simple installation instructions, and you are a few keystrokes away from running all the cool programs created by the Linux community.

<details>
	<summary>Contents</summary>
	<ul class="simple" title="View this section.">
		<li><a href="#installation" title="View this section.">Installation</a></li>
		<ul>
			<li><a href="#how-to-install" title="View this section.">How to Install</a></li>
		</ul>
		<li><a href="#launch-and-set-up" title="View this section.">Launch and Set Up</a></li>
		<ul>
			<li><a href="#how-to-launch" title="View this section.">How to Launch</a></li>
			<li><a href="#how-to-set-up-the-desktop" title="View this section.">How to Set Up the Desktop</a></li>
		</ul>
		<li><a href="#login" title="View this section.">Login</a></li>
		<ul>
			<li><a href="#how-to-start-the-desktop" title="View this section.">How to Start the Desktop</a></li>
			<li><a href="#how-to-connect-to-the-desktop" title="View this section.">How to Connect to the Desktop</a></li>
		</ul>
		<li><a href="#have-fun" title="View this section.">Have Fun</a></li>
		<li><a href="#management" title="View this section.">Management</a></li>
		<ul>
			<li><a href="#how-to-rename" title="View this section.">How to Rename</a></li>
			<li><a href="#how-to-backup" title="View this section.">How to Backup</a></li>
			<li><a href="#how-to-restore" title="View this section.">How to Restore</a></li>
			<li><a href="#how-to-uninstall" title="View this section.">How to Uninstall</a></li>
		</ul>
		<li><a href="#faq" title="View this section.">FAQ</a></li>
		<li><a href="#contribution" title="View this section.">Contribution</a></li>
	</ul>
</details>

## Installation

### How to Install

Download and install the [Termux](https://github.com/termux/termux-app/releases/latest "Download Termux from the official repository.") app on your phone, then open it and execute the following commands.

1. Upgrade Termux packages

```bash
pkg update && pkg upgrade
```

2. Install `curl`

```bash
pkg install curl
```

3. Download the install script

```bash
curl -fsSLO https://raw.githubusercontent.com/jorexdeveloper/termux-nethunter/main/install-nethunter.sh
```

4. Execute the install script

```bash
bash install-nethunter.sh
```

You can also customize the installation with command-line options (See `bash install-ubuntu.sh --help` for more information).

It's probably a good idea to inspect any install script from projects you don't yet know. You can do that by downloading the install script, looking through it to ensure everything looks fine before running it.

If you are lazy like me, you can just copy and paste the commands below in Termux.

```bash
pkg update -y && pkg upgrade -y && pkg install -y curl && curl -fsSLO https://raw.githubusercontent.com/jorexdeveloper/termux-nethunter/main/install-nethunter.sh && bash install-nethunter.sh
```

## Launch and Set Up

After successful installation, you need to launch the system and make a few setups.

### How to Launch

Launch the system by simply executing the following command.

```bash
nethunter
```

or with a shorter version

```bash
nh
```

You will be logged in with the default username, **kali** (You can log in as another user by providing their username as an argument.)

See `nethunter --help` for usage information.

### How to Set Up the Desktop

For the **minimal** and **nano** installations, you will need to install a desktop environment and a VNC server to get a graphical interface to interact with.

[Launch](#how-to-launch "View this section.") the system and execute the following commands.

1. Upgrade system packages

```bash
sudo apt update && apt full-upgrade
```

2. Install VNC server

```bash
sudo apt install tigervnc-standalone-server dbus-x11
```

3. Install desktop environment

```bash
sudo apt install kali-desktop-xfce
```

This command will not only take several gigabytes of your storage but also take a while to complete. Grab a coffee and ensure that Termux remains open during the installation to avoid potential issues (You can also acquire Termux wake lock, but it will only work if battery optimization is disabled).

## Login

Now all that's left is to log in to your newly installed system and start playing around with some commands. To do that, you need to start a VNC server in the system and connect to it through a VNC viewer.

### How to Start the Desktop

[Launch](#how-to-launch "View this section.") the system and execute the following command.

```bash
vnc
```

**Use `vnc kill` to stop the VNC server** and terminate the Desktop session. (See `vnc help` for more information).

On the first run of the command above, you will be prompted for a **VNC password**. This is the password that will be used to securely connect to the VNC server in the VNC viewer app, so save it somewhere.

### How to Connect to the Desktop

To connect to the VNC server and view the desktop, you will need to download and install a VNC viewer app of your choice (I recommend [AVNC](https://github.com/gujjwal00/avnc/releases/latest "Download AVNC from the official repository.")).

[Start the desktop](#how-to-start-the-desktop "View this section.") and **minimize** Termux.

Then open the VNC viewer app, click add server, and fill in the following details:

**Name**

```txt
Kali Desktop
```

**Host**

```txt
localhost
```

**Port**

| username | port                       |
| -------- | -------------------------- |
| kali     | 5900 (works for all users) |

**Password**

Enter the **VNC password** you set when [starting the desktop](#how-to-start-the-desktop "View this section.") for the first time.

## Have Fun

If you managed to get this far without any problems, congratulations! Linux is now installed on your phone, and it's time to explore and have some fun with it!

The possibilities are endless, and the only limits that exist are the ones you set for yourself.

You might want to Google some cool commands and programs to execute or even when you get stuck. Good luck.

## Management

A few features have been added to the `nethunter` command to simplify some tasks.

### How to Rename

Renaming the installed system is far more complicated than just executing a regular `mv` command.

To rename your installation, execute the following command:

```bash
nethunter --rename <new-directory>
```

### How to Backup

Backing up the installed system is far more complicated than just executing an ordinary `tar` command.

To back up your installation, execute the following command:

```bash
nethunter --backup <archive-name> [<dirs-to-exclude>]
```

The **backup is performed as a TAR archive** and **compression is determined by the output file extension.**

### How to Restore

To restore your backed-up installation from the archive, execute the following command:

```bash
nethunter --restore <archive-name>
```

**The rootfs MUST be restored to the original location** but you can [rename](#how-to-rename "View this section") it afterwards.

### How to Uninstall

To uninstall the system, just execute the following command:

```bash
nethunter --uninstall
```

## FAQ

If you encountered some hiccups during the installation or have some burning questions, you are probably not the first one. Feel free to document them in the [issues section](https://github.com/jorexdeveloper/termux-nethunter/issues "View the issues section.").

However, a few frequently asked questions have been answered below.

### What happens if Termux has root access?

This guide assumes that Termux has no root access and the only root permissions that exist are those simulated in the installed system.

However, if you have tried following the steps above with root permissions in Termux, then you have probably not succeeded because installing and running the system with root permissions in Termux can have unintended effects and should never be done (unless you are sure of what you are doing); otherwise, you might end up **damaging your device**.

For that reason, I added a **safety check** to the install script that terminates the installation process if Termux has root access.

There should not be a good enough reason to launch the system when Termux has root permissions because harmless root privileges are still simulated in the system with the help of proot.

#### Workaround

If you **don't mind damaging your device** (probably making it unusable) and are **ready to get your hands dirty**, this section might resonate.

Disabling the safety check will require a deeper understanding of the install script and the installation process. You will need to edit the install script as follows:

- Find and comment the call to the safety check function.

Not very helpful, is it? That's because **this is definitely a bad idea, and you are completely liable for any unintended effects of this action**.

Just remember, I am mostly lazy and would never implement a safety check for no reason.

## Contribution

Contributions to this project are not only welcome but also encouraged.

Here is the current TODO list:

- [x] **Add Management Features**

  - Features:

    - Uninstall, back up, restore, and rename an existing installation.

- [ ] **Utilize the `dialog` command**

  - Perform the installation using a GUI (The `dialog` command comes pre-installed in Termux).

- [x] **Automate RootFS updates**

  - Implemented using GitHub Actions.

- [x] **Other improvements**

  - Ensure all new programs, scripts, or functions adhere to the principle:
    _Perform only one task and do it extremely well._

## License

```txt
    Copyright (C) 2023-2025  Jore

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
