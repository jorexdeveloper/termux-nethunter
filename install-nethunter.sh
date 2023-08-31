#!/data/data/com.termux/files/usr/bin/bash

################################################################################
#                                                                              #
#     Kali NetHunter Installer, version 1.1                                    #
#                                                                              #
#     Install Kali NetHunter in Termux.                                        #
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

################################################################################
#                                FUNCTIONS                                     #
################################################################################

# Prints program version
function _PRINT_VERSION() {
	printf "${Y}Kali NetHunter Installer${C}, version ${Y}${VERSION}${N}\n"
	printf "${C}Copyright (C) 2023 Jore <https://github.com/jorexdeveloper>.${N}\n"
	printf "${C}License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>${N}\n\n"
	printf "${C}This is free software; you are free to change and redistribute it.${N}\n"
	printf "${C}There is NO WARRANTY, to the extent permitted by law.${N}\n"
}

# Prints program usage
function _PRINT_USAGE() {
	printf "${C}Usage: ${Y}$(basename "$0")${C} [${Y}option${C}]... [${Y}DIRECTORY${C}]${N}\n\n"
	printf "${C}Install Kali NetHunter in the specified directory or ${Y}~/kali-<sys_arch>${C} if unspecified.${N}\n"
	printf "${C}The ${Y}specified directory ${R}MUST${Y} be within Termux${C} or the default directory is used.${N}\n\n"
	printf "${C}Options:${N}\n"
	printf "${C}  --no-check-certificate${N}\n"
	printf "${C}          This option is passed to 'wget' while downloading files.${N}\n"
	printf "${C}  -h, --help${N}\n"
	printf "${C}          Print this message and exit.${N}\n"
	printf "${C}  -v. --version${N}\n"
	printf "${C}          Print version and exit.${N}\n\n"
	printf "${C}For more information, visit <${Y}https://github.com/jorexdeveloper/Install-NetHunter-Termux${C}>.${N}\n"
}

# Prints Kali banner
function _BANNER() {
	clear
	printf "${G}┌────────────────────────────────────────┐${N}\n"
	printf "${G}│╻┏ ┏━┓╻  ╻   ┏┓╻┏━╸╺┳╸╻ ╻╻ ╻┏┓╻╺┳╸┏━╸┏━┓│${N}\n"
	printf "${G}│┣┻┓┣━┫┃  ┃   ┃┗┫┣╸  ┃ ┣━┫┃ ┃┃┗┫ ┃ ┣╸ ┣┳┛│${N}\n"
	printf "${G}│╹ ╹╹ ╹┗━╸╹   ╹ ╹┗━╸ ╹ ╹ ╹┗━┛╹ ╹ ╹ ┗━╸╹┗╸│${N}\n"
	printf "${G}└────────────────────────────────────────┘${N}\n"
	printf "${G}[Version: ${Y}${VERSION}${G}]              [Author: ${Y}Jore${G}]${N}\n"
}

# Gets system architecture or exits script if unsupported
# Sets SYS_ARCH LIB_GCC_PATH
function _CHECK_ARCH() {
	printf "${C}\n[${Y}*${C}] Checking device architecture.${N}\n"
	case $(getprop ro.product.cpu.abi 2>/dev/null) in
		arm64-v8a)
			SYS_ARCH="arm64"
			LIB_GCC_PATH="/usr/lib/aarch64-linux-gnu/libgcc_s.so.1"
			;;
		armeabi | armeabi-v7a)
			SYS_ARCH="armhf"
			LIB_GCC_PATH="/usr/lib/arm-linux-gnueabihf/libgcc_s.so.1"
			;;
		*)
			printf "${R}[${Y}!${R}] Unsupported architecture.${N}\n"
			exit 1
			;;
	esac
}

# Installs required dependencies
function _CHECK_DEPENDENCIES() {
	printf "${C}\n[${Y}*${C}] Checking package dependencies.${N}\n"
	# Workaround for termux-app issue #1283 (https://github.com/termux/termux-app/issues/1283)
	# apt update -y &> /dev/null
	apt-get update -y &>/dev/null || apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" dist-upgrade -y &>/dev/null
	for i in wget proot tar pulseaudio; do
		if [ -e "$PREFIX/bin/${i}" ]; then
			printf "${G}[${Y}=${G}] ${i} installed.${N}\n"
		else
			printf "${C}[${Y}*${C}] Installing ${i}.${N}\n"
			apt-get install -y "$i" &>/dev/null || {
				printf "${R}[${Y}!${R}] Failed to install ${i}.${N}\n"
				exit 1
			}
		fi
	done
}

# Prompts for the required image installation
# Sets IMAGE_NAME SHA_NAME SELECTED_IMAGE
function _SELECT_IMAGE() {
	if [ "${SYS_ARCH}" = "arm64" ]; then
		printf "\n${G}  [${Y}1${G}] ${C}NetHunter ARM64 (full)${N}\n"
		printf "\n${G}  [${Y}2${G}] ${C}NetHunter ARM64 (mini)${N}\n"
		printf "\n${G}  [${Y}3${G}] ${C}NetHunter ARM64 (nano)${N}\n"
	elif [ "${SYS_ARCH}" = "armhf" ]; then
		printf "\n${G}  [${Y}1${G}] ${C}NetHunter ARMhf (full)${N}\n"
		printf "\n${G}  [${Y}2${G}] ${C}NetHunter ARMhf (mini)${N}\n"
		printf "\n${G}  [${Y}3${G}] ${C}NetHunter ARMhf (nano)${N}\n"
	fi
	printf "${C}\n[${Y}*${C}] Select image (default mini): ${N}"
	read -rn 1 SELECTED_IMAGE
	case "${SELECTED_IMAGE}" in
		1) printf "\n${G}[${Y}=${G}] Full image selected${N}\n" && SELECTED_IMAGE="full" ;;
		2) printf "\n${G}[${Y}=${G}] Mini image selected${N}\n" && SELECTED_IMAGE="minimal" ;;
		3) printf "\n${G}[${Y}=${G}] Nano image selected${N}\n" && SELECTED_IMAGE="nano" ;;
		*) printf "\n${G}[${Y}=${G}] Mini image selected${N}\n" && SELECTED_IMAGE="minimal" ;;
	esac
	IMAGE_NAME="kalifs-${SYS_ARCH}-${SELECTED_IMAGE}.tar.xz"
	SHA_NAME="kalifs-${SYS_ARCH}-${SELECTED_IMAGE}.sha512sum"
}

# Prompts whether to delete existing rootfs folder if any
# Sets KEEP_ROOTFS_DIR
function _CHECK_ROOTFS_DIR() {
	unset KEEP_ROOTFS_DIR
	if [ -d "${ROOTFS_DIR}" ]; then
		if _ASK "Existing ${Y}rootfs directory${C} found. Delete and create a new one?" "N"; then
			printf "${R}[${Y}!${R}] Deleting rootfs directory.${N}\n"
			rm -rf "${ROOTFS_DIR}"
		else
			printf "${Y}[${R}!${Y}] Using existing rootfs directory.${N}\n"
			KEEP_ROOTFS_DIR=1
		fi
	fi
}

# Downloads roots file and SHA or prompts if it exists
# Sets KEEP_IMAGE
function _GET_ROOTFS() {
	unset KEEP_IMAGE
	if [ -z "${KEEP_ROOTFS_DIR}" ]; then
		if [ -f "${IMAGE_NAME}" ]; then
			if _ASK "Existing ${Y}image file${C} found. Delete and download a new one." "N"; then
				printf "${R}[${Y}!${R}] Deleting image file.${N}\n"
				rm -f "${IMAGE_NAME}" "${SHA_NAME}"
			else
				printf "${Y}[${R}!${Y}] Using existing rootfs archive${N}\n"
				KEEP_IMAGE=1
				return
			fi
		fi
		printf "\n${C}[${Y}*${C}] Downloading rootfs.${N}\n"
		wget "${EXTRA_ARGS}" --verbose --continue --show-progress --output-document="${IMAGE_NAME}" "${BASE_URL}/${IMAGE_NAME}"
		printf "\n${C}[${Y}*${C}] Downloading SHA. ${N}\n"
		wget "${EXTRA_ARGS}" --verbose --continue --show-progress --output-document="${SHA_NAME}" "${BASE_URL}/${SHA_NAME}"
	fi
}

# Verifies SHA
function _VERIFY_SHA() {
	if [ -z $KEEP_ROOTFS_DIR ]; then
		printf "\n${C}[${Y}*${C}] Verifying integrity of rootfs archive.${N}\n"
		sha512sum -c "$SHA_NAME" &>/dev/null || {
			printf "${R}[${Y}!${R}] Rootfs corrupted. Please run this installer again or download the file manually.${N}\n"
			exit 1
		}
	fi
}

# Extracts rootfs if it was downloaded
function _EXTRACT_ROOTFS() {
	if [ -z "${KEEP_ROOTFS_DIR}" ] && mkdir -p "${ROOTFS_DIR}"; then
		printf "\n${C}[${Y}*${C}] Extracting rootfs. This may take long.${N}\n"
		local xdir="${TMPDIR}/kali-${SYS_ARCH}"
		# Remove existing directory before extraction
		if [ -e "${xdir}" ]; then
			rm -rf "${xdir}"
		fi
		# Extract in background to TMPDIR (PREFIX/tmp) then rename to ROOTFS_DIR
		(
			proot --link2symlink tar --extract --file "${IMAGE_NAME}" --directory="${TMPDIR}" &>/dev/null
			if [ -d "${xdir}" ]; then
				# Remove ROOTFS_DIR to prevent moving into it since we are renaming
				if [ -d "${ROOTFS_DIR}" ]; then
					rm -rf "${ROOTFS_DIR}"
				fi
				mv "${xdir}" "${ROOTFS_DIR}"
			else
				printf "${R}[${Y}!${R}] Fatal extraction error.${N}\n"
				pkill -9 proot &>/dev/null
				pkill -9 tar &>/dev/null
				exit 1
			fi
		) &
		# Wait for extraction process to begin
		sleep 5
		local imsize="$(xz -l "${IMAGE_NAME}" | awk 'NR==2 {print $5}')"
		# Monitor extraction process
		while true; do
			if [ -d "${xdir}" ]; then
				printf "${C}[${Y}*${C}] Extracted: ${G}$(du -sh "${xdir}" 2>/dev/null | cut -f 1 2>/dev/null)iB / ${imsize}${Y}+${G}MiB    ${N}\r"
			else
				printf "${G}[${Y}*${G}] Extraction complete.                  ${N}\n"
				break
			fi
		done
	fi
}

# Creates a script to launch NetHunter
function _CREATE_LAUNCHER() {
	printf "\n${C}[${Y}*${C}] Creating NetHunter launcher.${N}\n"
	local NH_LAUNCHER="${PREFIX}/bin/nethunter"
	local NH_SHORTCUT="${PREFIX}/bin/nh"
	mkdir -p "$(dirname "${NH_LAUNCHER}")" && cat >"$NH_LAUNCHER" <<-EOF
		#!/data/data/com.termux/files/usr/bin/bash -e

		# For enabling audio playing in distro, for rooted user, add --system
		pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1

		# unset LD_PRELOAD in case termux-exec is installed
		unset LD_PRELOAD

		# Workaround for Libreoffice, also needs to bind a fake /proc/version
		[ ! -f "${ROOTFS_DIR}/root/.version" ] && touch "${ROOTFS_DIR}/root/.version"

		# Command to start distro
		command="proot \\
		         --link2symlink \\
		         --kill-on-exit \\
		         --root-id \\
		         --rootfs=${ROOTFS_DIR} \\
		         --bind=/dev \\
		         --bind=/proc \\
		         --bind=${ROOTFS_DIR}/root:/dev/shm \\
		         --bind=\$([ ! -z \${INTERNAL_STORAGE} ] && echo \${INTERNAL_STORAGE} || echo /sdcard):/mnt/sd0 \\
		         --bind=\$([ ! -z \${EXTERNAL_STORAGE} ] && echo \${EXTERNAL_STORAGE} || echo /sdcard):/mnt/sd1 \\
		         --cwd=/ \\
		            /usr/bin/env -i \\
		            TERM=\${TERM} \\
		            LANG=C.UTF-8 \\
		            /usr/bin/login \\
		        "
		exec \${command}
	EOF
	chmod 700 "$NH_LAUNCHER"
	if [ -L "${NH_SHORTCUT}" ]; then
		rm -f "${NH_SHORTCUT}"
	fi
	if [ ! -f "${NH_SHORTCUT}" ]; then
		ln -s "${NH_LAUNCHER}" "${NH_SHORTCUT}" &>/dev/null
	fi
}

# Creates a script to start vnc in NetHunter
function _CREATE_VNC_LAUNCHER() {
	printf "\n${C}[${Y}*${C}] Creating VNC launcher.${N}\n"
	mkdir -p $ROOTFS_DIR/usr/local/bin && VNC_LAUNCHER=${ROOTFS_DIR}/usr/local/bin/vnc && cat >"$VNC_LAUNCHER" <<-EOF
		#!/bin/bash -e

		depth=24
		width=720
		height=1600
		orientation=landscape
		display=\$(echo \${DISPLAY} | cut -d : -f 2)

		function check_user() {
		    if [ "\${USER}" = "root" ] || [ "\$EUID" -eq 0 ] || [ "\$(whoami)" = "root" ]; then
		        read -p "[!] Warning: You are starting VNC as root user, some applications are not meant to be run as root and may not work properly. Do you want to continue? y/N" -rn 1 REPLY && echo && case "\${REPLY}" in y|Y) ;; *) exit 1 ;; esac
		    fi
		}

		function clean_tmp() {
		    rm -rf "/tmp/.X\${display}-lock"
		    rm -rf "/tmp/.X11-unix/X\${display}"
		}

		function set_geometry() {
		    case "\$orientation" in
		        "potrait")
		            geometry="\${width}x\${height}"
		            ;;
		        *)
		            geometry="\${height}x\${width}"
		            ;;
		    esac
		}

		function start_pulseaudio() {
		    if [ -f "/bin/pulseaudio" ] || ! which pulseaudio &>/dev/null; then
		        pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
		    else
		        echo "[!] Pulse Audio not installed, you may not get audio output."
		    fi
		}

		function set_passwd() {
		    vncpasswd
		    return \$?
		}

		function start_server() {
		    if [ -f "\${HOME}/.vnc/passwd" ]; then
		        export HOME="\${HOME}"
		        export USER="\${USER}"
		        LD_PRELOAD="${LIB_GCC_PATH}"
		        # You can use nohup
		        vncserver ":\$display" -geometry "\$geometry" -depth "\$depth" -name remote-desktop && echo -e "\n[*] VNC Server started successfully."
		    else
		        set_passwd && start_server
		    fi
		}

		function kill_server() {
		    # [ -f "/bin/pulseaudio" ] && pulseaudio --kill || pkill -9 pulseaudio
		    clean_tmp
		    vncserver -clean -kill ":\$display"
		    return \$?
		}

		function print_help() {
		    printf "Usage: \$(basename $0) [option]...\n\n"
		    printf "Start VNC Server.\n\n"
		    printf "Options:\n"
		    printf "  --potrait\n"
		    printf "          Use potrait orientation.\n"
		    printf "  --landscape\n"
		    printf "          Use landscape orientation. (default)\n"
		    printf "  -p, --password\n"
		    printf "          Set or change password.\n"
		    printf "  -s, --start\n"
		    printf "          Start vncserver. (default if no options supplied)\n"
		    printf "  -k, --kill\n"
		    printf "          Kill vncserver.\n"
		    printf "  -h, --help\n"
		    printf "          Print this message and exit.\n"
		}

		############################################
		##               Entry Point              ##
		############################################

		for option in \$@; do
		    case \$option in
		        "--potrait")
		            orientation=potrait
		            ;;
		        "--landscape")
		            orientation=landscape
		            ;;
		        "-p"|"--password")
		            set_passwd
		            exit
		            ;;
		        "-s"|"--start")
		            ;;
		        "-k"|"--kill")
		            kill_server
		            exit
		            ;;
		        "-h"|"--help")
		            _PRINT_USAGE
		            exit
		            ;;
		        *)
		            echo "Unknown option '\$option'."
		            print_help
		            exit 1
		            ;;
		    esac
		done
		check_user && clean_tmp && set_geometry && start_server
	EOF
	chmod 700 "$VNC_LAUNCHER"
}

# Prompts whether to delete downloaded files
function _CLEANUP_DOWNLOADS() {
	if [ -z "${KEEP_ROOTFS_DIR}" ] && [ -z "${KEEP_IMAGE}" ] && [ -f "${IMAGE_NAME}" ] && _ASK "Delete downloaded files to save space." "N"; then
		rm -f "${IMAGE_NAME}" "${SHA_NAME}"
	fi
}

# Prints usage instructions
function _PRINT_COMPLETE_MSG() {
	printf "\n\n"
	printf "${G}[${Y}=${G}] Kali NetHunter installed successfully${N}\n\n"
	printf "${G}[${Y}*${G}] Usage:${N}\n"
	printf "${G}[${Y}+${G}] ${Y}nh${G} | ${Y}nethunter${N}\n"
	printf "${G}[${Y}+${G}]         Start NetHunter CLI.${N}\n\n"
	printf "${G}[${Y}+${G}] Use '${Y}vnc${G}' in NetHunter to launch VNC Server${N}\n\n"
	printf "${G}[${Y}*${G}] Login Information:${N}\n"
	printf "${G}[${Y}*${G}] User: ${Y}kali${N}\n"
	printf "${G}[${Y}*${G}] Password: ${Y}kali${N}\n"
	printf "${G}[${Y}*${G}] Visit <${C}https://github.com/jorexdeveloper/Install-NetHunter-Termux${G}> for documentation.${N}\n"
	# Message prompt for minimal and nano installations
	if [ "${SELECTED_IMAGE}" != "full" ]; then
		printf "\n${R}[${Y}*${R}] You have a ${Y}${SELECTED_IMAGE} installation${R} which may not have a ${Y}VNC Server${R} and ${Y}Desktop Environment${R} pre-installed${R}. ${C}Please read the documentation on how to install them.${N}\n"
	fi
}

# Prompts parsed message and returns response as 0/1
function _ASK() {
	# Set prompt depending on default value
	if [ "${2:-}" = "Y" ]; then
		local prompt="${Y}Y${C}/${Y}n${C}"
		local default="Y"
	elif [ "${2:-}" = "N" ]; then
		local prompt="${Y}y${C}/${Y}N${C}"
		local default="N"
	else
		local prompt="${Y}y${C}/${Y}n${C}"
		local default=""
	fi
	printf "\n"
	local retries=3
	while true; do
		if [ ${retries} -eq 3 ]; then
			printf "\r${C}[${Y}?${C}] ${1} ${prompt}: ${N}"
		else
			printf "\r${R}[${Y}${retries}${R}] ${1} ${prompt}: ${N}"
		fi
		read -rn 1 reply
		# Set default value?
		if [ -z "${reply}" ]; then
			reply=${default}
		fi
		case "${reply}" in
			Y | y) unset reply && printf "\n" && return 0 ;;
			N | n) unset reply && printf "\n" && return 1 ;;
		esac
		# Ask return 3rd time if default value is set
		((retries--))
		if [ -n "${default}" ] && [ ${retries} -eq 0 ]; then # && [[ ${default} =~ ^(Y|N|y|n)$ ]]; then
			case "${default}" in
				Y | y) unset reply && printf "\n" && return 0 ;;
				N | n) unset reply && printf "\n" && return 1 ;;
			esac
		fi
	done
}

# General function for fixing all issues
function _FIX_ISSUES() {
	printf "\n${C}[${Y}*${C}] Making some tweaks.${N}\n"
	# These descriptions must be in order of the args supplied in the loop
	local bug_descriptions=(
		"Granting root permissions to user kali."
		"Preventing creation of links in read only file system."
		"Setting static display for the system."
		"Settting pulse audio server."
		"Setting DNS settings."
		"Setting JDK variabless."
		"Fixing zshrc."
	)
	local descrnum=0
	for i in _FIX_SUDO _FIX_PROFILE_BASH _FIX_DISPLAY _FIX_AUDIO _FIX_DNS _FIX_JDK _FIX_ZSHRC; do
		printf "\n${C}[${Y}*${C}] ${bug_descriptions[${descrnum}]}${N}"
		if ${i} &>/dev/null; then
			printf "\n${G}[${Y}=${G}] Done.${N}\n"
		else
			printf "\n${R}[${Y}!${R}] Failed.${N}\n"
		fi
		((descrnum++))
	done
	unset LD_PRELOAD && TMP_LOGIN_COMMAND="proot --link2symlink --root-id --rootfs=${ROOTFS_DIR} --bind=${ROOTFS_DIR}/root:/dev/shm --cwd=/"
	if _ASK "Set UID and GID for user kali to match that of Termux." "N"; then
		if _FIX_UID &>/dev/null; then
			printf "${G}[${Y}=${G}] Done.${N}\n"
		else
			printf "${R}[${Y}!${R}] Failed.${N}\n"
		fi
	fi
	if _ASK "Set default shell for user kali." "N"; then
		_SET_DEFAULT_SHELL && printf "${G}[${Y}=${G}] Done.${N}\n" || printf "${R}[${Y}!${R}] Failed.${N}\n"
	fi
	if _ASK "Set Time Zone and Local Time." "N"; then
		_SET_ZONE_INFO && printf "${G}[${Y}=${G}] Done.${N}\n" || printf "${R}[${Y}!${R}] Failed.${N}\n"
	fi
}

# Fix: Fixes sudo and adds user 'kali' to sudoers list
function _FIX_SUDO() {
	## fix sudo & su on start
	chmod +s "${ROOTFS_DIR}/usr/bin/sudo"
	chmod +s "${ROOTFS_DIR}/usr/bin/su"
	echo "kali   ALL=(ALL:ALL) NOPASSWD: ALL" >"${ROOTFS_DIR}/etc/sudoers.d/kali"
	# https://bugzilla.redhat.com/show_bug.cgi?id=1773148
	echo "Set disable_coredump false" >"${ROOTFS_DIR}/etc/sudo.conf"
}

# Fix: Prevents creation of links in read only file system
function _FIX_PROFILE_BASH() {
	if [ -f "${ROOTFS_DIR}/root/.bash_profile" ]; then
		sed -i '/if/,/fi/d' "${ROOTFS_DIR}/root/.bash_profile"
	fi
}

# Fix: Sets a static display across the system
function _FIX_DISPLAY() {
	cat >"${ROOTFS_DIR}/etc/profile.d/display.sh" <<-EOF
		if [ "\${USER}" = "root" ] || [ "\$EUID" -eq 0 ] || [ "\$(whoami)" = "root" ]; then
		    export DISPLAY=:0
		else
		    export DISPLAY=:1
		fi
	EOF
}

# Fix: Sets the pulse audio server to enable audio output
function _FIX_AUDIO() {
	echo "export PULSE_SERVER=127.0.0.1" >"${ROOTFS_DIR}/etc/profile.d/pulseserver.sh"
}

# Fix: Sets variables required by jdk
function _FIX_JDK() {
	if [[ "${SYS_ARCH}" == "armhf" ]]; then
		cat >"${ROOTFS_DIR}/etc/profile.d/java.sh" <<-EOF
			export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-armhf/
			export PATH=\$JAVA_HOME/bin:\$PATH
		EOF
	elif [[ "${SYS_ARCH}" == "arm64" ]]; then
		cat >"${ROOTFS_DIR}/etc/profile.d/java.sh" <<-EOF
			export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-aarch64/
			export PATH=\$JAVA_HOME/bin:\$PATH
		EOF
	else
		printf "${R}[${Y}!${R}] Unknown architecture.${N}\n"
		return 1
	fi
}

# Fix: Fixes zshrc issue
function _FIX_ZSHRC() {
	if [ -f "${ROOTFS_DIR}/etc/skel/.zshrc" ]; then
		rm -rf "${ROOTFS_DIR}/home/kali/.zshrc" "${ROOTFS_DIR}/root/.zshrc" && cp "${ROOTFS_DIR}/etc/skel/.zshrc" "${ROOTFS_DIR}/home/kali/" && cp "${ROOTFS_DIR}/etc/skel/.zshrc" "${ROOTFS_DIR}/root"
	fi
}

# Fix: Sets dns settings
function _FIX_DNS() {
	cat >"${ROOTFS_DIR}/etc/resolv.conf" <<-EOF
		nameserver 8.8.8.8
		nameserver 8.8.4.4
	EOF
}

# Fix: Changes uid and gid of user 'kali' to that of Termux
function _FIX_UID() {
	local USRID="$(id -u)"
	local GRPID="$(id -g)"
	${TMP_LOGIN_COMMAND} /usr/sbin/usermod -u "${USRID}" kali
	${TMP_LOGIN_COMMAND} /usr/sbin/groupmod -g "${GRPID}" kali
}

# Sets the default shell for user 'kali'
function _SET_DEFAULT_SHELL() {
	local shells=("bash" "zsh" "fish" "dash" "tcsh" "csh" "ksh")
	printf "\n${C}[${Y}*${C}] Enter default shell for user ${Y}kali${C}. i.e bash${N}\n"
	printf "\n${C}[${Y}?${C}] Shell: ${N}" && read -r shell
	if [[ "${shells[*]}" == *"${shell}"* ]] && [ -f "${ROOTFS_DIR}/usr/bin/${shell}" ]; then
		${TMP_LOGIN_COMMAND} /usr/bin/chsh -s "/usr/bin/${shell}" kali
	else
		printf "\n${R}[${Y}!${R}] '${shell}' not found.${N}" && _ASK "Try again." "N" && _SET_DEFAULT_SHELL
	fi
}

# Sets Time Zone and Local Time
function _SET_ZONE_INFO() {
	printf "\n${C}[${Y}*${C}] Enter time zone i.e ${Y}America/New_York${C}.${N}\n"
	printf "\n${C}[${Y}?${C}] Zone: ${N}" && read -r zone
	if [ -f "${ROOTFS_DIR}/usr/share/zoneinfo/${zone}" ]; then
		echo "${zone}" >"${ROOTFS_DIR}/etc/timezone" && ${TMP_LOGIN_COMMAND} /usr/bin/ln -fs -T "/usr/share/zoneinfo/${zone}" /etc/localtime
	else
		printf "\n${R}[${Y}!${R}] '${zone}' not found.${N}" && _ASK "Try again." "N" && _SET_ZONE_INFO
	fi
}

################################################################################
#                                ENTRY POINT                                   #
################################################################################

BASE_URL="https://kali.download/nethunter-images/current/rootfs"
LIB_GCC_PATH="/usr/lib/arm-linux-gnueabihf/libgcc_s.so.1"
TERMUX_FILES_DIR="/data/data/com.termux/files/"
VERSION="1.1"

case "${TERM}" in
	xterm-color | *-256color)
		R="\e[1;31m"
		G="\e[1;32m"
		Y="\e[1;33m"
		C="\e[1;36m"
		N="\e[0m"
		;;
esac

# Proces command line args
for option in "$@"; do
	case "${option}" in
		"-v" | "--version")
			_PRINT_VERSION
			exit
			;;
		"--no-check-certificate")
			# Extra arguments are parsed to 'wget' when downloading files
			EXTRA_ARGS=${option}
			shift
			;;
		"-h" | "--help")
			_PRINT_USAGE
			exit
			;;
	esac
done

# Check for system support
_BANNER
_CHECK_ARCH
_CHECK_DEPENDENCIES

# Set installation directory, but it must be within Termux to prevent file issues
if [ -n "$1" ] && ROOTFS_DIR="$(realpath "$1")" && [[ "${ROOTFS_DIR}" == "${TERMUX_FILES_DIR}"* ]]; then
	printf ""
else
	# Set the directory explicitly in case user's home directory is modified
	ROOTFS_DIR="$(realpath "${TERMUX_FILES_DIR}/home/kali-${SYS_ARCH}")"
fi

printf "\n${C}[${Y}*${C}] Installing Kali NetHunter in ${Y}${ROOTFS_DIR}${C}.${N}\n"
_SELECT_IMAGE
_CHECK_ROOTFS_DIR
_GET_ROOTFS
_VERIFY_SHA
_EXTRACT_ROOTFS
_CREATE_LAUNCHER
_CREATE_VNC_LAUNCHER
_CLEANUP_DOWNLOADS

# Fix some issues
_FIX_ISSUES
printf "\n${G}[${Y}*${G}] Installation process complete.${N}\n"

# Print help information
_PRINT_COMPLETE_MSG
