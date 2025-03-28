#!/data/data/com.termux/files/usr/bin/bash

################################################################################
#                                                                              #
#     Termux NetHunter Installer.                                              #
#                                                                              #
#     Installs Kali NetHunter in Termux.                                       #
#                                                                              #
#     Copyright (C) 2023  Jore <https://github.com/jorexdeveloper>             #
#                                                                              #
#     This program is free software: you can redistribute it and/or modify     #
#     it under the terms of the GNU General Public License as published by     #
#     the Free Software Foundation, either version 3 of the License, or        #
#     (at your option) any later version.                                      #
#                                                                              #
#     This program is distributed in the hope that it will be useful,          #
#     but WITHOUT ANY WARRANTY; without even the implied warranty of           #
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
#     GNU General Public License for more details.                             #
#                                                                              #
#     You should have received a copy of the GNU General Public License        #
#     along with this program.  If not, see <https://www.gnu.org/licenses/>.   #
#                                                                              #
################################################################################
# shellcheck disable=SC2034

# ATTENTION!!! CHANGE BELOW FUNTIONS FOR DISTRO DEPENDENT ACTIONS!!!

# Called before any safety checks
# New Variables: AUTHOR GITHUB LOG_FILE ACTION_INSTALL ACTION_CONFIGURE
#                ROOTFS_DIRECTORY COLOR_SUPPORT all_available_colors
pre_check_actions() {
	return
}

# Called before printing intro
# New Variables: none
distro_banner() {
	local spaces=''
	for ((i = $((($(stty size | cut -d ' ' -f2) - 49) / 2)); i > 0; i--)); do
		spaces+=' '
	done
	msg -a "${spaces}${B}.............."
	msg -a "${spaces}${B}            ..,;:ccc,."
	msg -a "${spaces}${B}          ......''';lxO."
	msg -a "${spaces}${B}.....''''..........,:ld;"
	msg -a "${spaces}${B}           .';;;:::;,,.x,"
	msg -a "${spaces}${B}      ..'''.            0Xxoc:,.  ..."
	msg -a "${spaces}${B}  ....                ,ONkc;,;cokOdc',."
	msg -a "${spaces}${B} .                   OMo           ':${R}dd${B}o."
	msg -a "${spaces}${B}                    dMc               :OO;"
	msg -a "${spaces}${B}                    0M.                 .:o."
	msg -a "${spaces}${B}                    ;Wd"
	msg -a "${spaces}${B}                     ;XO,"
	msg -a "${spaces}${B}                       ,d0Odlc;,.."
	msg -a "${spaces}${B}                           ..',;:cdOOd::,."
	msg -a "${spaces}${B}                                    .:d;.':;."
	msg -a "${spaces}${B}                                       'd,  .'"
	msg -a "${spaces}${C}${DISTRO_NAME}${B}                           ;l   .."
	msg -a "${spaces}${Y}    ${VERSION_NAME}${B}                                    .o"
	msg -a "${spaces}${B}                                            c"
	msg -a "${spaces}${B}                                            .'"
	msg -a "${spaces}${B}                                             ."
}

# Called after checking architecture and required pkgs
# New Variables: SYS_ARCH LIB_GCC_PATH
post_check_actions() {
	return
}

# Called after checking for rootfs directory
# New Variables: KEEP_ROOTFS_DIRECTORY
pre_install_actions() {
	if [ -z "${KEEP_ROOTFS_DIRECTORY}" ]; then
		msg -t "Select your prefered installation."
		msg -l "  full    (Large but contains everything you need)" "  minimal (Light-weight with essential packages only)" "${Y}>${G} nano    (Like minimal with a few more packages)"
		msg -n "Select choice: "
		read -ren 1 SELECTED_INSTALLATION
		case "${SELECTED_INSTALLATION}" in
			1 | f | F) SELECTED_INSTALLATION="full" ;;
			2 | m | M) SELECTED_INSTALLATION="minimal" ;;
			*) SELECTED_INSTALLATION="nano" ;;
		esac
		msg "Okay then, I shall install a '${Y}${SELECTED_INSTALLATION}${C}' rootfs."
		ARCHIVE_NAME="kali-nethunter-rootfs-${SELECTED_INSTALLATION}-${SYS_ARCH}.tar.xz"
	fi
}

# Called after extracting rootfs
# New Variables: KEEP_ROOTFS_ARCHIVE
post_install_actions() {
	msg -t "Lemme create an xstartup script for vnc."
	local xstartup="$(
		# Customize depending on distribution defaults
		cat 2>>"${LOG_FILE}" <<-EOF
			#!/bin/bash
			#############################
			##          All            ##
			unset SESSION_MANAGER
			unset DBUS_SESSION_BUS_ADDRESS

			export XDG_RUNTIME_DIR=/tmp/runtime-"\${USER:-root}"
			export SHELL="\${SHELL:-/bin/sh}"

			if [ -r ~/.Xresources ]; then
			    xrdb ~/.Xresources
			fi

			#############################
			##          Gnome          ##
			# exec gnome-session

			############################
			##           LXQT         ##
			# exec startlxqt

			############################
			##          KDE           ##
			# exec startplasma-x11

			############################
			##          XFCE          ##
			export QT_QPA_PLATFORMTHEME=qt5ct
			exec startxfce4

			############################
			##           i3           ##
			# exec i3

			############################
			##        BLACKBOX        ##
			# exec blackbox
		EOF
	)"
	if {
		mkdir -p "${ROOTFS_DIRECTORY}/root/.vnc"
		echo "${xstartup}" >"${ROOTFS_DIRECTORY}/root/.vnc/xstartup"
		chmod 744 "${ROOTFS_DIRECTORY}/root/.vnc/xstartup"
		if [ "${DEFAULT_LOGIN}" != "root" ]; then
			mkdir -p "${ROOTFS_DIRECTORY}/home/${DEFAULT_LOGIN}/.vnc"
			echo "${xstartup}" >"${ROOTFS_DIRECTORY}/home/${DEFAULT_LOGIN}/.vnc/xstartup"
			chmod 744 "${ROOTFS_DIRECTORY}/home/${DEFAULT_LOGIN}/.vnc/xstartup"
		fi
	} 2>>"${LOG_FILE}"; then
		msg -s "Done, xstartup script created successfully!"
	else
		msg -e "Sorry, I failed to create the xstartup script for vnc."
	fi
}

# Called before making configurations
# New Variables: none
pre_config_actions() {
	echo "${ROOTFS_DIRECTORY}" >"${ROOTFS_DIRECTORY}/etc/debian_chroot"
}

# Called after configurations
# New Variables: none
post_config_actions() {
	# Fix environment variables on login or su. (#17 fix)
	local fix="session  required  pam_env.so readenv=1"
	for f in su su-l system-local-login system-remote-login; do
		if [ -f "${ROOTFS_DIRECTORY}/etc/pam.d/${f}" ] && ! grep -q "${fix}" "${ROOTFS_DIRECTORY}/etc/pam.d/${f}" &>>"${LOG_FILE}"; then
			echo "${fix}" >>"${ROOTFS_DIRECTORY}/etc/pam.d/${f}"
		fi
	done
	# execute distro specific command for locale generation
	if [ -f "${ROOTFS_DIRECTORY}/etc/locale.gen" ] && [ -x "${ROOTFS_DIRECTORY}/sbin/dpkg-reconfigure" ]; then
		msg -t "Hold on while I generate the locales for you."
		sed -i -E 's/#[[:space:]]?(en_US.UTF-8[[:space:]]+UTF-8)/\1/g' "${ROOTFS_DIRECTORY}/etc/locale.gen"
		if distro_exec DEBIAN_FRONTEND=noninteractive /sbin/dpkg-reconfigure locales &>>"${LOG_FILE}"; then
			msg -s "Done, the locales are ready!"
		else
			msg -e "Sorry, I failed to generate the locales."
		fi
	fi
}

# Called before complete message
# New Variables: none
pre_complete_actions() {
	return
}

# Called after complete message
# New Variables: none
post_complete_actions() {
	if ${ACTION_INSTALL} && [ -n "${SELECTED_INSTALLATION}" ] && [ "${SELECTED_INSTALLATION}" != "full" ]; then
		msg -te "Remember, this is a ${SELECTED_INSTALLATION} installation of ${DISTRO_NAME}."
		msg "If you need to install additional packages, check out the documentation for a guide."
	fi
}

DISTRO_NAME="Kali NetHunter"
PROGRAM_NAME="$(basename "${0}")"
DISTRO_REPOSITORY="termux-nethunter"
VERSION_NAME="2025.1a"

SHASUM_CMD=sha256sum
TRUSTED_SHASUMS="$(
	cat <<-EOF
		bc77fc4e67ef3fb6fedee76c23a4368509a949982c6b745441d82f32e562816c  kali-nethunter-rootfs-full-arm64.tar.xz
		a5c3e87748c41c711771c16a60811c114cb8abaa8a5e1c9ac1c52e833bbe611d  kali-nethunter-rootfs-full-armhf.tar.xz
		7bfb05c8b29813932f09999c9ad32d6b0aa0ca40667c2d1c926ecf0c3ed3c51e  kali-nethunter-rootfs-minimal-arm64.tar.xz
		f424766aa5371f6a9588380c95ea9b16dffcdb39b0ab1f3630fdd613fa2ebbf3  kali-nethunter-rootfs-minimal-armhf.tar.xz
		9a785eb238151d0822a33f182658262c08d97cc231024cf54de0c0e5d6f338d4  kali-nethunter-rootfs-nano-arm64.tar.xz
		1aedc42b5a2d64064fc3916a973d15a176ed294b56d06c091da2247f11a5fb05  kali-nethunter-rootfs-nano-armhf.tar.xz
	EOF
)"

ARCHIVE_STRIP_DIRS=1 # directories stripped by tar when extracting rootfs archive
KERNEL_RELEASE="6.2.1-nethunter-proot"
BASE_URL="https://kali.download/nethunter-images/kali-${VERSION_NAME}/rootfs"

TERMUX_FILES_DIR="/data/data/com.termux/files"

DISTRO_SHORTCUT="${TERMUX_FILES_DIR}/usr/bin/nh"
DISTRO_LAUNCHER="${TERMUX_FILES_DIR}/usr/bin/nethunter"

DEFAULT_ROOTFS_DIR="${TERMUX_FILES_DIR}/kali"
DEFAULT_LOGIN="kali"

# WARNING!!! DO NOT CHANGE BELOW!!!

# Check in script's directory for template
distro_template="$(realpath "$(dirname "${0}")")/termux-distro.sh"
# shellcheck disable=SC1090
if [ -f "${distro_template}" ] && [ -r "${distro_template}" ]; then
	source "${distro_template}" "${@}"
elif curl -fsSLO "https://raw.githubusercontent.com/jorexdeveloper/termux-distro/main/termux-distro.sh" 2>"/dev/null" && [ -f "${distro_template}" ]; then
	source "${distro_template}"
else
	echo "You need an active internet connection to run this script."
fi
