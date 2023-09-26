#!/data/data/com.termux/files/usr/bin/bash

################################################################################
#                                                                              #
#     Kali NetHunter Installer, version 1.0                                    #
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

################################################################################
#                                FUNCTIONS                                     #
################################################################################

#########
### Major
#########

# Prints banner
_PRINT_BANNER() {
	clear
	printf "${C}┌────────────────────────────────────────┐${N}\n"
	printf "${C}│${G}╻┏ ┏━┓╻  ╻   ┏┓╻┏━╸╺┳╸╻ ╻╻ ╻┏┓╻╺┳╸┏━╸┏━┓${C}│${N}\n"
	printf "${C}│${G}┣┻┓┣━┫┃  ┃   ┃┗┫┣╸  ┃ ┣━┫┃ ┃┃┗┫ ┃ ┣╸ ┣┳┛${C}│${N}\n"
	printf "${C}│${G}╹ ╹╹ ╹┗━╸╹   ╹ ╹┗━╸ ╹ ╹ ╹┗━┛╹ ╹ ╹ ┗━╸╹┗╸${C}│${N}\n"
	printf "${C}│${Y}                TERMUX                  ${C}│${N}\n"
	printf "${C}└────────────────────────────────────────┘${N}\n"
	_PRINT_MESSAGE "Version:  ${SCRIPT_VERSION}" N
	_PRINT_MESSAGE "Author:   ${AUTHOR_NAME}" N
	_PRINT_MESSAGE "Github:   ${U}${AUTHOR_GITHUB}${NU}" N
}

# Checks system architecture
# Sets SYS_ARCH LIB_GCC_PATH
_CHECK_ARCHITECTURE() {
	_PRINT_TITLE "Checking device architecture"
	if SYS_ARCH="$(getprop ro.product.cpu.abi 2>/dev/null)" && _PRINT_MESSAGE "${SYS_ARCH} is supported"; then
		case "${SYS_ARCH}" in
			arm64-v8a)
				SYS_ARCH="arm64"
				LIB_GCC_PATH="/usr/lib/aarch64-linux-gnu/libgcc_s.so.1"
				;;
			armeabi | armeabi-v7a)
				SYS_ARCH="armhf"
				LIB_GCC_PATH="/usr/lib/arm-linux-gnueabihf/libgcc_s.so.1"
				;;
			*)
				_PRINT_ERROR_EXIT "Unsupported architecture"
				;;
		esac
	else
		_PRINT_ERROR_EXIT "Failed to get device architecture"
	fi
}

# Che<ks for dependencies
_CHECK_DEPENDENCIES() {
	_PRINT_TITLE "Updating system"
	# Workaround for termux-app issue #1283 (https://github.com/termux/termux-app/issues/1283)
	{
		apt-get -qq -o=Dpkg::Use-Pty=0 update -y 2>/dev/null || apt-get -qq -o=Dpkg::Use-Pty=0 -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" dist-upgrade -y
	} && _PRINT_MESSAGE "System update complete" || _PRINT_ERROR_EXIT "Failed to update system"
	_PRINT_TITLE "Checking for package dependencies"
	for package in wget proot tar pulseaudio; do
		if [ -e "${PREFIX}/bin/${package}" ]; then
			_PRINT_MESSAGE "Package ${package} is installed"
		else
			_PRINT_MESSAGE "Installing ${package}" N
			apt-get -qq -o=Dpkg::Use-Pty=0 install -y "${package}" 2>/dev/null || _PRINT_ERROR_EXIT "Failed to install ${package}" 1
			_PRINT_MESSAGE "Package ${package} is installed"
		fi
	done
}

# Prompts for installation
# Sets SELECTED_INSTALLATION
_SELECT_INSTALLATION() {
	_PRINT_TITLE "Select installation"
	echo
	_PRINT_MESSAGE "[1] ${DISTRO_NAME} ${SYS_ARCH} (full)"
	# _PRINT_MESSAGE "[2] ${DISTRO_NAME} ${SYS_ARCH} (mini)"
	_PRINT_MESSAGE "[2] ${DISTRO_NAME} ${SYS_ARCH} (nano)"
	echo
	_PRINT_MESSAGE "Enter choice (default=nano)" R
	read -ren 1 SELECTED_INSTALLATION
	echo
	case "${SELECTED_INSTALLATION}" in
		1 | f | F)
			_PRINT_MESSAGE "Full installation selected"
			SELECTED_INSTALLATION="full"
			;;
		# 2 | m | M)
		# 	_PRINT_MESSAGE "Mini installation selected"
		# 	SELECTED_INSTALLATION="minimal"
		# 	;;
		*)
			_PRINT_MESSAGE "Nano installation selected"
			SELECTED_INSTALLATION="nano"
			;;
	esac
}

# Checks for existing rootfs directory
# Sets KEEP_ROOTFS_DIRECTORY
_CHECK_ROOTFS_DIRECTORY() {
	unset KEEP_ROOTFS_DIRECTORY
	if [ -e "${ROOTFS_DIRECTORY}" ]; then
		if [ -d "${ROOTFS_DIRECTORY}" ]; then
			if _ASK "Existing rootfs directory found. Delete and create a new one" "N"; then
				_PRINT_MESSAGE "Deleting rootfs directory" E
			elif _ASK "Rootfs directory might be corrupted, use it anyway" "N"; then
				_PRINT_MESSAGE "Using existing rootfs directory"
				KEEP_ROOTFS_DIRECTORY=1
				return
			else
				_PRINT_ERROR_EXIT "Rootfs directory not touched"
			fi
		else
			if _ASK "Existing item found with same name as rootfs directory. Delete item" "N"; then
				_PRINT_MESSAGE "Deleting item" E
			else
				_PRINT_ERROR_EXIT "Item not touched"
			fi
		fi
		rm -rf "${ROOTFS_DIRECTORY}" && _PRINT_MESSAGE "Deleted successfully" || _PRINT_ERROR_EXIT "Failed to delete"
	fi
}

# Downloads roots archive
# Sets KEEP_ROOTFS_MAGE
_DOWNLOAD_ROOTFS_ARCHIVE() {
	unset KEEP_ROOTFS_MAGE
	if [ -z "${KEEP_ROOTFS_DIRECTORY}" ]; then
		if [ -e "${ARCHIVE_NAME}" ]; then
			if [ -f "${ARCHIVE_NAME}" ]; then
				if _ASK "Existing roots archive found. Delete and download a new one" "N"; then
					_PRINT_MESSAGE "Deleting old roots archive" E
				else
					_PRINT_MESSAGE "Using existing rootfs archive"
					KEEP_ROOTFS_MAGE=1
					return
				fi
			else
				if _ASK "Item found with same name as rootfs archive. Delete item" "N"; then
					_PRINT_MESSAGE "Deleting item" E
				else
					_PRINT_ERROR_EXIT "Item not touched"
				fi
			fi
			rm -f "${ARCHIVE_NAME}" && _PRINT_MESSAGE "Deleted successfully" || _PRINT_ERROR_EXIT "Failed to delete"
		fi
		_PRINT_TITLE "Downloading rootfs archive"
		wget --no-verbose --continue --show-progress --output-document="${ARCHIVE_NAME}" "${BASE_URL}/${ARCHIVE_NAME}" && _PRINT_MESSAGE "Download complete" || _PRINT_ERROR_EXIT "Failed to download rootfs archive" 1
	fi
}

# Verifies integrity of rootfs archive
_VERIFY_ROOTFS_ARCHIVE() {
	if [ -z "${KEEP_ROOTFS_DIRECTORY}" ]; then
		_PRINT_TITLE "Verifying integrity of the rootfs archive"
		# 2023-Aug-23 13:36
		local TRUSTED_SHASUMS="$(
			cat <<-EOF
				7406c9a0e7e3f5fd88454945eb7f0a63f993d48abde38af2ec9ed00b33ff204c  nethunter-2023.3b-generic-arm64-kalifs-full.zip
				740a7c7899bf64cb27a1a6b16de8bf4ea159bfdf30c331ac6fcbdb3e3e1da224  nethunter-2023.3b-generic-arm64-kalifs-full.zip.torrent
				96aa1d409d0430de28cddd9613a46c486b67cd322f3988aee121c374469b4b88  nethunter-2023.3b-generic-arm64-kalifs-nano.zip
				7d21b1122e4d0d3b2a67bdb9ea5c4e37551351ed4bda8c95cf8d054183262920  nethunter-2023.3b-generic-arm64-kalifs-nano.zip.torrent
				09dc86d922d134335198dec955515bca67809b2d752c269454590285a68dba84  nethunter-2023.3b-generic-armhf-kalifs-full.zip
				2342c27eed4d6d6e706694c6372d2ca642018c78573c828f8db5434116b6c43c  nethunter-2023.3b-generic-armhf-kalifs-full.zip.torrent
				7fbf5f20543b34a1d2c3c1d4f1137c2f40742dd53d28229a82986e6042b294fa  nethunter-2023.3b-generic-armhf-kalifs-nano.zip
				d3531be4a062b93cda59439be7831561958a4fa0419035c52ff4fb778dfacf1c  nethunter-2023.3b-generic-armhf-kalifs-nano.zip.torrent
			EOF
		)"
		if grep --regexp="${ARCHIVE_NAME}$" <<<"${TRUSTED_SHASUMS}" | sha256sum --quiet --check &>/dev/null; then
			_PRINT_MESSAGE "Rootfs archive is ok"
			return
		elif TRUSTED_SHASUMS="$(wget --quiet --output-document="-" "${BASE_URL}/SHA256SUMS")"; then
			if grep --regexp="${ARCHIVE_NAME}$" <<<"${TRUSTED_SHASUMS}" | sha256sum --quiet --check &>/dev/null; then
				_PRINT_MESSAGE "Rootfs archive is ok"
				return
			fi
		else
			_PRINT_ERROR_EXIT "Failed to verify integrity of the rootfs archive" 1
		fi
		_PRINT_ERROR_EXIT "Rootfs corrupted" 0
	fi
}

# Extracts rootfs archive
_EXTRACT_ROOTFS_ARCHIVE() {
	if [ -z "${KEEP_ROOTFS_DIRECTORY}" ]; then
		_PRINT_TITLE "Extracting rootfs archive"
		# These cause mknod errors and tar exits with non zero
		local rootfs_archive="kalifs-${SYS_ARCH}-${SELECTED_INSTALLATION}.tar.xz"
		local exclude_files=(
			"--exclude=${DEFAULT_ROOTFS_DIRECTORY}/dev/null"
			"--exclude=${DEFAULT_ROOTFS_DIRECTORY}/dev/tty"
			"--exclude=${DEFAULT_ROOTFS_DIRECTORY}/dev/full"
			"--exclude=${DEFAULT_ROOTFS_DIRECTORY}/dev/urandom"
			"--exclude=${DEFAULT_ROOTFS_DIRECTORY}/dev/zero"
			"--exclude=${DEFAULT_ROOTFS_DIRECTORY}/dev/random"
			"--exclude=${DEFAULT_ROOTFS_DIRECTORY}/dev/console"
			"--exclude=${DEFAULT_ROOTFS_DIRECTORY}/dev/ptmx"
		)
		printf "${Y}"
		unzip -p "${ARCHIVE_NAME}" "${rootfs_archive}" | proot --link2symlink tar --extract --xz --file="-" --directory="$(dirname "${ROOTFS_DIRECTORY}")" --checkpoint=1 --checkpoint-action=ttyout="   Extracted bytes %{}T in %ds%*\r" "${exclude_files[@]}" &>/dev/null || _PRINT_ERROR_EXIT "Failed to extract rootfs archive" 0
		printf "${N}"
	fi
}

# Creates script to start Kali NetHunter
_CREATE_NH_LAUNCHER() {
	_PRINT_TITLE "Creating ${DISTRO_NAME} launcher"
	local DISTRO_LAUNCHER="${PREFIX}/bin/nethunter"
	local DISTRO_SHORTCUT="${PREFIX}/bin/nh"
	mkdir -p "${PREFIX}/bin" && cat >"${DISTRO_LAUNCHER}" <<-EOF
		#!/data/data/com.termux/files/usr/bin/bash -e

		################################################################################
		#                                                                              #
		#     ${DISTRO_NAME} launcher, version ${SCRIPT_VERSION}                                     #
		#                                                                              #
		#     This script starts ${DISTRO_NAME}.                                       #
		#                                                                              #
		#     Copyright (C) 2023  ${AUTHOR_NAME} <${AUTHOR_GITHUB}>             #
		#                                                                              #
		################################################################################

		# Enables audio support
		# For rooted users, add option '--system'
		pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1

		# unset LD_PRELOAD in case termux-exec is installed
		unset LD_PRELOAD

		# Workaround for Libreoffice, also needs to bind a fake /proc/version
		if [ ! -f "${ROOTFS_DIRECTORY}/root/.version" ]; then
		    touch "${ROOTFS_DIRECTORY}/root/.version"
		fi

		# Command to start ${DISTRO_NAME}
		command="proot"
		command+=" --link2symlink"
		command+=" --kill-on-exit"
		command+=" --root-id"
		command+=" --rootfs=${ROOTFS_DIRECTORY}"
		command+=" --bind=/dev"
		command+=" --bind=/proc"
		command+=" --bind=${ROOTFS_DIRECTORY}/root:/dev/shm"
		command+=" --cwd=/"

		# Add acess to internal storage
		if [ -n "\${INTERNAL_STORAGE}" ]; then
		    command+=" --bind=\${INTERNAL_STORAGE}:/media/disk0"
		elif [ -d "/sdcard" ]; then
		    command+=" --bind=/sdcard:/media/disk0"
		fi

		# Add access to external storage
		if [ -n "\${EXTERNAL_STORAGE}" ]; then
		    command+=" --bind=\${EXTERNAL_STORAGE}:/media/disk1"
		fi

		# command+=" /usr/bin/env -i"
		# command+=" TERM=\${TERM}"
		# command+=" LANG=C.UTF-8"
		command+=" /usr/bin/login"

		# Execute launch command
		exec \${command}
	EOF
	{
		ln -sfT "${DISTRO_LAUNCHER}" "${DISTRO_SHORTCUT}" &>/dev/null && termux-fix-shebang "${DISTRO_LAUNCHER}" && chmod 700 "${DISTRO_LAUNCHER}"
	} && _PRINT_MESSAGE "${DISTRO_NAME} launcher created successfully" || _PRINT_ERROR_EXIT "Failed to create ${DISTRO_NAME} launcher" 0
}

# Creates VNC launcher
_CREATE_VNC_LAUNCHER() {
	_PRINT_TITLE "Creating VNC launcher"
	local VNC_LAUNCHER="${ROOTFS_DIRECTORY}/usr/local/bin/vnc"
	mkdir -p "${ROOTFS_DIRECTORY}/usr/local/bin" && cat >"${VNC_LAUNCHER}" <<-EOF
		#!/usr/bin/bash -e

		################################################################################
		#                                                                              #
		#     VNC launcher, version \${SCRIPT_VERSION}                                                #
		#                                                                              #
		#     This script starts the VNC server.                                       #
		#                                                                              #
		#     Copyright (C) 2023  \${AUTHOR_NAME} <\${AUTHOR_GITHUB}>             #
		#                                                                              #
		################################################################################

		################################################################################
		#                                FUNCTIONS                                     #
		################################################################################

		_CHECK_USER() {
		    if [ "\${USER}" = "root" ] || [ "\${EUID}" -eq 0 ] || [ "\$(whoami)" = "root" ]; then
		        read -rep ">> Some applications are not meant to be run as root and may not work properly. Continue anyway? y/N " -rn 1 REPLY
		        echo ""
		        case "\${REPLY}" in
		            y | Y) return ;;
		        esac
		        echo "Abort."
		        exit 1
		    fi
		}

		_CLEAN_TMP_DIR() {
		    rm -rf "/tmp/.X\${DISPLAY_VALUE}-lock" "/tmp/.X11-unix/X\${DISPLAY_VALUE}"
		}

		_SET_GEOMETRY() {
		    case "\${ORIENTATION_STYLE}" in
		        "potrait")
		            geometry="\${WIDTH_VALUE}x\${HEIGHT_VALUE}"
		            ;;
		        *)
		            geometry="\${HEIGHT_VALUE}x\${WIDTH_VALUE}"
		            ;;
		    esac
		}

		_SET_PASSWD() {
		    [ -x "\$(command -v vncpasswd)" ] && vncpasswd || { echo ">> No VNC server installed" && return 1; }
		    return \$?
		}

		_START_SERVER() {
		    if [ -f "\${HOME}/.vnc/passwd" ] && [ -r "\${HOME}/.vnc/passwd" ]; then
		        export HOME="\${HOME}"
		        export USER="\${USER}"
		        LD_PRELOAD="${LIB_GCC_PATH}"
		        # You can use nohup
		        /usr/bin/vncserver ":\${DISPLAY_VALUE}" -geometry "\${geometry}" -depth "\${DEPTH_VALUE}" -name remote-desktop && echo -e ">> VNC server started successfully."
		    else
		        _SET_PASSWD && _START_SERVER
		    fi
		}

		_KILL_SERVER() {
		    vncserver -clean -kill ":\${DISPLAY_VALUE}" && _CLEAN_TMP_DIR
		    return \$?
		}

		_PRINT_USAGE() {
		    echo ">> Usage \$(basename \$0) [option]..."
		    echo "   Start VNC server."
		    echo ""
		    echo ">> Options"
		    echo "   --potrait"
		    echo "         Use potrait orientation."
		    echo "   --landscape"
		    echo "         Use landscape orientation. (default)"
		    echo "   -p, --password"
		    echo "         Set or change password."
		    echo "   -s, --start"
		    echo "         Start vncserver. (default if no options supplied)"
		    echo "   -k, --kill"
		    echo "         Kill vncserver."
		    echo "   -h, --help"
		    echo "          Print this message and exit."
		}

		################################################################################
		#                                ENTRY POINT                                   #
		################################################################################

		DEPTH_VALUE=24
		WIDTH_VALUE=720
		HEIGHT_VALUE=1600
		ORIENTATION_STYLE="landscape"
		DISPLAY_VALUE="\$(cut -d : -f 2 <<< "\${DISPLAY}")"

		# Process command line args
		for option in "\${@}"; do
		    case "\$option" in
		        "--potrait")
		            ORIENTATION_STYLE=potrait
		            ;;
		        "--landscape")
		            ORIENTATION_STYLE=landscape
		            ;;
		        "-p" | "--password")
		            _SET_PASSWD
		            exit \$?
		            ;;
		        "-k" | "--kill")
		            _KILL_SERVER
		            exit \$?
		            ;;
		        "-h" | "--help")
		            _PRINT_USAGE
		            exit \$?
		            ;;
		        "-s" | "--start") ;;
		        *)
		            echo ">> Unknown option '\$option'."
		            _PRINT_USAGE
		            exit 1
		            ;;
		    esac
		done

		if [ -x "\$(command -v vncserver)" ]; then
		    _CHECK_USER && _CLEAN_TMP_DIR && _SET_GEOMETRY && _START_SERVER
		else
		    echo ">> No VNC server installed"
		fi
	EOF
	chmod 700 "$VNC_LAUNCHER" && _PRINT_MESSAGE "VNC launcher created successfully" || _PRINT_MESSAGE "Failed to create VNC launcher" E
}

# Deletes downloaded files
_CLEANUP_DOWNLOADS() {
	if [ -z "${KEEP_ROOTFS_DIRECTORY}" ] && [ -z "${KEEP_ROOTFS_MAGE}" ] && [ -f "${ARCHIVE_NAME}" ]; then
		if _ASK "Remove downloaded rootfs archive to save space" "N"; then
			_PRINT_MESSAGE "Removing downloaded rootfs archive" E
			rm -f "${ARCHIVE_NAME}" && _PRINT_MESSAGE "Downloaded rootfs archive removed" || _PRINT_MESSAGE "Failed to remove downloaded rootfs archive" E
		else
			_PRINT_MESSAGE "Downloaded rootfs archive not touched"
		fi
	fi
}

# Prints usage instructions
_PRINT_COMPLETE_MSG() {
	_PRINT_TITLE "${DISTRO_NAME} installed successfully" S
	_PRINT_MESSAGE "Run command '${Y}nethunter${C}' or '${Y}nh${C}' to start ${DISTRO_NAME}" N
	_PRINT_MESSAGE "Run command '${Y}vnc${C}' in ${DISTRO_NAME} to start the VNC Server" N
	_PRINT_TITLE "Login Information"
	_PRINT_MESSAGE "Login as super user" N
	_PRINT_MESSAGE "User/Login  '${Y}root${G}'"
	_PRINT_MESSAGE "Password    '${Y}${ROOT_PASSWD}${G}'"
	_PRINT_MESSAGE "Login as normal user" N
	_PRINT_MESSAGE "User/Login  '${Y}kali${G}'"
	_PRINT_MESSAGE "Password    '${Y}kali${G}'"
	_PRINT_TITLE "Documentation  ${U}${AUTHOR_GITHUB}/${SCRIPT_REPOSITORY}${NU}"
	# For minimal and nano installations
	if [ "${SELECTED_INSTALLATION}" != "full" ]; then
		_PRINT_TITLE "This is a ${SELECTED_INSTALLATION} installation of ${DISTRO_NAME}" E
		_PRINT_MESSAGE "Read the documentation on how to install additional components" E
	fi
}

# Prints script version
_PRINT_VERSION() {
	_PRINT_TITLE "${DISTRO_NAME} Installer, version ${SCRIPT_VERSION}"
	_PRINT_MESSAGE "Copyright (C) 2023 ${AUTHOR_NAME} <${U}${AUTHOR_GITHUB}${NU}>"
	_PRINT_MESSAGE "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>"
	_PRINT_MESSAGE "This is free software; you are free to change and redistribute it"
	_PRINT_MESSAGE "There is NO WARRANTY, to the extent permitted by law"
}

# Prints script usage
_PRINT_USAGE() {
	_PRINT_TITLE "Usage: $(basename "${0}") [option${C}]... [DIRECTORY]"
	_PRINT_MESSAGE "Install ${DISTRO_NAME} in DIRECTORY (default HOME/kali-<arch>)"
	_PRINT_TITLE "Options"
	_PRINT_MESSAGE "-h, --help"
	_PRINT_MESSAGE "        Print this message and exit"
	_PRINT_MESSAGE "-v. --version"
	_PRINT_MESSAGE "        Print program version and exit"
	_PRINT_TITLE "DIRECTORY must be within ${TERMUX_FILES_DIR} or its sub-folders" E
	_PRINT_TITLE "Documentation  ${U}${AUTHOR_GITHUB}/${SCRIPT_REPOSITORY}${NU}"
}

##########
### Issues
##########

# Fixes all issues
# Sets TMP_LOGIN_COMMAND
_FIX_ISSUES() {
	_PRINT_TITLE "Installation complete" S
	_PRINT_MESSAGE "Making some configurations" N
	local bug_descriptions=(
		"Configuring root settings"
		"Configuring display settings"
		"Configuring audio settings"
		"Configuring internet settings"
		"Configuring java settings"
		"Configuring profile settings"
	)
	# command for logging in
	unset LD_PRELOAD && TMP_LOGIN_COMMAND="proot --link2symlink --root-id --rootfs=${ROOTFS_DIRECTORY} --cwd=/"
	local descr_num=0
	for issue in _FIX_SUDO _FIX_DISPLAY _FIX_AUDIO _FIX_DNS _FIX_JDK _FIX_PROFILE; do
		_PRINT_MESSAGE "${bug_descriptions[${descr_num}]}" N
		if "${issue}" &>/dev/null; then
			_PRINT_MESSAGE "Sucess"
		else
			_PRINT_MESSAGE "Failed" E
		fi
		((descr_num++))
	done
	_PRINT_MESSAGE "Setting a root password" N
	if _SET_ROOT_PASSWD &>/dev/null; then
		_PRINT_MESSAGE "Sucess"
	else
		_PRINT_ERROR_EXIT "Failed" 0
	fi
	if _ASK "Set UID and GID for user kali to that of Termux" "N"; then
		_FIX_UID_AND_GID &>/dev/null && _PRINT_MESSAGE "Sucess" || _PRINT_MESSAGE "Failed" E
	fi
	if _ASK "Change login shell (default=zsh)" "N"; then
		_SET_DEFAULT_SHELL && _PRINT_MESSAGE "Sucess" || _PRINT_MESSAGE "Failed" E
	fi
	if _ASK "Set Time Zone and Local Time" "N"; then
		_SET_ZONE_INFO && _PRINT_MESSAGE "Sucess" || _PRINT_MESSAGE "Failed" E
	fi
}

# Fixes sudo and su on start
_FIX_SUDO() {
	local bin_dir="${ROOTFS_DIRECTORY}/usr/bin"
	if [ -x "${bin_dir}/sudo" ]; then
		chmod +s "${bin_dir}/sudo"
		echo "kali   ALL=(ALL:ALL) NOPASSWD: ALL" >"${ROOTFS_DIRECTORY}/etc/sudoers.d/kali"
		echo "Set disable_coredump false" >"${ROOTFS_DIRECTORY}/etc/sudo.conf"
	fi
	if [ -x "${bin_dir}/su" ]; then
		chmod +s "${bin_dir}/su"
	else
		return 1
	fi
}

# Sets display
_FIX_DISPLAY() {
	mkdir -p "${ROOTFS_DIRECTORY}/etc/profile.d/" && cat >"${ROOTFS_DIRECTORY}/etc/profile.d/display.sh" <<-EOF
		if [ "\${USER}" = "root" ] || [ "\$EUID" -eq 0 ] || [ "\$(whoami)" = "root" ]; then
		    export DISPLAY=:0
		else
		    export DISPLAY=:1
		fi
	EOF
}

# Sets pulse audio server
_FIX_AUDIO() {
	mkdir -p "${ROOTFS_DIRECTORY}/etc/profile.d/" && echo "export PULSE_SERVER=127.0.0.1" >"${ROOTFS_DIRECTORY}/etc/profile.d/pulseserver.sh"
}

# Sets dns settings
_FIX_DNS() {
	mkdir -p "${ROOTFS_DIRECTORY}/etc/" && cat >"${ROOTFS_DIRECTORY}/etc/resolv.conf" <<-EOF
		nameserver 8.8.8.8
		nameserver 8.8.4.4
	EOF
}

# Sets java variables
_FIX_JDK() {
	if [[ "${SYS_ARCH}" == "armhf" ]]; then
		mkdir -p "${ROOTFS_DIRECTORY}/etc/profile.d/" && cat >"${ROOTFS_DIRECTORY}/etc/profile.d/java.sh" <<-EOF
			export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-armhf/
			export PATH=\$JAVA_HOME/bin:\$PATH
		EOF
	elif [[ "${SYS_ARCH}" == "arm64" ]]; then
		mkdir -p "${ROOTFS_DIRECTORY}/etc/profile.d/" && cat >"${ROOTFS_DIRECTORY}/etc/profile.d/java.sh" <<-EOF
			export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-aarch64/
			export PATH=\$JAVA_HOME/bin:\$PATH
		EOF
	else
		return 1
	fi
}

# Prevents creation of links in read only file system
_FIX_PROFILE() {
	if [ -f "${ROOTFS_DIRECTORY}/root/.bash_profile" ]; then
		sed -i '/^if/,/^fi/d' "${ROOTFS_DIRECTORY}/root/.bash_profile"
	else
		return 1
	fi
}

# Sets uid and gid of user kali to that of Termux
_FIX_UID_AND_GID() {
	if [ -x "${ROOTFS_DIRECTORY}/usr/sbin/usermod" ] && [ -x "${ROOTFS_DIRECTORY}/usr/sbin/groupmod" ]; then
		local USRID="$(id -u)"
		local GRPID="$(id -g)"
		${TMP_LOGIN_COMMAND} /usr/sbin/usermod -u "${USRID}" kali
		${TMP_LOGIN_COMMAND} /usr/sbin/groupmod -g "${GRPID}" kali
	else
		return 1
	fi
}

# Sets root passwd
_SET_ROOT_PASSWD() {
	if [ -x "${ROOTFS_DIRECTORY}/usr/bin/passwd" ]; then
		${TMP_LOGIN_COMMAND} "usr/bin/passwd" root <<-EOF
			${ROOT_PASSWD}
			${ROOT_PASSWD}
		EOF
	else
		return 1
	fi
}

# Sets default shell
_SET_DEFAULT_SHELL() {
	if [ -x "${ROOTFS_DIRECTORY}/usr/bin/chsh" ]; then
		local shells=("bash" "zsh" "fish" "dash" "tcsh" "csh" "ksh")
		_PRINT_MESSAGE "Select default login shell" N
		_PRINT_MESSAGE "Enter choice" R && read -rei "${shells[0]}" shell
		if [[ "${shells[*]}" == *"${shell}"* ]] && [ -x "${ROOTFS_DIRECTORY}/usr/bin/${shell}" ]; then
			${TMP_LOGIN_COMMAND} /usr/bin/chsh -s "/usr/bin/${shell}" kali
			${TMP_LOGIN_COMMAND} /usr/bin/chsh -s "/usr/bin/${shell}" root
		else
			_PRINT_MESSAGE "'${shell}' not found" E && _ASK "Try again" "N" && _SET_DEFAULT_SHELL
		fi
	else
		return 1
	fi
}

# Sets zone information
_SET_ZONE_INFO() {
	if [ -x "${ROOTFS_DIRECTORY}/usr/bin/ln" ]; then
		_PRINT_MESSAGE "Select time zone (format Country/City)" N
		_PRINT_MESSAGE "Enter choice" R && read -re zone
		if [ -f "${ROOTFS_DIRECTORY}/usr/share/zoneinfo/${zone}" ]; then
			echo "${zone}" >"${ROOTFS_DIRECTORY}/etc/timezone" && ${TMP_LOGIN_COMMAND} /usr/bin/ln -fs -T "/usr/share/zoneinfo/${zone}" /etc/localtime
		else
			_PRINT_MESSAGE "'${zone}' not found" && _ASK "Try again" "N" && _SET_ZONE_INFO
		fi
	else
		return 1
	fi
}

###########
### Helpers
###########

# Prints title
_PRINT_TITLE() {
	local color="${C}"
	local prefix=">> "
	case "${2}" in
		s | S)
			color="${G}"
			# prefix=""
			;;
		e | E)
			color="${R}"
			# prefix=""
			;;
	esac
	printf "\n${color}${prefix}${1}${N}\n"
}

# Prints message
_PRINT_MESSAGE() {
	local color="${G}"
	local prefix="   "
	case "${2}" in
		n | N)
			color="${C}"
			# prefix=""
			;;
		e | E)
			color="${R}"
			# prefix=""
			;;
		r | R)
			printf "${C}${prefix}${1}: ${N}"
			return
			;;
	esac
	printf "${color}${prefix}${1}${N}\n"
}

# Prints error message and exits
_PRINT_ERROR_EXIT() {
	local color="${R}"
	local prefix="   "
	if [ -n "${2}" ]; then
		local suggested_messages=(
			" Try running this script again"
			" Internet connection required"
			" Try '-h' or '--help' for usage"
		)
		local message="${suggested_messages[${2}]}"
	fi
	printf "${color}${prefix}${1}${message}${N}\n"
	exit 1
}

# Asks for Y/N response
_ASK() {
	local color="${C}"
	local prefix=" "
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
	# echo
	local retries=3
	while true; do
		if [ ${retries} -ne 3 ]; then
			prefix="${R}${retries}${N}${color}"
		fi
		printf "\r${color} ${prefix} ${1}? (${prompt}) ${N}"
		read -ren 1 reply
		if [ -z "${reply}" ]; then
			reply="${default}"
		fi
		case "${reply}" in
			Y | y) echo && return 0 ;;
			N | n) echo && return 1 ;;
		esac
		# Return default value 3rd time
		((retries--))
		if [ -n "${default}" ] && [ ${retries} -eq 0 ]; then # && [[ ${default} =~ ^(Y|N|y|n)$ ]]; then
			case "${default}" in
				y | Y) echo && return 0 ;;
				n | N) echo && return 1 ;;
			esac
		fi
	done
}

################################################################################
#                                ENTRY POINT                                   #
################################################################################

# Author info
AUTHOR_NAME="Jore"
AUTHOR_GITHUB="https://github.com/jorexdeveloper"

# Script info
SCRIPT_VERSION="1.0"
SCRIPT_REPOSITORY="termux-nethunter"

# Static info
ROOT_PASSWD="root"
DISTRO_NAME="Kali NetHunter"
TERMUX_FILES_DIR="/data/data/com.termux/files"
BASE_URL="https://kali.download/nethunter-images/current/"
ARCHIVE_VERSION="2023.3b"

# Color supported terminals
case "${TERM}" in
	*color*)
		R="\e[1;31m"
		G="\e[1;32m"
		Y="\e[1;33m"
		C="\e[1;36m"
		U="\e[1;4m"
		NU="\e[24m"
		N="\e[0m"
		;;
esac

# Proces command line args
for option in "${@}"; do
	case "${option}" in
		"-v" | "--version")
			_PRINT_VERSION
			exit
			;;
		"-h" | "--help")
			_PRINT_USAGE
			exit
			;;
	esac
done

# Begin
_PRINT_BANNER
_CHECK_ARCHITECTURE
_CHECK_DEPENDENCIES
_SELECT_INSTALLATION

# Arch dependent variables
DEFAULT_ROOTFS_DIRECTORY="kali-${SYS_ARCH}"
ARCHIVE_NAME="nethunter-${ARCHIVE_VERSION}-generic-${SYS_ARCH}-kalifs-${SELECTED_INSTALLATION}.zip"

# Set installation directory (must be within Termux to prevent permission issues)
if [ -n "${1}" ] && ROOTFS_DIRECTORY="$(realpath "${1}")" && [[ "${ROOTFS_DIRECTORY}" == "${TERMUX_FILES_DIR}"* ]]; then
	test
else
	if [ -n "${1}" ]; then
		_PRINT_ERROR_EXIT "Directory '${1}' is not within ${TERMUX_FILES_DIR}" 2
	fi
	ROOTFS_DIRECTORY="$(realpath "${TERMUX_FILES_DIR}/home/${DEFAULT_ROOTFS_DIRECTORY}")"
fi

# Comfirm Installation directory
_PRINT_TITLE "Installing ${DISTRO_NAME} in ${ROOTFS_DIRECTORY}"

# Installation
_CHECK_ROOTFS_DIRECTORY
_DOWNLOAD_ROOTFS_ARCHIVE
_VERIFY_ROOTFS_ARCHIVE
_EXTRACT_ROOTFS_ARCHIVE
_CREATE_NH_LAUNCHER
_CREATE_VNC_LAUNCHER
_CLEANUP_DOWNLOADS

# Fix issues
_FIX_ISSUES

# Print help info
_PRINT_COMPLETE_MSG

# Exit successfully
exit
