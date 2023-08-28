#!/data/data/com.termux/files/usr/bin/bash -e

################################################################################
#                                                                              #
#     Kali NetHunter Installer. version 1.0                                    #
#                                                                              #
#     Install Kali NetHunter in Termux.                                        #
#                                                                              #
#     Copyright (C) 2023  Jore                                                 #
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

# Prints version and exits
function print_version() {
	printf "${Y}Kali NetHunter Installer${C}, version ${VERSION}${N}\n"
	printf "${C}Copyright (C) 2023 Jore.${N}\n"
	printf "${C}License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>${N}\n"
	printf "\n"
	printf "${C}This is free software; you are free to change and redistribute it.${N}\n"
	printf "${C}There is NO WARRANTY, to the extent permitted by law.${N}\n"
}

# Prints usage of program
function print_usage() {
	printf "${C}Usage: ${Y}$(basename $0) [--no-check-certificate] [-h,--help] [-v,--version]${N}\n"
	printf "${C}Options:${N}\n"
	printf "${C}  --no-check-certificate${N}\n"
	printf "${C}          This option is passed to 'wget' while downloading files.${N}\n"
	printf "${C}  -h, --help${N}\n"
	printf "${C}          Print this message and exit.${N}\n"
	printf "${C}  -v. --version${N}\n"
	printf "${C}          Print version and exit.${N}\n"
}

# Prints Kali banner
function print_banner() {
	clear
	printf "${G}\t╻┏ ┏━┓╻  ╻   ┏┓╻┏━╸╺┳╸╻ ╻╻ ╻┏┓╻╺┳╸┏━╸┏━┓${N}\n"
	printf "${G}\t┣┻┓┣━┫┃  ┃╺━╸┃┗┫┣╸  ┃ ┣━┫┃ ┃┃┗┫ ┃ ┣╸ ┣┳┛${N}\n"
	printf "${G}\t╹ ╹╹ ╹┗━╸╹   ╹ ╹┗━╸ ╹ ╹ ╹┗━┛╹ ╹ ╹ ┗━╸╹┗╸${N}\n"
	printf "${Y}\t\t\tby Jore${N}\n\n"
}

# Gets system architecture or exits script if unsupported
# Sets SYS_ARCH LIB_GCC_PATH
function check_arch() {
	printf "${C}\n[${Y}*${C}] Checking device architecture...${N}\n"
	case $(getprop ro.product.cpu.abi) in
		arm64-v8a)
			SYS_ARCH=arm64
			LIB_GCC_PATH=/usr/lib/aarch64-linux-gnu/libgcc_s.so.1
			;;
		armeabi | armeabi-v7a)
			SYS_ARCH=armhf
			LIB_GCC_PATH=/usr/lib/arm-linux-gnueabihf/libgcc_s.so.1
			;;
		*)
			printf "${R}[${Y}!${R}] Unsupported architecture\n\n${N}\n"
			exit 1
			;;
	esac
}

# Installs required dependencies
function check_dependencies() {
	printf "${C}\n[${Y}*${C}] Checking package dependencies...${N}\n"
	## Workaround for termux-app issue #1283 (https://github.com/termux/termux-app/issues/1283)
	## apt update -y &> /dev/null
	apt-get update -y &> /dev/null || apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" dist-upgrade -y &> /dev/null
	for i in wget proot tar pulseaudio; do
		if [ -e $PREFIX/bin/$i ]; then
			printf "${G}[${Y}=${G}] $i is OK${N}\n"
		else
			printf "${C}[${Y}*${C}] Installing ${i}...${N}\n"
			apt install -y $i &> /dev/null || {
				printf "${R}[${Y}!${R}] Failed to install ${i}.\n Exiting.\n${N}"
				exit 1
			}
		fi
	done
}

# Prompts for the required image installation
# Sets CHROOT IMAGE_NAME SHA_NAME SELECTED_FS
function select_image() {
	if [[ ${SYS_ARCH} == "arm64" ]]; then
		printf "\n${G}  [${Y}1${G}] ${C}NetHunter ARM64 (full)${N}\n"
		printf "\n${G}  [${Y}2${G}] ${C}NetHunter ARM64 (mini)${N}\n"
		printf "\n${G}  [${Y}3${G}] ${C}NetHunter ARM64 (nano)${N}\n"
	elif [[ ${SYS_ARCH} == "armhf" ]]; then
		printf "\n${G}  [${Y}1${G}] ${C}NetHunter ARMhf (full)${N}\n"
		printf "\n${G}  [${Y}2${G}] ${C}NetHunter ARMhf (mini)${N}\n"
		printf "\n${G}  [${Y}3${G}] ${C}NetHunter ARMhf (nano)${N}\n"
	fi
	printf "${C}\n[${Y}*${C}] Enter the image you want to install: ${N}"
	read -n 1 SELECTED_FS 2> /dev/null
	case $SELECTED_FS in
		1) printf "\n${G}[${Y}=${G}] Full selected${N}\n" && SELECTED_FS="full" ;;
		2) printf "\n${G}[${Y}=${G}] Mini selected${N}\n" && SELECTED_FS="minimal" ;;
		3) printf "\n${G}[${Y}=${G}] Nano selected${N}\n" && SELECTED_FS="nano" ;;
		*) printf "\n${G}[${Y}=${G}] Mini selected${N}\n" && SELECTED_FS="minimal" ;;
	esac
	CHROOT="kali-${SYS_ARCH}"
	IMAGE_NAME="kalifs-${SYS_ARCH}-${SELECTED_FS}.tar.xz"
	SHA_NAME="kalifs-${SYS_ARCH}-${SELECTED_FS}.sha512sum"
}

# Prompts whether to delete existing rootfs folder if any
# Sets KEEP_CHROOT
function check_fs() {
	unset KEEP_CHROOT
	if [ -d ${CHROOT} ]; then
		if ask "Existing rootfs directory found. Delete and create a new one?" "N"; then
			printf "${R}[${Y}!${R}] Deleting rootfs directory...${N}\n"
			rm -rf ${CHROOT}
		else
			printf "${Y}[${R}!${Y}] Using existing rootfs directory.${N}\n"
			KEEP_CHROOT=1
		fi
	fi
}

# Downloads roots file and SHA or prompts if it exists
# Sets KEEP_IMAGE
function get_rootfs() {
	unset KEEP_IMAGE
	if [ -z ${KEEP_CHROOT} ]; then
		if [ -f ${IMAGE_NAME} ]; then
			if ask "Existing image file found. Delete and download a new one." "N"; then
				printf "${R}[${Y}!${R}] Deleting image file...${N}\n"
				rm -f ${IMAGE_NAME}
			else
				printf "${Y}[${R}!${Y}] Using existing rootfs archive${N}\n"
				KEEP_IMAGE=1
				return
			fi
		fi
		# Download rootfs
		printf "${C}[${Y}*${C}] Downloading rootfs...${N}\n"
		wget ${EXTRA_ARGS} --continue "${BASE_URL}/${IMAGE_NAME}"
		# Download SHA
		printf "${C}[${Y}*${C}] Downloading SHA... ${N}\n"
		[ -f ${SHA_NAME} ] && rm -f ${SHA_NAME}
		wget ${EXTRA_ARGS} --continue "${BASE_URL}/${SHA_NAME}"
	fi
}

# Verifies SHA
function verify_sha() {
	if [ -z $KEEP_CHROOT ]; then
		printf "\n${C}[${Y}*${C}] Verifying integrity of rootfs archive...${N}\n"
		sha512sum -c $SHA_NAME &> /dev/null || {
			printf "${R}[${Y}!${R}] Rootfs corrupted. Please run this installer again or download the file manually.${N}\n"
			exit 1
		}
	fi
}

# Extracts rootfs if it was downloaded
function extract_rootfs() {
	if [ -z $KEEP_CHROOT ]; then
		printf "\n${C}[${Y}*${C}] Extracting rootfs...${N}\n"
		proot --link2symlink tar -xf $IMAGE_NAME 2> /dev/null
	fi
}

# Creates a script to launch NetHunter
function create_launcher() {
	printf "\n${C}[${Y}*${C}] Creating NetHunter launcher...${N}\n"
	NH_LAUNCHER=${PREFIX}/bin/nethunter
	NH_SHORTCUT=${PREFIX}/bin/nh
	mkdir -p $(dirname ${NH_LAUNCHER}) && cat > $NH_LAUNCHER <<- EOF
		#!/data/data/com.termux/files/usr/bin/bash -e

		# For enabling audio playing in distro, for rooted user: pulseaudio --start --system
		pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1

		# unset LD_PRELOAD in case termux-exec is installed
		unset LD_PRELOAD

		# Workaround for Libreoffice, also needs to bind a fake /proc/version
		[ ! -f kali-armhf/root/.version ] && touch kali-armhf/root/.version

		# Command to start distro
		command="proot \
		         --link2symlink \
		         --kill-on-exit \
		         --root-id \
		         --rootfs=\${HOME}/kali-armhf \
		         --bind=/dev \
		         --bind=/proc \
		         --bind=kali-armhf/root:/dev/shm \
		         --bind=\$([ ! -z "\${INTERNAL_STORAGE}" ] && echo "\${INTERNAL_STORAGE}" || echo "/sdcard"):/mnt/sd0 \
		         --bind=\$([ ! -z "\${EXTERNAL_STORAGE}" ] && echo "\${EXTERNAL_STORAGE}" || echo "/sdcard"):/mnt/sd1 \
		         --cwd=/ \
		            /usr/bin/env -i \
		            TERM=\${TERM} \
		            LANG=C.UTF-8 \
		            /usr/bin/login \
		        "
		exec \${command}
	EOF
	chmod 700 $NH_LAUNCHER
	if [ -L ${NH_SHORTCUT} ]; then
		rm -f ${NH_SHORTCUT}
	fi
	if [ ! -f ${NH_SHORTCUT} ]; then
		ln -s ${NH_LAUNCHER} ${NH_SHORTCUT} > /dev/null
	fi
}

# Creates a script to start vnc for NetHunter
function create_vnc_launcher() {
	printf "\n${C}[${Y}*${C}] Creating VNC launcher...${N}\n"
	mkdir -p $CHROOT/usr/local/bin && VNC_LAUNCHER=${CHROOT}/usr/local/bin/vnc && cat > $VNC_LAUNCHER <<- EOF
		#!/bin/bash -e

		depth=24
		width=720
		height=1600
		orientation=landscape
		display=\$(echo \${DISPLAY} | cut -d : -f 2)

		function check_user() {
		    if [ "\${USER}" = "root" ] || [ "\$EUID" -eq 0 ] || [ "\$(whoami)" = "root" ]; then
		        read -p "[!] Warning: You are starting VNC as root user, some applications are not meant to be run as root and may not work properly. Do you want to continue? y/N" -n 1 REPLY && echo && case \${REPLY} in y|Y) ;; *) exit 1 ;; esac
		    fi
		}

		function clean_tmp() {
		    rm -rf /tmp/.X\${display}-lock
		    rm -rf /tmp/.X11-unix/X\${display}
		}

		function set_geometry() {
		    case \$orientation in
		        "potrait")
		            geometry="\${width}x\${height}"
		            ;;
		        *)
		            geometry="\${height}x\${width}"
		            ;;
		    esac
		}

		function start_pulseaudio() {
		    if [ -f "/bin/pulseaudio" ] || ! which pulseaudio; then
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
		    if [ -f \${HOME}/.vnc/passwd ]; then
		        export HOME=\${HOME}
		        export USER=\${USER}
		        LD_PRELOAD=${LIB_GCC_PATH}
		        # You can use nohup
		        vncserver :\$display -geometry \$geometry -depth \$depth -name remote-desktop && echo -e "\n[*] VNC Server started successfully."
		    else
		        set_passwd && start_server
		    fi
		}

		function kill_server() {
		    # [ -f "/bin/pulseaudio" ] && pulseaudio --kill || pkill pulseaudio
		    clean_tmp
		    vncserver -clean -kill :\$display
		    return \$?
		}

		function print_usage() {
		    echo "Usage: \$(basename $0) [--potrait] [--landscape] [-p,--password] [-s,--start] [-k,--kill]"
		    echo "Options:"
		    echo "  --potrait"
		    echo "          Use potrait orientation."
		    echo "  --landscape"
		    echo "          Use landscape orientation. (default)"
		    echo "  -p, --password"
		    echo "          Set or change password."
		    echo "  -s, --start"
		    echo "          Start vncserver. (default if no options supplied)"
		    echo "  -k, --kill"
		    echo "          Kill vncserver."
		    echo "  -h, --help"
		    echo "          Print this message and exit."
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
		            print_usage
		            exit
		            ;;
		        *)
		            echo "Unknown option '\$option'."
		            print_usage
		            exit 1
		            ;;
		    esac
		done
		check_user && clean_tmp && set_geometry && start_server
		unset depth display width height name orientation geometry
	EOF
	chmod 700 $VNC_LAUNCHER
}

# Prompts whether to delete downloaded files
function cleanup() {
	if [ -z $KEEP_CHROOT ] && [ -z $KEEP_IMAGE ] && [ -f ${IMAGE_NAME} ] && ask "Delete downloaded rootfs file." "N"; then
		[ -f ${IMAGE_NAME} ] && rm -f ${IMAGE_NAME}
		[ -f ${SHA_NAME} ] && rm -f ${SHA_NAME}
	fi
}

# Prints usage instructions
function print_help() {
	printf "\n\n"
	printf "${G}[${Y}=${G}] Kali NetHunter installed successfully${N}\n\n"
	printf "${G}[${Y}*${G}] Usage:${N}\n"
	printf "${G}[${Y}+${G}] ${Y}nh${G} | ${Y}nethunter${N}\n"
	printf "${G}[${Y}+${G}]         Start NetHunter CLI.${N}\n\n"
	printf "${G}[${Y}+${G}] Use '${Y}vnc${G}' in NetHunter to launch VNC Server${N}\n\n"
	printf "${G}[${Y}*${G}] Login Information:${N}\n"
	printf "${G}[${Y}*${G}] User: ${Y}kali${N}\n"
	printf "${G}[${Y}*${G}] Password: ${Y}kali${N}\n"
	printf "${G}[${Y}*${G}] Visit ${C}https://github.com/jorexdeveloper/Install-NetHunter-Termux${G} for documentation.${N}\n"
	# Message prompt for minimal and nano installations
	if [[ ${SELECTED_FS} != "full" ]]; then
		printf "\n${R}[${Y}*${R}] You have a ${Y}${SELECTED_FS} installation${R} which may not have a ${Y}VNC Server${R} and ${Y}Desktop Environment${R} pre-installed${R}. ${C}Please read the documentation in link above on how to install them.${N}\n"
	fi
}

# Prompts parsed message and returns response as 0/1
function ask() {
	# Set prompt depending on default value
	if [ "${2:-}" = "Y" ]; then
		local prompt="Y/n"
		local default="Y"
	elif [ "${2:-}" = "N" ]; then
		local prompt="y/N"
		local default="N"
	else
		local prompt="y/n"
		local default=""
	fi
	printf "\n"
	# Ask
	local retries=3
	while true; do
		if [ ${retries} -eq 3 ]; then
			printf "\r${C}[${Y}?${C}] ${1} ${prompt}: ${N}"
		else
			printf "\r${R}[${Y}${retries}${R}] ${1} ${prompt}: ${N}"
		fi
		read -n 1 reply
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
		if [ ! -z "${default}" ] && [ ${retries} -eq 0 ]; then # && [[ ${default} =~ ^(Y|N|y|n)$ ]]; then
			case "${default}" in
				Y | y) unset reply && printf "\n" && return 0 ;;
				N | n) unset reply && printf "\n" && return 1 ;;
			esac
		fi
	done
}

# General prompt for all tweaks
function tweaks() {
	printf "\n${C}[${Y}*${C}] Making some tweaks.${N}\n"
	## These descriptions must be in order of the args supplied in the loop
	local bug_descriptions=(
		"Granting root permissions to user kali."
		"Preventing creation of links in read only file system."
		"Setting static display for the system."
		"Settting pulse audio server."
		"Setting DNS settings."
		"Setting up jdk variables."
	)
	local descrnum=0
	for i in tweak_sudo tweak_profile_bash tweak_display tweak_audio tweak_dns tweak_java; do
		printf "\n${C}[${Y}*${C}] ${bug_descriptions[${descrnum}]}${N}"
		if ${i} &> /dev/null; then
			printf "\n${G}[${Y}=${G}] Done.${N}\n"
		else
			printf "\n${R}[${Y}!${R}] Failed.${N}\n"
		fi
		((descrnum++))
	done
	unset LD_PRELOAD && TMP_LOGIN_COMMAND="proot --link2symlink --root-id --rootfs=${CHROOT} --bind=${CHROOT}/root:/dev/shm --cwd=/"
	if ask "Set default shell for user kali." "N"; then
		tweak_default_shell && printf "${G}[${Y}=${G}] Done.${N}\n" || printf "${R}[${Y}!${R}] Failed.${N}\n"
	fi
	if ask "Set UID and GID for user kali to match that of Termux." "N"; then
		if tweak_uid &> /dev/null; then
			printf "${G}[${Y}=${G}] Done.${N}\n"
		else
			printf "${R}[${Y}!${R}] Failed.${N}\n"
		fi
	fi
	if ask "Set Time Zone and Local Time." "N"; then
		tweak_zoneinfo && printf "${G}[${Y}=${G}] Done.${N}\n" || printf "${R}[${Y}!${R}] Failed.${N}\n"
	fi
}

# Tweak: Prevents creation of links in read only file system
function tweak_profile_bash() {
	if [ -f ${CHROOT}/root/.bash_profile ]; then
		sed -i '/if/,/fi/d' "${CHROOT}/root/.bash_profile"
	fi
}

# Tweak: Fixes sudo and adds user 'kali' to sudoers list
function tweak_sudo() {
	## fix sudo & su on start
	chmod +s $CHROOT/usr/bin/sudo
	chmod +s $CHROOT/usr/bin/su
	echo "kali   ALL=(ALL:ALL) NOPASSWD: ALL" > $CHROOT/etc/sudoers.d/kali
	# https://bugzilla.redhat.com/show_bug.cgi?id=1773148
	echo "Set disable_coredump false" > $CHROOT/etc/sudo.conf
}

# Tweak: Sets the pulse audio server to enable audio output
function tweak_audio() {
	echo -e "export PULSE_SERVER=127.0.0.1" > $CHROOT/etc/profile.d/pulseserver.sh
}

# Tweak: Sets a static display across the system
function tweak_display() {
	echo -e ""
	cat > $CHROOT/etc/profile.d/display.sh <<- EOF
		if [ "\${USER}" = "root" ] || [ "\$EUID" -eq 0 ] || [ "\$(whoami)" = "root" ]; then
		    export DISPLAY=:0
		else
		    export DISPLAY=:1
		fi
	EOF
}

# Tweak: Sets variables required by jdk
function tweak_java() {
	if [[ "${SYS_ARCH}" == "armhf" ]]; then
		cat > $CHROOT/etc/profile.d/java.sh <<- EOF
			export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-armhf/
			export PATH=\$JAVA_HOME/bin:\$PATH
		EOF
	elif [[ "${SYS_ARCH}" == "arm64" ]]; then
		cat > $CHROOT/etc/profile.d/java.sh <<- EOF
			export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-aarch64/
			export PATH=\$JAVA_HOME/bin:\$PATH
		EOF
	else
		printf "${R}[${Y}!${R}] Unknown architecture.${N}\n"
		return 1
	fi
}

# Tweak: Sets dns settings
function tweak_dns() {
	cat > $CHROOT/etc/resolv.conf <<- EOF
		nameserver 8.8.8.8
		nameserver 8.8.4.4
	EOF
}

# Tweak: Sets the default shell for user 'kali'
function tweak_default_shell() {
	local shells=("bash" "zsh" "fish" "dash" "tcsh" "csh" "ksh")
	printf "\n${C}[${Y}*${C}] Enter default shell for user ${Y}kali${C}. i.e bash${N}\n"
	printf "\n${C}[${Y}?${C}] Shell: ${N}" && read shell
	if [[ "${shells[*]}" == *"${shell}"* ]] && [ -f "$CHROOT/usr/bin/${shell}" ]; then
		${TMP_LOGIN_COMMAND} /usr/bin/chsh -s /usr/bin/${shell} kali
	else
		printf "\n${R}[${Y}!${R}] '${shell}' not found.${N}" && ask "Try again." "N" && tweak_default_shell
	fi
}

# Tweak: Sets Time Zone and Local Time
function tweak_zoneinfo() {
	printf "\n${C}[${Y}*${C}] Enter time zone i.e ${Y}America/New_York${C}.${N}\n"
	printf "\n${C}[${Y}?${C}] Zone: ${N}" && read zone
	if [ -f "$CHROOT/usr/share/zoneinfo/${zone}" ]; then
		echo "${zone}" > ${CHROOT}/etc/timezone && ${TMP_LOGIN_COMMAND} /usr/bin/ln -fs -T /usr/share/zoneinfo/${zone} /etc/localtime
	else
		printf "\n${R}[${Y}!${R}] '${zone}' not found.${N}" && ask "Try again." "N" && tweak_zoneinfo
	fi
}

# Tweak: Changes uid and gid of user 'kali' to that of Termux
function tweak_uid() {
	local USRID=$(id -u)
	local GRPID=$(id -g)
	${TMP_LOGIN_COMMAND} /usr/sbin/usermod -u ${USRID} kali
	${TMP_LOGIN_COMMAND} /usr/sbin/groupmod -g ${GRPID} kali
}

################################################################################
#                                ENTRY POINT                                   #
################################################################################

BASE_URL="https://kali.download/nethunter-images/current/rootfs"
LIB_GCC_PATH="/usr/lib/arm-linux-gnueabihf/libgcc_s.so.1"
VERSION="1.0"
USERNAME="kali"
R="\e[1;31m"
G="\e[1;32m"
Y="\e[1;33m"
C="\e[1;36m"
N="\e[0m"

# Proces command line args
for option in $@; do
	case ${option} in
		"-v" | "--version")
			print_version
			exit
			;;
		"--no-check-certificate")
			# Extra arguments are parsed to 'wget' when downloading files
			EXTRA_ARGS=${option}
			;;
		"-h" | "--help")
			print_usage
			exit
			;;
		*)
			printf "${R}[${Y}!${R}]Unknown option '${option}'.${N}\n"
			print_usage
			exit
			;;
	esac
done

# Begin Installation
cd $HOME
print_banner

printf "\n${C}[${Y}*${C}] Beginning installation process.${N}\n"
check_arch
check_dependencies
select_image
check_fs
get_rootfs
verify_sha
extract_rootfs
create_launcher
create_vnc_launcher
cleanup
tweaks
printf "\n${G}[${Y}*${G}] Installation process complete.${N}\n"

# Print help information
print_help
