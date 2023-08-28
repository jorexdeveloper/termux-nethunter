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
	printf "${YELLOW}Kali NetHunter Installer${CYAN}, version ${VERSION}${RESET}\n"
	printf "${CYAN}Copyright (C) 2023 Jore.${RESET}\n"
	printf "${CYAN}License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>${RESET}\n"
	printf "\n"
	printf "${CYAN}This is free software; you are free to change and redistribute it.${RESET}\n"
	printf "${CYAN}There is NO WARRANTY, to the extent permitted by law.${RESET}\n"
}

# Prints usage of program
function print_usage() {
	printf "${CYAN}Usage: ${YELLOW}$(basename $0) [--no-check-certificate] [-h,--help] [-v,--version]${RESET}\n"
	printf "${CYAN}Options:${RESET}\n"
	printf "${CYAN}  --no-check-certificate${RESET}\n"
	printf "${CYAN}          This option is passed to 'wget' while downloading files.${RESET}\n"
	printf "${CYAN}  -h, --help${RESET}\n"
	printf "${CYAN}          Print this message and exit.${RESET}\n"
	printf "${CYAN}  -v. --version${RESET}\n"
	printf "${CYAN}          Print version and exit.${RESET}\n"
}

# Prints Kali banner
function print_banner() {
	clear
	printf "${GREEN}\t╻┏ ┏━┓╻  ╻   ┏┓╻┏━╸╺┳╸╻ ╻╻ ╻┏┓╻╺┳╸┏━╸┏━┓${RESET}\n"
	printf "${GREEN}\t┣┻┓┣━┫┃  ┃╺━╸┃┗┫┣╸  ┃ ┣━┫┃ ┃┃┗┫ ┃ ┣╸ ┣┳┛${RESET}\n"
	printf "${GREEN}\t╹ ╹╹ ╹┗━╸╹   ╹ ╹┗━╸ ╹ ╹ ╹┗━┛╹ ╹ ╹ ┗━╸╹┗╸${RESET}\n"
	printf "${YELLOW}\t\t\tby Jore${RESET}\n\n"
}

# Gets system architecture or exits script if unsupported
# Sets SYS_ARCH LIB_GCC_PATH
function check_arch() {
	printf "${CYAN}\n[${YELLOW}*${CYAN}] Checking device architecture...${RESET}\n"
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
			printf "${RED}[${YELLOW}!${RED}] Unsupported architecture\n\n${RESET}\n"
			exit 1
			;;
	esac
}

# Installs required dependencies
function check_dependencies() {
	printf "${CYAN}\n[${YELLOW}*${CYAN}] Checking package dependencies...${RESET}\n"
	## Workaround for termux-app issue #1283 (https://github.com/termux/termux-app/issues/1283)
	## apt update -y &> /dev/null
	apt-get update -y &> /dev/null || apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" dist-upgrade -y &> /dev/null
	for i in wget proot tar pulseaudio; do
		if [ -e $PREFIX/bin/$i ]; then
			printf "${GREEN}[${YELLOW}=${GREEN}] $i is OK${RESET}\n"
		else
			printf "${CYAN}[${YELLOW}*${CYAN}] Installing ${i}...${RESET}\n"
			apt install -y $i &> /dev/null || {
				printf "${RED}[${YELLOW}!${RED}] Failed to install ${i}.\n Exiting.\n${RESET}"
				exit 1
			}
		fi
	done
}

# Prompts for the required image installation
# Sets CHROOT IMAGE_NAME SHA_NAME
function select_image() {
	if [[ ${SYS_ARCH} == "arm64" ]]; then
		printf "\n${GREEN}  [${YELLOW}1${GREEN}] ${CYAN}NetHunter ARM64 (full)${RESET}\n"
		printf "\n${GREEN}  [${YELLOW}2${GREEN}] ${CYAN}NetHunter ARM64 (mini)${RESET}\n"
		printf "\n${GREEN}  [${YELLOW}3${GREEN}] ${CYAN}NetHunter ARM64 (nano)${RESET}\n"
	elif [[ ${SYS_ARCH} == "armhf" ]]; then
		printf "\n${GREEN}  [${YELLOW}1${GREEN}] ${CYAN}NetHunter ARMhf (full)${RESET}\n"
		printf "\n${GREEN}  [${YELLOW}2${GREEN}] ${CYAN}NetHunter ARMhf (mini)${RESET}\n"
		printf "\n${GREEN}  [${YELLOW}3${GREEN}] ${CYAN}NetHunter ARMhf (nano)${RESET}\n"
	fi
	printf "${CYAN}\n[${YELLOW}*${CYAN}] Enter the image you want to install: ${RESET}"
	read -n 1 CHOICE 2> /dev/null
	case $CHOICE in
		1) printf "\n${GREEN}[${YELLOW}=${GREEN}] Full selected${RESET}\n" && CHOICE="full" ;;
		2) printf "\n${GREEN}[${YELLOW}=${GREEN}] Mini selected${RESET}\n" && CHOICE="minimal" ;;
		3) printf "\n${GREEN}[${YELLOW}=${GREEN}] Nano selected${RESET}\n" && CHOICE="nano" ;;
		*) printf "\n${GREEN}[${YELLOW}=${GREEN}] Mini selected${RESET}\n" && CHOICE="minimal" ;;
	esac
	CHROOT="kali-${SYS_ARCH}"
	IMAGE_NAME="kalifs-${SYS_ARCH}-${CHOICE}.tar.xz"
	SHA_NAME="kalifs-${SYS_ARCH}-${CHOICE}.sha512sum"
}

# Prompts whether to delete existing rootfs folder if any
# Sets KEEP_CHROOT
function check_fs() {
	unset KEEP_CHROOT
	if [ -d ${CHROOT} ]; then
		if ask "Existing rootfs directory found. Delete and create a new one?" "N"; then
			printf "${RED}[${YELLOW}!${RED}] Deleting rootfs directory...${RESET}\n"
			rm -rf ${CHROOT}
		else
			printf "${YELLOW}[${RED}!${YELLOW}] Using existing rootfs directory.${RESET}\n"
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
				printf "${RED}[${YELLOW}!${RED}] Deleting image file...${RESET}\n"
				rm -f ${IMAGE_NAME}
			else
				printf "${YELLOW}[${RED}!${YELLOW}] Using existing rootfs archive${RESET}\n"
				KEEP_IMAGE=1
				return
			fi
		fi
		# Download rootfs
		printf "${CYAN}[${YELLOW}*${CYAN}] Downloading rootfs...${RESET}\n"
		wget ${EXTRA_ARGS} --continue "${BASE_URL}/${IMAGE_NAME}"
		# Download SHA
		printf "${CYAN}[${YELLOW}*${CYAN}] Downloading SHA... ${RESET}\n"
		[ -f ${SHA_NAME} ] && rm -f ${SHA_NAME}
		wget ${EXTRA_ARGS} --continue "${BASE_URL}/${SHA_NAME}"
	fi
}

# Verifies SHA
function verify_sha() {
	if [ -z $KEEP_CHROOT ]; then
		printf "\n${CYAN}[${YELLOW}*${CYAN}] Verifying integrity of rootfs archive...${RESET}\n"
		sha512sum -c $SHA_NAME &> /dev/null || {
			printf "${RED}[${YELLOW}!${RED}] Rootfs corrupted. Please run this installer again or download the file manually.${RESET}\n"
			exit 1
		}
	fi
}

# Extracts rootfs if it was downloaded
function extract_rootfs() {
	if [ -z $KEEP_CHROOT ]; then
		printf "\n${CYAN}[${YELLOW}*${CYAN}] Extracting rootfs...${RESET}\n"
		proot --link2symlink tar -xf $IMAGE_NAME 2> /dev/null
	fi
}

# Creates a script to launch NetHunter
function create_launcher() {
	NH_LAUNCHER=${HOME}/bin/nethunter
	NH_SHORTCUT=${HOME}/bin/nh
	cat > $NH_LAUNCHER <<- EOF
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
	mkdir -p $CHROOT/usr/local/bin && VNC_LAUNCHER=${CHROOT}/usr/local/bin/vnc && cat > $VNC_LAUNCHER <<- EOF
		#!/bin/bash -e

		depth=24
		display=1
		width=720
		height=1600
		orientation=landscape

		function check_user() {
		    if [ "\${USER}" = "root" ] || [ "\$EUID" -eq 0 ] || [ "\$(whoami)" = "root" ]; then
		        display=0 && export DISPLAY=\${display}
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
		        # You can start with nohup
		        vncserver :\$display -geometry \$geometry -depth \$depth -name remote-desktop && echo -e "\n[*] VNC Server started successfully."
		    else
		        set_passwd && start_server
		    fi
		}

		function kill_server() {
		    [ -f "/bin/pulseaudio" ] && pulseaudio --kill || pkill pulseaudio
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

		[[ "\$@" == "" ]] && args="--start" || args="\$@"
		for option in \$args; do
		    case \$option in
		        "--potrait")
		            orientation=potrait
		            ;;
		        "--landscape")
		            orientation=landscape
		            ;;
		        "-p"|"--password")
		            set_passwd
		            ;;
		        "-s"|"--start")
		            check_user && clean_tmp && set_geometry && start_server
		            ;;
		        "-k"|"--kill")
		            kill_server
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
	printf "${GREEN}[${YELLOW}=${GREEN}] Kali NetHunter installed successfully${RESET}\n\n"
	printf "${GREEN}[${YELLOW}*${GREEN}] Usage:${RESET}\n"
	printf "${GREEN}[${YELLOW}+${GREEN}] ${YELLOW}nh${GREEN} | ${YELLOW}nethunter${RESET}\n"
	printf "${GREEN}[${YELLOW}+${GREEN}]         Start NetHunter CLI.${RESET}\n\n"
	printf "${GREEN}[${YELLOW}+${GREEN}] Use '${YELLOW}vnc${GREEN}' in NetHunter to launch VNC Server${RESET}\n\n"
	printf "${GREEN}[${YELLOW}*${GREEN}] Login Information:${RESET}\n"
	printf "${GREEN}[${YELLOW}*${GREEN}] User: ${YELLOW}kali${RESET}\n"
	printf "${GREEN}[${YELLOW}*${GREEN}] Password: ${YELLOW}kali${RESET}\n"
	printf "${GREEN}[${YELLOW}*${GREEN}] Visit https://github.com/jorexdeveloper/Install-NetHunter-Termux for documentation.${RESET}\n"
}

# Prompts parsed message and returns response as 0/1
function ask() {
	# http://djm.me/ask
	while true; do
		if [ "${2:-}" = "Y" ]; then
			prompt="Y/n"
			default=Y
		elif [ "${2:-}" = "N" ]; then
			prompt="y/N"
			default=N
		else
			prompt="y/n"
			default=
		fi
		# Ask the question
		printf "\n${CYAN}[${YELLOW}?${CYAN}] ${1} [${prompt}] ${RESET}"
		read -n 1 REPLY
		# Default?
		if [ -z "$REPLY" ]; then
			REPLY=${default}
		fi
		printf "\n${RESET}"
		# Check if the reply is valid
		case "$REPLY" in
			Y* | y*) return 0 ;;
			N* | n*) return 1 ;;
		esac
	done
}

# General prompt for all tweaks
function tweaks() {
	printf "\n${CYAN}[${YELLOW}*${CYAN}] Making some tweaks.${RESET}\n"
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
		printf "\n${CYAN}[${YELLOW}*${CYAN}] ${bug_descriptions[${descrnum}]}${RESET}"
		if ${i} &> /dev/null; then
			printf "\n${GREEN}[${YELLOW}=${GREEN}] Done.${RESET}\n"
		else
			printf "${RED}[${YELLOW}!${RED}] Failed.${RESET}\n"
		fi
		((descrnum++))
	done
	local descrnum=0
	if ask "Set UID and GID for user kali to match that of Termux." "N"; then
		if tweak_uid &> /dev/null; then
			printf "${GREEN}[${YELLOW}=${GREEN}] Done.${RESET}\n"
		else
			printf "${RED}[${YELLOW}!${RED}] Failed.${RESET}\n"
		fi
	fi
	if ask "Set Time Zone and Local Time." "N"; then
		tweak_zoneinfo
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
	echo -e "export DISPLAY=:1" > $CHROOT/etc/profile.d/display.sh
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
		printf "${RED}[${YELLOW}!${RED}] Unknown architecture.${RESET}\n"
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

# Tweak: Sets Time Zone and Local Time
function tweak_zoneinfo() {
	printf "\n${CYAN}[${YELLOW}*${CYAN}] Input time zone i.e America/New_York.${RESET}\n"
	printf "\n${CYAN}[${YELLOW}?${CYAN}] Zone: ${RESET}" && read zone
	if [ -f "$CHROOT/usr/share/zoneinfo/${zone}" ]; then
		echo "${zone}" > ${CHROOT}/etc/timezone && nethunter -r ln -fs -T /usr/share/zoneinfo/${zone} /etc/localtime
	else
		printf "\n${RED}[${YELLOW}!${RED}] '${zone}' not found.${RESET}" && ask "Try again." "N" && tweak_zoneinfo
	fi
}

# Tweak: Changes uid and gid of user 'kali' to that of Termux
function tweak_uid() {
	local USRID=$(id -u)
	local GRPID=$(id -g)
	nethunter -p kali kali usermod -u $USRID kali &> /dev/null
	nethunter -p kali kali groupmod -g $GRPID kali &> /dev/null
}

################################################################################
#                                ENTRY POINT                                   #
################################################################################

BASE_URL="https://kali.download/nethunter-images/current/rootfs"
LIB_GCC_PATH="/usr/lib/arm-linux-gnueabihf/libgcc_s.so.1"
VERSION="1.0"
USERNAME="kali"
RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
CYAN="\e[1;36m"
RESET="\e[0m"

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
			printf "${RED}[${YELLOW}!${RED}]Unknown option '${option}'.${RESET}\n"
			print_usage
			exit
			;;
	esac
done

# Begin Installation
cd $HOME
print_banner

printf "\n${CYAN}[${YELLOW}*${CYAN}] Beginning installation process.${RESET}\n"
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
printf "\n${GREEN}[${YELLOW}*${GREEN}] Installation process complete.${RESET}\n"

# Print a help message
print_help
