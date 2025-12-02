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

# Sets up the desktop environment
set_up_de() {
	local available_desktops=(
		E17 GNOME i3 KDE LXDE MATE Xfce
	)
	local -A xstartups=(
		[e17]=enlightenment_start [gnome]=gnome-session [i3]=i3 [kde]=startplasma-x11 [lxde]=startlxde [mate]=mate-session [xfce]=startxfce4
	)

	choose -d7 -t "Select Desktop Environment" \
		"${available_desktops[@]}"
	selected_desktop=${available_desktops[$((${?} - 1))]}

	msg -t "Installing ${selected_desktop} Desktop"

	if command -v termux-wake-lock &>>"${LOG_FILE}"; then
		msg -tn "Acquiring Termux wake lock..."

		if termux-wake-lock &>>"${LOG_FILE}"; then
			cursor -u1
			msg -ts "Termux wake lock held"
		else
			cursor -u1
			msg -te "Failed to acquire Termux wake lock"
		fi
	fi

	msg -tn "Installing ${selected_desktop} packages in ${DISTRO_NAME}..."
	trap 'buffer -h; echo; msg -fem2; exit 130' INT
	buffer -s

	local pkgs=(tigervnc-standalone-server dbus-x11 kali-desktop-"${selected_desktop,,}")
	if buffer -i apt update && distro_exec apt update &&
		buffer -i apt full-upgrade && distro_exec apt full-upgrade &&
		buffer -i apt install -y "${pkgs[@]}" && distro_exec apt install -y "${pkgs[@]}"; then
		buffer -h3
		trap - INT
		cursor -u1
		msg -ts "${selected_desktop} packages installed in ${DISTRO_NAME}"

		msg -tn "Creating xstartup program..."

		local xstartup=$(
			cat 2>>"${LOG_FILE}" <<-EOF
				#!/bin/bash
				unset SESSION_MANAGER
				unset DBUS_SESSION_BUS_ADDRESS

				export XDG_RUNTIME_DIR=\${TMPDIR:-/tmp}/runtime-"\$(id -u)"
				export SHELL=\${SHELL:-/bin/sh}

				if [[ -r ~/.Xresources ]]; then
				    xrdb ~/.Xresources
				fi

				exec ${xstartups["${selected_desktop,,}"]}
			EOF
		)

		if {
			mkdir -p "${ROOTFS_DIRECTORY}"/root/.vnc &&
				echo "${xstartup}" >"${ROOTFS_DIRECTORY}"/root/.vnc/xstartup &&
				chmod 744 "${ROOTFS_DIRECTORY}"/root/.vnc/xstartup &&
				if [[ ${DEFAULT_LOGIN} != root ]]; then
					mkdir -p "${ROOTFS_DIRECTORY}"/home/"${DEFAULT_LOGIN}"/.vnc &&
						echo "${xstartup}" >"${ROOTFS_DIRECTORY}"/home/"${DEFAULT_LOGIN}"/.vnc/xstartup &&
						chmod 744 "${ROOTFS_DIRECTORY}"/home/"${DEFAULT_LOGIN}"/.vnc/xstartup
				fi
		} 2>>"${LOG_FILE}"; then
			cursor -u1
			msg -ts "Xstartup program created"
		else
			cursor -u1
			msg -te "Failed create xstartup program"
		fi
	else
		buffer -h5
		trap - INT
		cursor -u1
		msg -te "Failed to install ${selected_desktop} packages in ${DISTRO_NAME}"
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
VERSION_NAME=2025.3

SHASUM_CMD=sha256sum
TRUSTED_SHASUMS=$(
	cat <<-EOF
		8dd42a9c8eb6cb7efcb169a6824b2cdc61ff0f999e87b30effa11832c528916e  kali-nethunter-rootfs-minimal-arm64.tar.xz
		709f131a7b8ca25073553b8ac8065cf9f9d113e764d1f5f4c03c54cb47fc4475  kali-nethunter-rootfs-minimal-armhf.tar.xz
		771f511202c28074a1756859ac8211bed9d85a1cf4eddba19416b12e05492d24  kali-nethunter-rootfs-nano-arm64.tar.xz
		ae1c75b78dd1c70f37fd748561a5272015a1ae054335d78de9f0a6ed49dc1bdb  kali-nethunter-rootfs-nano-armhf.tar.xz
		b7c60dd5a1db33b399afcecc40be39415f5593f7302b6573aece1265dae44d73  kali-nethunter-rootfs-full-arm64.tar.xz
		11ee09de068493a6f7a2c8f6b1e0d5a18cb3cc511f25aca7db99e1ede82c0e15  kali-nethunter-rootfs-full-armhf.tar.xz
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
