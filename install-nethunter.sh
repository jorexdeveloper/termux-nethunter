#!/data/data/com.termux/files/usr/bin/bash

################################################################################
#                                                                              #
#     Termux NetHunter Installer.                                              #
#                                                                              #
#     Installs Kali NetHunter in Termux.                                       #
#                                                                              #
#     Copyright (C) 2023-2025  Jore <https://github.com/jorexdeveloper>        #
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
# shellcheck disable=SC2034,SC2155

# ATTENTION!!! CHANGE BELOW FUNTIONS FOR DISTRO DEPENDENT ACTIONS!!!

################################################################################
# Called before any safety checks                                              #
# New Variables: AUTHOR GITHUB LOG_FILE ACTION_INSTALL ACTION_CONFIGURE        #
#                ROOTFS_DIRECTORY COLOR_SUPPORT all_available_colors           #
################################################################################
pre_check_actions() {
	return
}

################################################################################
# Called before printing intro                                                 #
# New Variables: none                                                          #
################################################################################
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
	if [ -z "${KEEP_ROOTFS_DIRECTORY}" ]; then
		choose -d2 -t "Select your prefered installation." \
			"full - GUI + All ${DISTRO_NAME} Packages" \
			"mini - Essential Packages Only" \
			"nano - Essential Packages++"
		SELECTED_INSTALLATION=${?}
		case "${SELECTED_INSTALLATION}" in
			1)
				SELECTED_INSTALLATION="full"
				GUI_INSTALLED=true
				;;
			3) SELECTED_INSTALLATION="nano" ;;
			*) SELECTED_INSTALLATION="mini" ;;
		esac
		msg "Okay then, I shall install a '${Y}${SELECTED_INSTALLATION}${C}' rootfs."
		ARCHIVE_NAME="kali-nethunter-rootfs-${SELECTED_INSTALLATION/mini/minimal}-${SYS_ARCH}.tar.xz"
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
	mkdir -p "${ROOTFS_DIRECTORY}/etc" >>"${LOG_FILE}" 2>&1 && echo "${ROOTFS_DIRECTORY}" >"${ROOTFS_DIRECTORY}/etc/debian_chroot"
}

################################################################################
# Called after configurations                                                  #
# New Variables: none                                                          #
################################################################################
post_config_actions() {
	# Fix environment variables on login or su. (#17 fix)
	# local fix="session  required  pam_env.so readenv=1"
	# for f in su su-l system-local-login system-remote-login; do
	# 	if [ -f "${ROOTFS_DIRECTORY}/etc/pam.d/${f}" ] && ! grep -q "${fix}" "${ROOTFS_DIRECTORY}/etc/pam.d/${f}" >>"${LOG_FILE}" 2>&1; then
	# 		echo "${fix}" >>"${ROOTFS_DIRECTORY}/etc/pam.d/${f}"
	# 	fi
	# done
	# execute distro specific command for locale generation
	if [ -f "${ROOTFS_DIRECTORY}/etc/locale.gen" ] && [ -x "${ROOTFS_DIRECTORY}/sbin/dpkg-reconfigure" ]; then
		msg -t "Hold on while I generate the locales for you."
		sed -i -E 's/#[[:space:]]?(en_US.UTF-8[[:space:]]+UTF-8)/\1/g' "${ROOTFS_DIRECTORY}/etc/locale.gen"
		if distro_exec DEBIAN_FRONTEND=noninteractive /sbin/dpkg-reconfigure locales >>"${LOG_FILE}" 2>&1; then
			msg -s "Done, the locales are ready!"
		else
			msg -e "I failed to generate the locales."
		fi
	fi
}

################################################################################
# Called before complete message                                               #
# New Variables: none                                                          #
################################################################################
pre_complete_actions() {
	if ! ${GUI_INSTALLED:-false} && [ "${SELECTED_INSTALLATION}" != "full" ] && ask -y -- -t "Should I set up the GUI now?"; then
		set_up_gui && set_up_browser && GUI_INSTALLED=true
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

# Sets up the GUI
set_up_gui() {
	local available_desktops=(
		"E17" "GNOME" "i3" "KDE" "LXDE" "MATE" "Xfce"
	)
	local -A xstartups=(
		["e17"]="enlightenment_start" ["gnome"]="gnome-session" ["i3"]="i3" ["kde"]="startplasma-x11" ["lxde"]="startlxde" ["mate"]="mate-session" ["xfce"]="startxfce4"
	)
	choose -d7 -t "Select your prefered Desktop Environment." \
		"${available_desktops[@]}"
	selected_desktop="${available_desktops[$((${?} - 1))]}"
	msg "Okay then, I shall install the '${Y}${selected_desktop}${C}' Desktop."
	msg -t "The installation is going to take very long."
	msg "Lemme me acquire the '${Y}Termux wake lock${C}'."
	if [ -x "$(command -v termux-wake-lock)" ]; then
		if termux-wake-lock >>"${LOG_FILE}" 2>&1; then
			msg -s "Great, the Termux wake lock is now activated."
		else
			msg -e "I have failed to set up the Termux wake lock."
			msg "Keep Termux open during the installation."
		fi
	else
		msg -e "I could not find the '${Y}termux-wake-lock${R}' command."
		msg "Keep Termux open during the installation."
	fi
	msg -t "Lemme first upgrade the packages in ${DISTRO_NAME}."
	msg "This won't take long."
	if distro_exec apt update && distro_exec apt full-upgrade; then
		msg -s "Done, all the ${DISTRO_NAME} packages are upgraded."
		msg -t "Now lemme install the GUI in ${DISTRO_NAME}."
		msg "This will take very long."
		if distro_exec apt install -y tigervnc-standalone-server dbus-x11 kali-desktop-"${selected_desktop,,}"; then
			msg -s "Finally, the GUI is now installed in ${DISTRO_NAME}."
			msg -t "Now lemme add the xstartup script for VNC."
			if {
				local xstartup="$(
					cat 2>>"${LOG_FILE}" <<-EOF
						#!/usr/bin/bash
						unset SESSION_MANAGER
						unset DBUS_SESSION_BUS_ADDRESS
						export XDG_RUNTIME_DIR=\${TMPDIR:-/tmp}/runtime-"\${USER:-root}"
						export SHELL="\${SHELL:-/bin/sh}"
						if [ -r ~/.Xresources ]; then
						    xrdb ~/.Xresources
						fi
						exec ${xstartups["${selected_desktop,,}"]}
					EOF
				)"
				mkdir -p "${ROOTFS_DIRECTORY}/root/.vnc"
				echo "${xstartup}" >"${ROOTFS_DIRECTORY}/root/.vnc/xstartup"
				chmod 744 "${ROOTFS_DIRECTORY}/root/.vnc/xstartup"
				if [ "${DEFAULT_LOGIN}" != "root" ]; then
					mkdir -p "${ROOTFS_DIRECTORY}/home/${DEFAULT_LOGIN}/.vnc"
					echo "${xstartup}" >"${ROOTFS_DIRECTORY}/home/${DEFAULT_LOGIN}/.vnc/xstartup"
					chmod 744 "${ROOTFS_DIRECTORY}/home/${DEFAULT_LOGIN}/.vnc/xstartup"
				fi
			} 2>>"${LOG_FILE}"; then
				msg -s "Done, xstartup script added successfully!"
			else
				msg -e "I failed to add the xstartup script."
			fi
		else
			msg -qm0 "I have failed to install the GUI in ${DISTRO_NAME}."
		fi
	else
		msg -qm0 "I have failed to upgrade the packages in ${DISTRO_NAME}."
	fi
}

# Sets up the Browser
set_up_browser() {
	local available_browsers=(
		"Chromium" "Firefox ESR" "Both Browsers"
	)
	choose -d2 -t "Select your prefered Browser." \
		"${available_browsers[@]}"
	local selected_browser="${available_browsers[$((${?} - 1))]}"
	local selected_browsers verb
	if [ "${selected_browser}" = "${available_browsers[-1]}" ]; then
		selected_browsers=("${available_browsers[@]:0:${#available_browsers[@]}-1}")
		selected_browsers=("${selected_browsers[@]// /-}")
		verb="are"
	else
		selected_browsers=("${selected_browser// /-}")
		verb="is"
	fi
	msg "Okay then, I shall install '${Y}${selected_browser}${C}'."
	if distro_exec apt install -y "${selected_browsers[@],,}"; then
		if [ "${selected_browsers[0]}" = "${available_browsers[0]}" ]; then
			sed -Ei 's/^(Exec=.*chromium).*(%U)$/\1 --no-sandbox \2/' "${ROOTFS_DIRECTORY}/usr/share/applications/chromium.desktop"
		fi
		msg "Done, ${selected_browser} ${verb} now installed in ${DISTRO_NAME}."
	else
		msg -e "I have failed to install ${selected_browser} in ${DISTRO_NAME}."
	fi
}

DISTRO_NAME="Kali NetHunter"
PROGRAM_NAME="$(basename "${0}")"
DISTRO_REPOSITORY="termux-nethunter"
VERSION_NAME="2025.3"
KERNEL_RELEASE="$(uname -r)"

SHASUM_CMD=sha256sum
TRUSTED_SHASUMS="$(
	cat <<-EOF
		8dd42a9c8eb6cb7efcb169a6824b2cdc61ff0f999e87b30effa11832c528916e  kali-nethunter-rootfs-minimal-arm64.tar.xz
		709f131a7b8ca25073553b8ac8065cf9f9d113e764d1f5f4c03c54cb47fc4475  kali-nethunter-rootfs-minimal-armhf.tar.xz
		771f511202c28074a1756859ac8211bed9d85a1cf4eddba19416b12e05492d24  kali-nethunter-rootfs-nano-arm64.tar.xz
		ae1c75b78dd1c70f37fd748561a5272015a1ae054335d78de9f0a6ed49dc1bdb  kali-nethunter-rootfs-nano-armhf.tar.xz
		b7c60dd5a1db33b399afcecc40be39415f5593f7302b6573aece1265dae44d73  kali-nethunter-rootfs-full-arm64.tar.xz
		11ee09de068493a6f7a2c8f6b1e0d5a18cb3cc511f25aca7db99e1ede82c0e15  kali-nethunter-rootfs-full-armhf.tar.xz
	EOF
)"

ARCHIVE_STRIP_DIRS=1 # directories stripped by tar when extracting rootfs archive
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
