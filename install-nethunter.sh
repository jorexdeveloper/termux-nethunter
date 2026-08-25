#!/data/data/com.termux/files/usr/bin/bash

################################################################################
#                                                                              #
# Termux NetHunter Installer.                                                  #
#                                                                              #
# Installs Kali NetHunter in Termux.                                           #
#                                                                              #
# Copyright (C) 2023-2025  Jore <https://github.com/jorexdeveloper>            #
#                                                                              #
# This program is free software: you can redistribute it and/or modify         #
# it under the terms of the GNU General Public License as published by         #
# the Free Software Foundation, either version 3 of the License, or            #
# (at your option) any later version.                                          #
#                                                                              #
# This program is distributed in the hope that it will be useful,              #
# but WITHOUT ANY WARRANTY; without even the implied warranty of               #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                #
# GNU General Public License for more details.                                 #
#                                                                              #
# You should have received a copy of the GNU General Public License            #
# along with this program.  If not, see <https://www.gnu.org/licenses/>.       #
#                                                                              #
################################################################################
# shellcheck disable=SC2034,SC2155

# ATTENTION!!! CHANGE BELOW FUNTIONS FOR DISTRO DEPENDENT ACTIONS!!!

################################################################################
# Called before any safety checks                                              #
# New Variables: AUTHOR GITHUB LOG_FILE ACTION_INSTALL ACTION_CONFIGURE        #
#                ROOTFS_DIRECTORY COLOR_SUPPORT (all available colors)         #
################################################################################
pre_check_actions() {
	P=${W} # primary color
	S=${B} # secondary color
	T=${M} # tertiary color
}

################################################################################
# Called before printing intro                                                 #
# New Variables: none                                                          #
################################################################################
distro_banner() {
	local spaces=$(printf "%*s" $((($(stty size | awk '{print $2}') - 49) / 2)) "")
	msg -a "${spaces}${S}.............."
	msg -a "${spaces}${S}            ..,;:ccc,."
	msg -a "${spaces}${S}          ......''';lxO."
	msg -a "${spaces}${S}.....''''..........,:ld;"
	msg -a "${spaces}${S}           .';;;:::;,,.x,"
	msg -a "${spaces}${S}      ..'''.            0Xxoc:,.  ..."
	msg -a "${spaces}${S}  ....                ,ONkc;,;cokOdc',."
	msg -a "${spaces}${S} .                   OMo           ':${R}dd${S}o."
	msg -a "${spaces}${S}                    dMc               :OO;"
	msg -a "${spaces}${S}                    0M.                 .:o."
	msg -a "${spaces}${S}                    ;Wd"
	msg -a "${spaces}${S}                     ;XO,"
	msg -a "${spaces}${S}                       ,d0Odlc;,.."
	msg -a "${spaces}${S}                           ..',;:cdOOd::,."
	msg -a "${spaces}${S}                                    .:d;.':;."
	msg -a "${spaces}${S}                                       'd,  .'"
	msg -a "${spaces}${S}${P}${DISTRO_NAME}${S}                           ;l   .."
	msg -a "${spaces}${S}    ${T}${VERSION_NAME}${S}                                    .o"
	msg -a "${spaces}${S}                                            c  ."
	msg -a "${spaces}${S}                                            .'"
	msg -a "${spaces}${S}                                             ."
}

################################################################################
# Called after checking architecture and required pkgs                         #
# New Variables: SYS_ARCH LIB_GCC_PATH                                         #
################################################################################
post_check_actions() {
	return
}

################################################################################
# Called after checking for rootfs directory                                   #
# New Variables: KEEP_ROOTFS_DIRECTORY                                         #
################################################################################
pre_install_actions() {
	if [[ ! ${KEEP_ROOTFS_DIRECTORY} ]]; then
		choose -d2 -t "Select installation" \
			"Full (Desktop environment)" \
			"Mini (Essential Packages)" \
			"Nano (Essential Packages)"
		SELECTED_INSTALLATION=${?}

		case "${SELECTED_INSTALLATION}" in
			1)
				SELECTED_INSTALLATION=full
				DE_INSTALLED=1
				;;
			3) SELECTED_INSTALLATION=nano ;;
			*) SELECTED_INSTALLATION=mini ;;
		esac

		ARCHIVE_NAME=kali-nethunter-rootfs-${SELECTED_INSTALLATION/mini/minimal}-${SYS_ARCH}.tar.xz
	fi
}

################################################################################
# Called after extracting rootfs                                               #
# New Variables: KEEP_ROOTFS_ARCHIVE                                           #
################################################################################
post_install_actions() {
	return
}

################################################################################
# Called before making configurations                                          #
# New Variables: none                                                          #
################################################################################
pre_config_actions() {
	mkdir -p "${ROOTFS_DIRECTORY}"/etc &>>"${LOG_FILE}" && echo "${ROOTFS_DIRECTORY}" >"${ROOTFS_DIRECTORY}"/etc/debian_chroot
}

################################################################################
# Called after configurations                                                  #
# New Variables: none                                                          #
################################################################################
post_config_actions() {
	if [[ -f ${ROOTFS_DIRECTORY}/etc/locale.gen && -x ${ROOTFS_DIRECTORY}/sbin/dpkg-reconfigure ]]; then
		msg -tn "Generating locales..."
		sed -i -E 's/#[[:space:]]?(en_US.UTF-8[[:space:]]+UTF-8)/\1/g' "${ROOTFS_DIRECTORY}"/etc/locale.gen

		if distro_exec DEBIAN_FRONTEND=noninteractive /sbin/dpkg-reconfigure locales &>>"${LOG_FILE}"; then
			cursor -u1
			msg -ts "Locales generated"
		else
			cursor -u1
			msg -te "Failed to generate locales."
		fi
	fi
}

################################################################################
# Called before complete message                                               #
# New Variables: none                                                          #
################################################################################
pre_complete_actions() {
	if [[ ! ${DE_INSTALLED} && ${SELECTED_INSTALLATION} != full ]] && ask -y -- -t "Install Desktop Environment?"; then
		set_up_de && {
			DE_INSTALLED=1
			set_up_browser
		}
	fi
}

################################################################################
# Called after complete message                                                #
# New Variables: none                                                          #
################################################################################
post_complete_actions() {
	return
}

################################################################################
# Local Functions                                                              #
################################################################################

# Sets up X11 environment (Optimized for Unrooted Samsung A05s)
set_up_de() {
	msg -t "Setting up X11 Display Server Environment"
	msg -a "Display: :1 (via TigerVNC)"
	
	# X11 server options
	local x11_server="tigervnc"
	local display_number=1
	local display_res="720x1280"  # Portrait mode for phone screen
	local display_depth=24
	
	# Lightweight window managers suitable for X11 + unrooted device
	local available_wm=(
		"Openbox (Ultra-light WM)"
		"i3 (Tiling WM)"
		"Xfce (Full DE with X11)"
		"Fluxbox (Lightweight WM)"
	)
	
	local -A wm_commands=(
		[openbox]="openbox"
		[i3]="i3"
		[xfce]="startxfce4"
		[fluxbox]="fluxbox"
	)
	
	local -A wm_packages=(
		[openbox]="openbox"
		[i3]="i3"
		[xfce]="kali-desktop-xfce"
		[fluxbox]="fluxbox"
	)

	choose -d3 -t "Select Window Manager for X11" \
		"${available_wm[@]}"
	local selected_choice=${?}

	local selected_wm selected_pkg
	case "${selected_choice}" in
		1) selected_wm="openbox"; selected_pkg="openbox" ;;
		2) selected_wm="i3"; selected_pkg="i3" ;;
		3) selected_wm="xfce"; selected_pkg="kali-desktop-xfce" ;;
		4) selected_wm="fluxbox"; selected_pkg="fluxbox" ;;
		*) selected_wm="openbox"; selected_pkg="openbox" ;;
	esac

	msg -t "Installing ${selected_wm} Window Manager with X11"

	# Check for unrooted device limitations
	if ! command -v termux-wake-lock &>/dev/null; then
		msg -tw "Device is likely unrooted - wake-lock unavailable (expected)"
	fi

	msg -tn "Installing X11 and display server packages..."
	trap 'buffer -h; echo; msg -fem2; exit 130' INT
	buffer -s

	# Minimal X11 package set for unrooted device
	local x11_pkgs=(
		"tigervnc-standalone-server"
		"dbus-x11"
		"xserver-xorg-core"
		"xfonts-base"
		"x11-utils"
		"x11-xserver-utils"
		"${selected_pkg}"
	)
	
	if buffer -i apt update && distro_exec apt update && \
	   buffer -i apt install -y --no-install-recommends "${x11_pkgs[@]}" && \
	   distro_exec apt install -y --no-install-recommends "${x11_pkgs[@]}"; then
		buffer -h3
		trap - INT
		cursor -u1
		msg -ts "X11 and ${selected_wm} installed successfully"

		msg -tn "Configuring X11 environment..."

		# Create X11-optimized xstartup script
		local xstartup=$(
			cat 2>>"${LOG_FILE}" <<-'XEOF'
				#!/bin/bash
				# X11 Environment Startup Script
				# Optimized for Unrooted Android Devices
				
				# Clean X11 environment
				unset SESSION_MANAGER
				unset DBUS_SESSION_BUS_ADDRESS
				
				# X11 Display setup
				export DISPLAY=:1
				export XAUTHORITY=$HOME/.Xauthority
				
				# Runtime directories
				export XDG_RUNTIME_DIR=${TMPDIR:-/tmp}/runtime-"$(id -u)"
				mkdir -p "$XDG_RUNTIME_DIR"
				chmod 700 "$XDG_RUNTIME_DIR"
				
				export SHELL=${SHELL:-/bin/bash}
				
				# Memory optimization for limited resources (A05s: 4GB RAM)
				export MALLOC_TRIM_THRESHOLD_=131072
				export MALLOC_MMAP_THRESHOLD_=131072
				
				# DBus setup for X11 applications
				if [[ ! -S "$XDG_RUNTIME_DIR/dbus-socket" ]]; then
					eval "$(dbus-launch --sh-syntax)"
					export DBUS_SESSION_BUS_ADDRESS
					export DBUS_SESSION_BUS_PID
				fi
				
				# Load X resources if available
				if [[ -r ~/.Xresources ]]; then
					xrdb -merge ~/.Xresources
				fi
				
				# Start window manager
				exec XEOF
		)
		
		# Append the window manager command
		xstartup+="${wm_commands[${selected_wm}]}"
		
		if {
			mkdir -p "${ROOTFS_DIRECTORY}"/root/.vnc &&
			echo "${xstartup}" >"${ROOTFS_DIRECTORY}"/root/.vnc/xstartup &&
			chmod 755 "${ROOTFS_DIRECTORY}"/root/.vnc/xstartup &&
			if [[ ${DEFAULT_LOGIN} != root ]]; then
				mkdir -p "${ROOTFS_DIRECTORY}"/home/"${DEFAULT_LOGIN}"/.vnc &&
				echo "${xstartup}" >"${ROOTFS_DIRECTORY}"/home/"${DEFAULT_LOGIN}"/.vnc/xstartup &&
				chmod 755 "${ROOTFS_DIRECTORY}"/home/"${DEFAULT_LOGIN}"/.vnc/xstartup
			fi
		} 2>>"${LOG_FILE}"; then
			cursor -u1
			msg -ts "X11 xstartup script configured"
			
			# Create startup helper script in home directory
			local startup_helper=$(
				cat 2>>"${LOG_FILE}" <<-'HELPER'
					#!/bin/bash
					# VNC Server Startup Helper for X11
					
					echo "Starting VNC Server with X11..."
					echo "Display Resolution: 720x1280 (Portrait)"
					echo "Color Depth: 24-bit"
					echo "Port: 5901"
					echo ""
					
					# Kill any existing VNC servers
					vncserver -kill :1 2>/dev/null
					sleep 1
					
					# Start new VNC server
					vncserver :1 -geometry 720x1280 -depth 24 -localhost no
					
					echo ""
					echo "VNC Server started!"
					echo "Connect via: 127.0.0.1:5901"
					echo "To stop: vncserver -kill :1"
				HELPER
			)
			
			if echo "${startup_helper}" >"${ROOTFS_DIRECTORY}"/root/start-x11.sh && \
			   chmod 755 "${ROOTFS_DIRECTORY}"/root/start-x11.sh; then
				cursor -u1
				msg -ts "X11 startup helper created"
			fi
			
			# Print usage instructions
			msg -ta "✓ X11 ENVIRONMENT SETUP COMPLETE"
			msg -a ""
			msg -a "START X11 DISPLAY SERVER:"
			msg -a "  Inside Termux container (as root or kali user):"
			msg -a "  $ vncserver :1 -geometry 720x1280 -depth 24 -localhost no"
			msg -a ""
			msg -a "CONNECT VIA VNC CLIENT:"
			msg -a "  - Use any VNC viewer app (RealVNC, TightVNC, etc.)"
			msg -a "  - Address: 127.0.0.1:5901"
			msg -a "  - Password: (set when first running vncserver)"
			msg -a ""
			msg -a "STOP X11 SERVER:"
			msg -a "  $ vncserver -kill :1"
			msg -a ""
			msg -a "NOTES FOR UNROOTED DEVICE:"
			msg -a "  - Some tools (airmon-ng, iptables) require root"
			msg -a "  - X11 forwarding works fine without root"
			msg -a "  - Use SSH for better performance: ssh -X user@localhost"
		else
			cursor -u1
			msg -te "Failed to configure X11 xstartup script"
			return 1
		fi
	else
		buffer -h5
		trap - INT
		cursor -u1
		msg -te "Failed to install X11 packages"
		msg -a "Ensure sufficient storage (2GB+) and RAM available"
		return 1
	fi
}

# Sets up the Browser
set_up_browser() {
	local available_browsers selected_browser selected_browsers suffix
	available_browsers=(
		"Chromium" "Firefox ESR" "Chromium & Firefox ESR"
	)

	choose -d2 -t "Select Browser" \
		"${available_browsers[@]}"
	selected_browser=${available_browsers[$((${?} - 1))]}

	if [[ ${selected_browser} == "${available_browsers[-1]}" ]]; then
		selected_browsers=("${available_browsers[@]:0:${#available_browsers[@]}-1}")
		selected_browsers=("${selected_browsers[@]// /-}")
		suffix=s
	else
		selected_browsers=("${selected_browser// /-}")
		suffix=
	fi

	msg -tn "Installing ${selected_browser} Browser${suffix}..."
	trap 'buffer -h; echo; msg -fem2; exit 130' INT
	buffer -s

	if buffer -i apt install -y "${selected_browsers[@],,}" && distro_exec apt install -y "${selected_browsers[@],,}"; then
		if [[ ${selected_browsers[0]} == "${available_browsers[0]}" && -f "${ROOTFS_DIRECTORY}"/usr/share/applications/chromium.desktop ]]; then
			sed -Ei 's/^(Exec=.*chromium).*(%U)$/\1 --no-sandbox \2/' "${ROOTFS_DIRECTORY}"/usr/share/applications/chromium.desktop
		fi

		buffer -h3
		trap - INT
		cursor -u1
		msg -ts "${selected_browser} Browser${suffix} installed"
	else
		buffer -h5
		trap - INT
		cursor -u1
		msg -te "Failed to install ${selected_browser} Browser${suffix}"
	fi
}

DISTRO_NAME="Kali NetHunter"
PROGRAM_NAME=$(basename "${0}")
DISTRO_REPOSITORY=termux-nethunter
KERNEL_RELEASE=$(uname -r)
VERSION_NAME=2026.1

SHASUM_CMD=sha256sum
TRUSTED_SHASUMS=$(
	cat <<-EOF
		b8098fc90ed74a553592f7019a1d88dfe3c65b16c60af487b0658860554dc5aa  kali-nethunter-rootfs-full-arm64.tar.xz
		b15a4aba9fb1c6f7481d7b3d08cb77c9e9c993eb542475961d008bdc64767d64  kali-nethunter-rootfs-full-armhf.tar.xz
		08f121b553d03476b82b6322365eb4f47f73f4edf8800dafa7462b061eb2d0fc  kali-nethunter-rootfs-minimal-arm64.tar.xz
		1ff5a8313cca728cf3c967bd2c8b59c629e8d4b9f4b35bf62b9df9f0097c8c1d  kali-nethunter-rootfs-minimal-armhf.tar.xz
		484af462afa5064512f420d8565a90c7923ac6288f35d37d37dff6aa44936a23  kali-nethunter-rootfs-nano-arm64.tar.xz
		d0761b79c0b303401a1ac405db1b2b223b0e3e8d60ec647a6b391fd70c595fdf  kali-nethunter-rootfs-nano-armhf.tar.xz
	EOF
)

ARCHIVE_STRIP_DIRS=1 # directories stripped by tar when extracting rootfs archive
BASE_URL=https://kali.download/nethunter-images/kali-${VERSION_NAME}/rootfs
TERMUX_FILES_DIR=/data/data/com.termux/files

DISTRO_SHORTCUT=${TERMUX_FILES_DIR}/usr/bin/nh
DISTRO_LAUNCHER=${TERMUX_FILES_DIR}/usr/bin/nethunter

DEFAULT_ROOTFS_DIR=${TERMUX_FILES_DIR}/kali
DEFAULT_LOGIN=kali

# WARNING!!! DO NOT CHANGE BELOW!!!

# Check in program's directory for template
distro_template=$(realpath "$(dirname "${0}")")/termux-distro.sh

# shellcheck disable=SC1090
if [[ -f ${distro_template} ]] || curl -fsSLO https://raw.githubusercontent.com/jorexdeveloper/termux-distro/main/termux-distro.sh &>/dev/null; then
	source "${distro_template}" "${@}" || exit 1
else
	echo "You need an active internet connection to run this program."
fi
