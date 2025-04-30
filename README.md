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
	<a href="https://kali.download/nethunter-images/kali-2025.1c/rootfs">
		<img
			src="https://img.shields.io/badge/dynamic/json?label=RootFS%20status%20&query=$.status&url=https%3A%2F%2Fraw.githubusercontent.com%2Fjorexdeveloper%2Ftermux-nethunter%2Fmain%2Fstatus.json&color=lightgray&logo=linux&logoSize=auto&style=for-the-badge">
	</a>
</p>

Are you a Linux enthusiast, or do you enjoy experimenting with the terminal and running commands to feel like a tech genius? Well, for whatever reason it is that you want to install Linux on your phone, I got you covered.

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
			<li><a href="#how-to-setup-the-desktop" title="View this section.">How to Set Up the Desktop</a></li>
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

4. Execute install script

```bash
bash install-nethunter.sh
```

You can also customize the installation with command-line options. (See `bash install-ubuntu.sh --help` for more information.)

It's probably a good idea to inspect any install script from projects you don't yet know. You can do that by downloading the install script, looking through it so everything looks fine before running it.

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

You will be logged in with the default username, **kali** (You can log in as another user by providing their username as an argument. See `nethunter --help` for usage information).

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

Use `vnc kill` to stop the VNC server and terminate the Desktop session. the Desktop. (See `vnc help` for more information.)

On the first run of the command above, you will be prompted for a **VNC password**. This is the password that will be used to securely connect to the VNC server in the VNC viewer app, so save it somewhere.

### How to Connect to the Desktop

To connect to the VNC server and view the desktop, you will need to download and install a VNC viewer app of your choice (I recommend [AVNC](https://github.com/gujjwal00/avnc/releases/latest "Download AVNC from the official repository.")).

[Start the desktop](#how-to-start-the-desktop "View this section.") and **minimize** Termux.

Then open the VNC viewer app, click add server, and fill in with the following details:

**Name**

```txt
Kali Desktop
```

**Host**

```txt
localhost
```

**Port**

| username                   | port |
| -------------------------- | ---- |
| kali (works for all users) | 5900 |

**Password**

Enter the **VNC password** you set when [starting the desktop](#how-to-start-the-desktop "View this section.") for the first time.

## Have Fun

If you managed to get this far without any problems, congratulations! Linux is now installed on your phone, and it's time to explore and have some fun with it!

The possibilities are endless, and the only limits that exist are the ones you set up for yourself.

You might want to Google for some cool commands and programs to execute or even when you get stuck. Good luck.

## Management

I **stubbornly refuse** to add some of these management features to the install script directly because it defeats the whole design structure of _making the program do one thing extremely well_.

### How to Rename

Renaming the installed system is far more complicated than just executing a regular `mv` command.

To rename your installed system, you need to locate and change all the proot links within the system to point to the new directory.

Here is a simple shell function to help you do that.

```bash
chroot-rename() {
	if [ -n "${1}" ] && [ -n "${2}" ] && [ -d "${1}" ]; then
		if [ -e "${2}" ]; then
			# Prevent overwriting any existing files.
			echo ">> '${2}' already exists, aborting."
		else
			local old_chroot="$(realpath "${1}")"
			local new_chroot="$(realpath "${2}")"
			echo ">> Renaming '${old_chroot}' to '${new_chroot}'."
			# Rename the directory
			mv "${old_chroot}" "${new_chroot}"
			echo ">> Updating proot links, this may take a while."
			local name old_target new_target
			# Find all proot links
			find "${new_chroot}" -type l | while read -r name; do
				# Get old link destination
				old_target=$(readlink "${name}")
				if [ "${old_target:0:${#old}}" = "${old_chroot}" ]; then
					# Set new link destination
					new_target="${old_target//${old_chroot}/${new_chroot}}"
					# Create new link and replace old one
					ln -sf "${new_target}" "${name}"
				fi
			done
			echo ">> Done, but I didn't rename any launch commands!"
			echo ">> Just run the install script again with option '--config-only'"
		fi
	else
		echo "Usage: chroot-rename <old-directory> <new-directory>"
	fi
}
```

Just copy and paste the above code in Termux and then execute the command below.

```bash
chroot-rename <old-directory> <new-directory>
```

**NOTE:** This does not update the launch commands to use the new directory. To do that, just execute the install script again, giving it the new directory as an argument.

```bash
bash install-nethunter.sh --config-only <new-directory>
```

### How to Backup

Backing up the installed system is more complicated than just executing an ordinary `tar` command.

To back up your installed system, you need to execute the `tar` command with a few extra options to ensure that file permissions are properly preserved and your system remains usable.

Here is a simple shell function to help you do that.

```bash
chroot-backup() {
	if [ -n "${1}" ] && [ -d "${1}" ]; then
		if [ -n "${2}" ]; then
			local file="${2}"
		else
			# Default archive name if not given.
			local file="${HOME}/$(basename "${1}").tar.xz"
		fi
		# Directories to include/exclude in the archive some read-only directories
		# like /dev need to be ignored but you can add your own if you wish
		local include=(.l2s bin boot etc home lib media mnt opt proc root run sbin snap srv sys tmp usr var)
		local exclude=()
		echo ">> Packing chroot into '${file}'."
		echo ">> Including:"
		local i
		for i in "${include[@]}"; do
			echo -e "\t${i}"
		done
		echo ">> Excluding:"
		local exclude_args=()
		# Prepend the '--exclude' tag to all exclude dirs
		for i in "${exclude[@]}"; do
			echo -e "\t${i}"
			exclude_args=("${exclude_args[@]}" "--exclude=${i}")
		done
		rmdir "${1}"/* &>/dev/null
		rm -rvf "${1}"/linkerconfig "${1}"/data "${1}"/storage &>/dev/null
		# Make sure all directories exist
		for i in "${include[@]}" "${exclude[@]}"; do
			mkdir -p "${1}/${i}"
		done
		# Switch to the chroot directory and back up the given directories
		tar \
			--warning=no-file-ignored \
			--one-file-system \
			--xattrs \
			--xattrs-include='*' \
			--preserve-permissions \
			--create \
			--auto-compress \
			-C \
			"${1}" \
			--file="${file}" \
			"${exclude_args[@]}" \
			"${include[@]}"
	else
		echo "Usage: chroot-backup <directory> [<file>]"
	fi
}
```

Just copy and paste the above code in Termux and then execute the command below.

```bash
chroot-backup <directory>
```

### How to Restore

To restore your installation from the archive, execute the following commands in Termux.

```bash
mkdir -p <original-directory>
```

Switch to the directory.

```bash
cd <original-directory>
```

Unpack the archive (This can take some time).

```bash
tar \
    --delay-directory-restore \
    --preserve-permissions \
    --warning=no-unknown-keyword \
    --extract \
    --auto-compress \
    --file "<archive>"
```

**NOTE:** This process requires you to restore the system to the same directory as the original installation; otherwise, the proot links get broken, and the system gets corrupted.

### How to Uninstall

To uninstall the system, just execute the install script again in Termux with the option `--uninstall`.

```bash
bash install-nethunter.sh --uninstall
```

**NOTE:** If you installed the system in a custom directory, add the path to the installation directory as an additional argument.

If you feel like all that is too technical, feel free to contribute a management script that automates these actions because I'm still lazy for that right now (see the [contributions section](#contribution "View this section")).

## FAQ

If you encountered some hiccups during the installation or have some burning questions, you are probably not the first one. Feel free to document them in the [issues section](https://github.com/jorexdeveloper/termux-nethunter/issues "View the issues section.")

However, a few frequently asked questions have been answered below.

### What happens if Termux has root access?

This guide assumes that Termux has no root access and the only root permissions that exist are those simulated in the installed system.

However, if you have tried following the steps above with root permissions in Termux, then you have probably not succeeded because installing and running the system with root permissions in Termux can have unintended effects and should never be done (unless you are sure of what you are doing); otherwise, you might end up **damaging your device**.

For that reason, I added an **anti-root fuse** to the install script that prevents the installation process if Termux has root access.

There should not be a good enough reason to launch the system when Termux has root permissions because harmless root privileges are still simulated in the system with the help of proot.

#### Workaround

If you **don't mind damaging your device** (probably making it unusable) and are **ready to get your hands dirty**, this section might resonate.

Disabling the anti-root fuse will require a deeper understanding of the install script and the installation process. You will need to edit the install script as follows:

- Find and comment the call to the function checking root access.

Not very helpful, is it? That's because **this is definitely a bad idea, and you are completely liable for any unintended effects of this action**.

Just remember, I am mostly lazy and would never implement an anti-root fuse for absolutely no reason.

## Contribution

Contributions to this project are not only welcome but also encouraged.

Here is the current TODO list:

- [ ] **Create a management script**

  - Features:

    - Back up, restore, and rename an existing installation.
    - Intuitive and user-friendly with clear usage information.

- [ ] **Utilize the `dialog` command**

  - Perform the installation using a GUI.
  - Note: The `dialog` command comes pre-installed in Termux.

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
