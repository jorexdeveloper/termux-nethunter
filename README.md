<h1 align="center">TERMUX NETHUNTER</h1>

<div align="center";background-color:black;border:3px solid black;border-radius:6px;margin:5px 0;padding:2px 5px">
<img src="./logo.webp"
    alt="Image could not be loaded!"
    style="color:red;background-color:black;font-weight:bold"/>
</div>

Are you a linux fan or do you just love playing with the terminal and executing cool commands, just to look like a tech genius? Well, for whatever reason it is that you want to install linux on your phone, I got you covered.

Installing linux on your phone might not make you a hacker, but it will certainly make you look and feel like one.

With this guide, you will be able to run a full linux system, including every linux command you can think of and install different PC software, all on your phone! Wait that's not all, you can run a desktop environment and enjoy the PC graphical interface and probably try to hack into NASA using your phone like the guy in that one movie.

Did I mention that you do not require root access to do all this? All you have to do is follow these simple installation instructions and you are a few keystrokes away from running all the cool programs created by the linux community.

<details>
  <summary>Contents</summary>
  <ul class="simple" title="View this section.">
    <li><a href="#installation" title="View this section.">Installation</a></li>
    <ul>
      <li><a href="#how-to-install" title="View this section.">How to install</a></li>
    </ul>
    <li><a href="#launch-and-set-up" title="View this section.">Launch and set up</a></li>
    <ul>
      <li><a href="#how-to-launch" title="View this section.">How to launch</a></li>
      <li><a href="#how-to-install-desktop-and-vnc-server" title="View this section.">How to install desktop and vnc server</a></li>
    </ul>
    <li><a href="#login" title="View this section.">Login</a></li>
    <ul>
      <li><a href="#how-to-start-vnc-server" title="View this section.">How to start vnc server</a></li>
      <li><a href="#how-to-connect-to-vnc-server" title="View this section.">How to connect to vnc server</a></li>
    </ul>
    <li><a href="#have-fun" title="View this section.">Have fun</a></li>
    <li><a href="#uninstallation" title="View this section.">Uninstallation</a></li>
    <ul>
      <li><a href="#how-to-uninstall" title="View this section.">How to uninstall</a></li>
    </ul>
    <li><a href="#faq" title="View this section.">FAQ</a></li>
  </ul>
</details>

<details>
  <summary>Features</summary>
  <ul class="simple">
    <li>anti-root fuse</li>
    <li>interactive installation</li>
    <li>color output (if supported)</li>
    <li>command line options</li>
    <ul>
      <li>install in custom directory</li>
      <li>make clean install (no configurations)</li>
      <li>configurations only (if already installed)</li>
      <li>uninstall</li>
      <li>color</li>
      <li>log</li>
    </ul>
    <li>creates vnc wrapper</li>
    <li>automatic configurations</li>
    <li>provides access to system and Termux commands</li>
    <li>customize default shell and local time during installation</li>
    <li>minor tweaks</li>
  </ul>
</details>

## Installation

### How to install

Download and install the [Termux](https://fdroid.org/packages/com.termux "Download Termux from Fdroid.") app on your phone, then open it and execute the following commands.

1.  Upgrade Termux packages

```bash
pkg update && pkg upgrade
```

2.  Install `curl`

```bash
pkg install curl
```

3.  Download the install script

```bash
curl -fsSLO https://raw.githubusercontent.com/jorexdeveloper/termux-nethunter/main/install-nethunter.sh
```

4.  Execute install script

```bash
bash install-nethunter.sh
```

> See `bash install-nethunter.sh --help` for usage information.

It's probably a good idea to inspect any install script from projects you don't yet know. You can do that by downloading the install script, looking through it so everything looks fine before running it.

If you are lazy like me, you can just copy and paste the commands below in Termux.

```bash
pkg update -y && pkg upgrade -y && pkg install -y curl && curl -fsSLO https://raw.githubusercontent.com/jorexdeveloper/termux-nethunter/main/install-nethunter.sh && bash install-nethunter.sh
```

## Launch and set up

After successful installation, you need to launch the system and make a few set ups.

### How to launch

Launch the system by simply executing the following command.

```bash
nethunter
```

or with a shorter version

```bash
nh
```

You will be logged in with the default user name, **kali** (You can login as another user by providing their user name as an argument. See `nethunter --help` for usage information).

### How to install desktop and vnc server

For the **minimal** and **nano** installations, you will need to install a desktop environment and a vnc server to get a graphical interface to interact with.

[Launch](#how-to-launch "View this section.") the system and execute the following commands.

1.  Upgrade system packages

```bash
sudo apt update && apt full-upgrade
```

2.  Install vnc server

```bash
sudo apt install tigervnc-standalone-server dbus-x11
```

3. Install desktop environment

```bash
sudo apt install kali-desktop-xfce
```

This command will not only take several gigabytes of your storage but also take a while to complete, grab a coffee and make sure you keep Termux open during the installation or you might run into some problems later (You can also acquire Termux wake lock but it will only work if battery optimization is disabled).

## Login

Now all that's left is to login into your newly installed system and start playing around with some commands. To do that, you need to start a vnc server in the system and connect to it through a vnc viewer.

### How to start vnc server

[Launch](#how-to-launch "View this section.") the system and execute the following command.

```bash
vnc
```

> See `vnc help` for usage information.

On the first run of the command above, you will be prompted for a **vnc password**. This is the password that will be used to securely connect to the vnc server, in the vnc viewer, so save it somewhere.

### How to connect to vnc server

To connect to the vnc server, you will need to download and install a vnc viewer app of your choice (I recommend [AVNC](https://f-droid.org/packages/com.gaurav.avnc "Download AVNC from Fdroid.")).

[Start the vnc server](#how-to-start-vnc-server "View this section.") and **minimize** Termux.

Then open the vnc viewer app, click add server and fill in with the following details:

**Name**

```txt
Kali Desktop
```

**Host**

```txt
localhost
```

**Port**

The default display port differs for the root user and other users (Don't ask me why, I just got here).

| user name                  | port |
| -------------------------- | ---- |
| root                       | 5900 |
| kali (and any other users) | 5901 |

You shall use the second one if you are logged in as **kali** (The default login).

**Password**

Enter the **vnc password** you set when [starting the vnc server](#how-to-start-vnc-server "View this section.") for the first time.

## Have fun

If you managed to get this far without any problems, congratulations! Linux now is installed on your phone and it's time to explore and have some fun with it!

The possibilities are endless and the only limits that exist are the ones you set up for yourself.

You might wan't to google for some cool commands and programs to execute or even when get you stuck, good luck.

## Uninstallation

If for some reason you need to uninstall the system from Termux, just follow the steps below.

### How to uninstall

Simply execute the [install](#how-to-install "View this section.") script again in Termux with the option `--uninstall`.

```bash
bash install-nethunter.sh --uninstall
```

**Note:** If you installed the system in a custom directory, supply the path to the installation directory as an additional argument.

## FAQ

If you got some hickups during the installation or have some burning questions, you are probably not the first one. Feel free to document them in the [issues section](https://github.com/jorexdeveloper/termux-nethunter/issues "View the issues section.")

However, a few frequently asked questions have been answered below.

### What happens if Termux has root access?

This guide assumes that Termux has no root access and the only root permissions that exist are those simulated in the installed system.

However, if you have tried following the steps above with root permissions in Termux, then you have probably not succeeded because installing and running the system with root permissions in Termux can have unintended effects, and should never be done (unless you are sure of what you are doing) otherwise you might end up **damaging your device**.

For that reason, I added an **anti-root fuse** to the install script that prevents the installation process if Termux has root access.

There should not be a good enough reason to launch the system when Termux has root permissions because harmless root privileges are still simulated in the system with help of proot.

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
