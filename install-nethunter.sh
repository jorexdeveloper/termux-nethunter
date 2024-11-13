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
	# No need to select installation if using existing directory
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
			#!/usr/bin/bash
			#############################
			##          All            ##
			export XDG_RUNTIME_DIR=/tmp/runtime-"\${USER-root}"
			export SHELL="\${SHELL-/usr/bin/sh}"

			unset SESSION_MANAGER
			unset DBUS_SESSION_BUS_ADDRESS

			xrdb "\${HOME-/tmp}"/.Xresources

			#############################
			##          Gnome          ##
			# export XKL_XMODMAP_DISABLE=1
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
		EOF
	)"
	if {
		mkdir -p "${ROOTFS_DIRECTORY}/root/.vnc"
		echo "${xstartup}" >"${ROOTFS_DIRECTORY}/root/.vnc/xstartup"
		chmod 744 "${ROOTFS_DIRECTORY}/root/.vnc/xstartup"
		if [ "${DEFAULT_LOGIN}" != "root" ]; then
			mkdir -p "${ROOTFS_DIRECTORY}/${DEFAULT_LOGIN}/.vnc"
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
	return
}

# Called after configurations
# New Variables: none
post_config_actions() {
	# execute distro specific command for locale generation
	if [ -f "${ROOTFS_DIRECTORY}/etc/locale.gen" ] && [ -x "${ROOTFS_DIRECTORY}/sbin/dpkg-reconfigure" ]; then
		msg -t "Hold on while I generate the locales for you."
		sed -i -E 's/#[[:space:]]?(en_US.UTF-8[[:space:]]+UTF-8)/\1/g' "${ROOTFS_DIRECTORY}/etc/locale.gen"
		if distro_exec DEBIAN_FRONTEND=noninteractive /sbin/dpkg-reconfigure locales &>"${LOG_FILE}"; then
			msg -s "Yup, locales are ready!"
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
	# Print only when installation is made
	if ${ACTION_INSTALL} && [ "${SELECTED_INSTALLATION}" != "full" ]; then
		msg -te "Remember, this is a ${SELECTED_INSTALLATION} installation of ${DISTRO_NAME}."
		msg "If you need to install additional packages, check out the documentation for a guide."
	fi
}

DISTRO_NAME="Kali NetHunter"
PROGRAM_NAME="$(basename "${0}")"
DISTRO_REPOSITORY="termux-nethunter"
VERSION_NAME="2024.3"

SHASUM_TYPE=512
TRUSTED_SHASUMS="$(
	cat <<-EOF
		aba9be5d08d982da1e4726d1073284446d67c4d9b571b1dfa6ff1963e0050212dd0a78613565b4ff3443e8fc581726b58133d89dd6f6cd664562aa4611346b17  kali-nethunter-rootfs-full-arm64.tar.xz
		c045d0d5bbb08667803b23d653cd1de1869d42b7437c3de8dce241361c28a75396e879e01fb68060321b97af9ceea81142b44ef71558d2b60ff292d7a7dc5aaa  kali-nethunter-rootfs-full-armhf.tar.xz
		9bd6e478b0ffaf8ef64664a0cac3f6900ad43919a6595b81ad3c317a974224b088ac78e1357aae1dbd2359f9de1510bc840674709cd5ae75e883a07aa65ad2ed  kali-nethunter-rootfs-minimal-arm64.tar.xz
		6f143c93a1a0cca739ecf51d0091a7850e4ec135e66b5dc66d30969ef924ea9ba71186b8bf9b725f670785867e2ba5ac57afbd577eb6850d35cb5adbdefc1cd8  kali-nethunter-rootfs-minimal-armhf.tar.xz
		4cf9db4ffd68a35895dfbe7cd90058a671a32e24959e6fc89e6645b9b6c0275d2398fbea82b1f3efd80664b4c324f9cb1c631c76717c0b7573a0d86e12231b99  kali-nethunter-rootfs-nano-arm64.tar.xz
		10e5bf2e7a950a8ebdf7f0410feff52c6067c3ffbba7cb1164b082329c3b5759e81573839c63184be642a44e7cd581186f645910f29bd85c5f488a1ae8692fd9  kali-nethunter-rootfs-nano-armhf.tar.xz
	EOF
)"

ARCHIVE_STRIP_DIRS=2 # directories stripped by tar when extracting rootfs archive
KERNEL_RELEASE="6.2.1-nethunter-proot"
BASE_URL="https://kali.download/nethunter-images/kali-${VERSION}/rootfs"

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
