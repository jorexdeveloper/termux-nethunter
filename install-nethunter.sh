#!/data/data/com.termux/files/usr/bin/bash

################################################################################
#                                                                              #
#     Kali NetHunter Installer.                                                #
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

AUTHOR="Jore"
GITHUB="https://github.com/jorexdeveloper"
REPOSITORY="termux-nethunter"
NAME="$(basename "${0}")"
VERSION="2024.3"

################################################################################
# Prevents running this program as root to prevent harm to system directories  #
################################################################################
root_check() {
	if [ "${EUID}" = "0" ] || [ "$(id -u)" = "0" ]; then
		msg -aq "Hold up right there! I can't let you run this program with root access. This can have some unintended effects."
	fi
}

################################################################################
# Prints the distro banner                                                     #
################################################################################
print_intro() {
	local spaces=""
	for ((i = $(((($(stty size | cut -d ' ' -f2) - 56) / 2))); i > 0; i--)); do
		spaces+=" "
	done
	clear
	msg -a "${spaces} _  __     _ _   _  _     _   _  _          _"
	msg -a "${spaces}| |/ /__ _| (_) | \| |___| |_| || |_  _ _ _| |_ ___ _ _"
	msg -a "${spaces}| ' </ _' | | | | .' / -_)  _| __ | || | ' \  _/ -_) '_|"
	msg -a "${spaces}|_|\_\__,_|_|_| |_|\_\___|\__|_||_|\_,_|_||_\__\___|_|"
	msg -a "${spaces}                         ${VERSION}"
	msg -t "Hey there,👋 I'm ${AUTHOR}"
	msg "I am here to help you to install ${DISTRO_NAME}."
}

################################################################################
# Checks if the device architecture is supported                               #
# Sets global variables: SYS_ARCH LIB_GCC_PATH                                 #
################################################################################
check_arch() {
	msg -t "First, lemme check if your device architecture is supported."
	local arch
	if [ -x "$(command -v getprop)" ]; then
		arch="$(getprop ro.product.cpu.abi 2>>"${LOG_FILE}")"
	elif [ -x "$(command -v uname)" ]; then
		arch="$(uname -m 2>>"${LOG_FILE}")"
	else
		msg -q "Unfortunately, I can't get your device architecture."
	fi
	case "${arch}" in
		"arm64-v8a" | "armv8l")
			SYS_ARCH="arm64"
			LIB_GCC_PATH="/usr/lib/aarch64-linux-gnu/libgcc_s.so.1"
			;;
		"armeabi" | "armv7l" | "armeabi-v7a")
			SYS_ARCH="armhf"
			LIB_GCC_PATH="/usr/lib/arm-linux-gnueabihf/libgcc_s.so.1"
			;;
		*) msg -q "Sorry, '${arch}' is currently not supported." ;;
	esac
	msg -s "Great! '${arch}' is supported."
}

################################################################################
# Updates installed packages and che<ks if the required commands that are not  #
# pre-installed are installed, if not, attempts to install them                #
################################################################################
check_pkgs() {
	msg -t "Now lemme check if all system packages are up to date. Just a sec..."
	if pkg update -y < <(echo -e "y\ny\ny\ny\ny") &>>"${LOG_FILE}" || apt-get -qq -o=Dpkg::Use-Pty=0 update -y &>>"${LOG_FILE}" || apt-get -qq -o=Dpkg::Use-Pty=0 -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" dist-upgrade -y &>>"${LOG_FILE}"; then
		msg -s "Yup! Everything looks good. Let's proceed."
	else
		msg -q "Sorry! Your system is not up to date."
	fi
	msg -t "Hold on while I check if all the required packages are installed."
	for package in tar wget proot unzip pulseaudio; do
		if ! [ -x "$(command -v "${package}")" ]; then
			msg "Oops, '${package}' is missing. Let me install it now..."
			if pkg install -y "${package}" < <(echo -e "y\ny\ny\ny\ny") &>>"${LOG_FILE}" || apt-get -qq -o=Dpkg::Use-Pty=0 install -y "${package}" &>>"${LOG_FILE}"; then
				msg -s "Done! '${package}' is now installed."
			else
				msg -q "Unfortunately, I can't install '${package}'."
			fi
		fi
	done
	msg -s "Great! You have all the required packages! Let's get started!"
	unset package
}

################################################################################
# Checks if there is an existing rootfs directory, or a file with similar name #
# Sets global variables: KEEP_ROOTFS_DIRECTORY                                 #
################################################################################
check_rootfs_directory() {
	unset KEEP_ROOTFS_DIRECTORY
	if [ -e "${ROOTFS_DIRECTORY}" ]; then
		if [ -d "${ROOTFS_DIRECTORY}" ]; then
			if [ -n "$(ls -UA "${ROOTFS_DIRECTORY}" 2>>"${LOG_FILE}")" ]; then
				msg -t "Wait! I have found an existing rootfs directory that is not empty."
				msg "What should I do with it?"
				msg -l "Use the directory." "Delete the directory." "Leave the directory and exit. (default)"
				msg -n "Select action: "
				read -ren 1 reply
				case "${reply}" in
					1 | u | U)
						msg "Okay then, I shall proceed with the existing rootfs directory."
						KEEP_ROOTFS_DIRECTORY=1
						return
						;;
					2 | d | D) ;;
					*) msg -q "Alright, I shall leave the rootfs directory." ;;
				esac
				unset reply
			else
				rmdir "${ROOTFS_DIRECTORY}" &>>"${LOG_FILE}"
				return
			fi
		else
			msg -t "Wait! I have found a file with the same path as the rootfs directory."
			if ! ask -n "Should I delete the file and proceed?"; then
				msg -q "Alright! I shall not touch the file."
			fi
		fi
		msg -e "Okay, deleting '${ROOTFS_DIRECTORY}'."
		if rm -rf "${ROOTFS_DIRECTORY}"; then
			msg -s "Done! Now let's proceed."
		else
			msg -q "Unfortunately, I can't delete '${ROOTFS_DIRECTORY}'."
		fi
	fi
}

################################################################################
# Prompts the user for the required rootfs installation                        #
# Sets global variables: SELECTED_INSTALLATION                                 #
################################################################################
select_installation() {
	msg -t "Select your prefered installation."
	msg -l "  full    (Large but contains everything you need)" "  minimal (Light-weight with basic packages only)" "> nano    (Like minimal with a few more packages)"
	msg -n "Enter choice: "
	read -ren 1 SELECTED_INSTALLATION
	case "${SELECTED_INSTALLATION}" in
		1 | f | F) SELECTED_INSTALLATION="full" ;;
		2 | m | M) SELECTED_INSTALLATION="minimal" ;;
		*) SELECTED_INSTALLATION="nano" ;;
	esac
	msg "Okay then, I shall install a ${SELECTED_INSTALLATION} rootfs."
}

################################################################################
# Downloads the rootfs archive if it does not exist in the current directory   #
# Sets global variables: KEEP_ROOTFS_ARCHIVE                                     #
################################################################################
download_rootfs_archive() {
	unset KEEP_ROOTFS_ARCHIVE
	if [ -z "${KEEP_ROOTFS_DIRECTORY}" ]; then
		if [ -e "${ARCHIVE_NAME}" ]; then
			if [ -f "${ARCHIVE_NAME}" ]; then
				msg -t "Hold on! I have found an existing rootfs archive."
				if ! ask -n "Should I delete it and download a new one?"; then
					msg "Okay, I shall use the existing rootfs archive."
					KEEP_ROOTFS_ARCHIVE=1
					return
				fi
			else
				msg -t "Hold on! I have found an item with the same name as the rootfs archive."
				if ! ask -n "Should I delete the  item and proceed?"; then
					msg -q "Alright! I shall leave the item."
				fi
			fi
			msg -e "Okay, deleting '${ARCHIVE_NAME}'."
			if rm -rf "${ARCHIVE_NAME}"; then
				msg -s "Done! now let's proceed."
			else
				msg -q "Unfortunately, I can't delete '${ARCHIVE_NAME}'"
			fi
		fi
		local tmp_dload="${ARCHIVE_NAME}.pending"
		msg -t "Alright, it's time to download the rootfs archive. This might take a while..."
		if wget --no-verbose --continue --show-progress --output-document="${tmp_dload}" "${BASE_URL}/${ARCHIVE_NAME}"; then
			mv "${tmp_dload}" "${ARCHIVE_NAME}"
			msg -s "Great! The rootfs download is complete."
		else
			rm -rf "${tmp_dload}"
			msg -qm1 "Unfortunately, I can't download the rootfs archive."
		fi
	fi
}

################################################################################
# Checks the integrity of the rootfs archive                                   #
################################################################################
verify_rootfs_archive() {
	if [ -z "${KEEP_ROOTFS_DIRECTORY}" ]; then
		msg -t "Give me a sec to verify the integrity of the rootfs archive..."
		local trusted_shasums="$(
			cat <<-EOF
				10e5bf2e7a950a8ebdf7f0410feff52c6067c3ffbba7cb1164b082329c3b5759e81573839c63184be642a44e7cd581186f645910f29bd85c5f488a1ae8692fd9  kali-nethunter-rootfs-nano-armhf.tar.xz
				6f143c93a1a0cca739ecf51d0091a7850e4ec135e66b5dc66d30969ef924ea9ba71186b8bf9b725f670785867e2ba5ac57afbd577eb6850d35cb5adbdefc1cd8  kali-nethunter-rootfs-minimal-armhf.tar.xz
				c045d0d5bbb08667803b23d653cd1de1869d42b7437c3de8dce241361c28a75396e879e01fb68060321b97af9ceea81142b44ef71558d2b60ff292d7a7dc5aaa  kali-nethunter-rootfs-full-armhf.tar.xz
			EOF
		)"
		if grep --regexp="${ARCHIVE_NAME}$" <<<"${trusted_shasums}" | sha512sum --quiet --check &>>"${LOG_FILE}"; then
			msg -s "Yup, the rootfs archive is looks fine."
			return
		elif trusted_shasums="$(wget --quiet --output-document="-" "${BASE_URL}/${ARCHIVE_NAME}.sha512sum")"; then # "${BASE_URL}/SHA256SUMS")"; then
			if grep --regexp="${ARCHIVE_NAME}$" <<<"${trusted_shasums}" | sha512sum --quiet --check &>>"${LOG_FILE}"; then
				msg -s "Yup, the rootfs archive is looks fine."
				return
			fi
		else
			msg -qm1 "Unfortunately, I can't verify the integrity of the rootfs archive."
		fi
		msg -qm0 "Unfortunately, the rootfs archive is corrupted and not safe for installation."
	fi
}

################################################################################
# Extracts the contents of the rootfs archive                                  #
################################################################################
extract_rootfs_archive() {
	if [ -z "${KEEP_ROOTFS_DIRECTORY}" ]; then
		msg -t "Grab a coffee while I extract the rootfs archive. This will take a while..."
		trap 'rm -rf "${ROOTFS_DIRECTORY}"; msg -q "Exiting immediately as requested.                        "' HUP INT TERM
		mkdir -p "${ROOTFS_DIRECTORY}"
		set +e
		if # unzip -p "${ARCHIVE_NAME}" "kalifs-${SYS_ARCH}-${SELECTED_INSTALLATION}.tar.xz" |
			proot --link2symlink tar --strip=2 --delay-directory-restore --warning=no-unknown-keyword --extract --xz --exclude="dev" --file="${ARCHIVE_NAME}" --directory="${ROOTFS_DIRECTORY}" --checkpoint=1 --checkpoint-action=ttyout="${I}${Y}   I have extracted %{}T in %ds so far.%*\r${N}${V}" &>>"${LOG_FILE}"
		then
			msg -s "Finally, I am done extracting the rootfs archive."
		else
			rm -rf "${ROOTFS_DIRECTORY}"
			msg -q "Unfortunately, I can't extract the rootfs archive."
		fi
		set -e
		trap - HUP INT TERM
	fi
}

################################################################################
# Creates a script used to login into the distro                               #
################################################################################
create_rootfs_launcher() {
	msg -t "Lemme create a command to launch ${DISTRO_NAME}."
	mkdir -p "$(dirname "${DISTRO_LAUNCHER}")" && cat >"${DISTRO_LAUNCHER}" <<-EOF
		#!/bin/bash -e

		################################################################################
		#                                                                              #
		#     ${DISTRO_NAME} launcher, version ${VERSION}                                  #
		#                                                                              #
		#     Launches ${DISTRO_NAME}.                                                 #
		#                                                                              #
		#     Copyright (C) 2023  ${AUTHOR} <${GITHUB}>             #
		#                                                                              #
		################################################################################

		custom_ids=""
		login_name=""
		distro_command=""
		custom_bindings=""
		share_tmp_dir=false
		no_sysvipc=false
		no_kill_on_exit=false
		no_link2symlink=false
		isolated_env=false
		protect_ports=false
		use_termux_ids=false
		kernel_release="${KERNEL_RELEASE}"

		while [ "\${#}" -gt 0 ]; do
		    case "\${1}" in
		    --command*)
		        optarg="\${1//--command/}"
		        optarg="\${optarg//=/}"
		        if [ -z "\${optarg}" ]; then
		            shift 1
		            optarg="\${1-}"
		        fi
		        if [ -z "\${optarg}" ]; then
		            echo "Option '--command' requires an argument."
		            exit 1
		        fi
		        distro_command="\${optarg}"
		        unset optarg
		        ;;
		    --bind*)
		        optarg="\${1//--bind/}"
		        optarg="\${optarg//=/}"
		        if [ -z "\${optarg}" ]; then
		            shift 1
		            optarg="\${1-}"
		        fi
		        if [ -z "\${optarg}" ]; then
		            echo "Option '--bind' requires an argument."
		            exit 1
		        fi
		        custom_bindings+=" --bind=\${optarg}"
		        unset optarg
		        ;;
		    --share-tmp-dir)
		        share_tmp_dir=true
		        ;;
		    --no-sysvipc)
		        no_sysvipc=true
		        ;;
		    --no-link2symlink)
		        no_link2symlink=true
		        ;;
		    --no-kill-on-exit)
		        no_kill_on_exit=true
		        ;;
		    --isolated)
		        isolated_env=true
		        ;;
		    --protect-ports)
		        protect_ports=true
		        ;;
		    --use-termux-ids)
		        use_termux_ids=true
		        ;;
		    --id*)
		        optarg="\${1//--id/}"
		        optarg="\${optarg//=/}"
		        if [ -z "\${optarg}" ]; then
		            shift 1
		            optarg="\${1-}"
		        fi
		        if [ -z "\${optarg}" ]; then
		            echo "Option '--id' requires an argument."
		            exit 1
		        fi
		        custom_ids="\${optarg}"
		        unset optarg
		        ;;
		    --kernel-release*)
		        optarg="\${1//--kernel-release/}"
		        optarg="\${optarg//=/}"
		        if [ -z "\${optarg}" ]; then
		            shift 1
		            optarg="\${1-}"
		        fi
		        if [ -z "\${optarg}" ]; then
		            echo "Option '--kernel-release' requires an argument."
		            exit 1
		        fi
		        kernel_release="\${optarg}"
		        unset optarg
		        ;;
		    -h | --help)
		        echo "Usage: $(basename "${DISTRO_LAUNCHER}") [OPTION]... [USERNAME]"
		        echo ""
		        echo "Login as user USERNAME or execute a comand in ${DISTRO_NAME}."
		        echo "(prompts for USERNAME if not supplied)"
		        echo ""
		        echo "Options:"
		        echo "    --command[=COMMAND]"
		        echo "            Execute COMMAND in distro."
		        echo "            (default='login')"
		        echo "    --bind[=PATH]"
		        echo "            Make the content of PATH accessible in the guest rootfs."
		        echo "    --share-tmp-dir"
		        echo "            Bind TMPDIR (${TERMUX_FILES_DIR}/usr/tmp if unset)"
		        echo "            to /tmp in the guest rootfs."
		        echo "    --no-sysvipc"
		        echo "            Do not handle System V IPC syscalls in proot."
		        echo "            (WARNING: use with caution)"
		        echo "    --no-link2symlink"
		        echo "            Do not fake hard links with symbolic links."
		        echo "            (WARNING: prevents hard link support)"
		        echo "    --no-kill-on-exit"
		        echo "            Do not kill running processes on command exit."
		        echo "            (WARNING: use with caution)"
		        echo "    --isolated"
		        echo "            Do not include host specific variables and directories."
		        echo "    --protect-ports"
		        echo "            Modify bindings to protected ports to use a higher port"
		        echo "            number."
		        echo "    --use-termux-ids"
		        echo "            Make the current user and group appear as that of termux."
		        echo "            (ignores '--id')"
		        echo "    --id[=UID:GID]"
		        echo "            Make the current user and group appear as UID and GID."
		        echo "    --kernel-release[=STRING]"
		        echo "            Make current kernel realease appear as STRING."
		        echo "            (default='${KERNEL_RELEASE}')"
		        echo "    -h, --help"
		        echo "            Print this information and exit."
		        echo "    -v, --version"
		        echo "            Print distro version and exit."
		        echo ""
		        echo "Documentation: ${GITHUB}/${REPOSITORY}"
		        echo ""
		        echo "Also see proot(1)"
		        exit 0
		        ;;
		    -v | --version)
		        echo "${DISTRO_NAME} launcher, version ${VERSION}."
		        echo "Copyright (C) 2023 ${AUTHOR} <${GITHUB}>."
		        echo "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>."
		        echo ""
		        echo "This is free software, you are free to change and redistribute it."
		        echo "There is NO WARRANTY, to the extent permitted by law."
		        exit 0
		        ;;
		    -*)
		        echo "Unrecognized argument/option '\${1}'."
		        echo "Try '$(basename "${DISTRO_LAUNCHER}") --help' for more information"
		        exit 1
		        ;;
		    *) login_name="\${1}" ;;
		    esac
		    shift 1
		done

		if [ -z "\${distro_command}" ]; then
		    if [ -x "${ROOTFS_DIRECTORY}/usr/bin/login" ]; then
		        distro_command="login \${login_name}"
		    else
		        echo "The command 'login' was not found in guest rootfs."
		        echo "Use '$(basename "${DISTRO_LAUNCHER}") --command[=COMMAND]'."
		        exit 1
		    fi
		fi
		# unset LD_PRELOAD in case termux-exec is installed
		unset LD_PRELOAD

		# Create directory where proot stores all hard link info
		export PROOT_L2S_DIR="${ROOTFS_DIRECTORY}/.l2s"
		if ! [ -d "\${PROOT_L2S_DIR}" ]; then
		    mkdir -p "\${PROOT_L2S_DIR}"
		fi

		# Create fake /root/.version required by some apps i.e LibreOffice
		if [ ! -f "${ROOTFS_DIRECTORY}/root/.version" ]; then
		    mkdir -p "${ROOTFS_DIRECTORY}/root" && touch "${ROOTFS_DIRECTORY}/root/.version"
		fi

		# Launch command
		launch_command="proot"

		# Correct the size returned from lstat for symbolic links
		launch_command+=" -L"
		launch_command+=" --cwd=/root"
		launch_command+=" --rootfs=${ROOTFS_DIRECTORY}"

		# Turn off proot errors
		# launch_command+=" --verbose=-1"

		# Use termux UID/GID
		if \${use_termux_ids}; then
		    launch_command+=" --change-id=\$(id -u):\$(id -g)"
		elif [ -n "\${custom_ids}" ]; then
		    launch_command+=" --change-id=\${custom_ids}"
		else
		    launch_command+=" --root-id"
		fi

		# Fake hard links using symbolic links
		if ! "\${no_link2symlink}"; then
		    launch_command+=" --link2symlink"
		fi

		# Kill all processes on command exit
		if ! "\${no_kill_on_exit}"; then
		    launch_command+=" --kill-on-exit"
		fi

		# Handle System V IPC syscalls in proot
		if ! "\${no_sysvipc}"; then
		    launch_command+=" --sysvipc"
		fi

		# Make current kernel appear as kernel release
		launch_command+=" --kernel-release=\${kernel_release}"

		# Core file systems that should always be present.
		launch_command+=" --bind=/dev"
		launch_command+=" --bind=/dev/urandom:/dev/random"
		launch_command+=" --bind=/proc"
		launch_command+=" --bind=/proc/self/fd:/dev/fd"
		launch_command+=" --bind=/proc/self/fd/0:/dev/stdin"
		launch_command+=" --bind=/proc/self/fd/1:/dev/stdout"
		launch_command+=" --bind=/proc/self/fd/2:/dev/stderr"
		launch_command+=" --bind=/sys"

		# Fake /proc/loadavg if necessary
		if ! cat /proc/loadavg &>/dev/null; then
		    launch_command+=" --bind=${ROOTFS_DIRECTORY}/proc/.loadavg:/proc/loadavg"
		fi

		# Fake /proc/stat if necessary
		if ! cat /proc/stat &>/dev/null; then
		    launch_command+=" --bind=${ROOTFS_DIRECTORY}/proc/.stat:/proc/stat"
		fi

		# Fake /proc/uptime if necessary
		if ! cat /proc/uptime &>/dev/null; then
		    launch_command+=" --bind=${ROOTFS_DIRECTORY}/proc/.uptime:/proc/uptime"
		fi

		# Fake /proc/version if necessary
		if ! cat /proc/version &>/dev/null; then
		    launch_command+=" --bind=${ROOTFS_DIRECTORY}/proc/.version:/proc/version"
		fi

		# Fake /proc/vmstat if necessary
		if ! cat /proc/vmstat &>/dev/null; then
		    launch_command+=" --bind=${ROOTFS_DIRECTORY}/proc/.vmstat:/proc/vmstat"
		fi

		# Fake /proc/sys/kernel/cap_last_cap if necessary
		if ! cat /proc/sys/kernel/cap_last_cap &>/dev/null; then
		    launch_command+=" --bind=${ROOTFS_DIRECTORY}/proc/.sysctl_entry_cap_last_cap:/proc/sys/kernel/cap_last_cap"
		fi

		# Bind /tmp to /dev/shm
		launch_command+=" --bind=${ROOTFS_DIRECTORY}/tmp:/dev/shm"
		if [ ! -d "${ROOTFS_DIRECTORY}/tmp" ]; then
		    mkdir -p "${ROOTFS_DIRECTORY}/tmp"
		fi
		chmod 1777 "${ROOTFS_DIRECTORY}/tmp"

		# Add host system specific variables and directories
		if ! "\${isolated_env}"; then
		    for dir in /apex /data/app /data/dalvik-cache /data/misc/apexdata/com.android.art/dalvik-cache /product /system /vendor; do
		        [ ! -d "\${dir}" ] && continue
		        dir_mode="\$(stat --format='%a' "\${dir}")"
		        if [[ \${dir_mode:2} =~ ^[157]$ ]]; then
		            launch_command+=" --bind=\${dir}"
		        fi
		    done
		    unset dir dir_mode

		    # Required by termux-api Android 11
		    if [ -e "/linkerconfig/ld.config.txt" ]; then
		        launch_command+=" --bind=/linkerconfig/ld.config.txt"
		    fi

		    # Used by getprop
		    if [ -f /property_contexts ]; then
		        launch_command+=" --bind=/property_contexts"
		    fi

		    launch_command+=" --bind=/data/data/com.termux/cache"
		    launch_command+=" --bind=${TERMUX_FILES_DIR}/home"
		    launch_command+=" --bind=${TERMUX_FILES_DIR}/usr"

		    if [ -d "${TERMUX_FILES_DIR}/apps" ]; then
		        launch_command+=" --bind=${TERMUX_FILES_DIR}/apps"
		    fi
		    if ls -U /storage &>/dev/null; then
		        launch_command+=" --bind=/storage"
		        launch_command+=" --bind=/storage/emulated/0:/sdcard"
		    else
		        if ls -U /storage/self/primary/ &>/dev/null; then
		            storage_path="/storage/self/primary"
		        elif ls -U /storage/emulated/0/ &>/dev/null; then
		            storage_path="/storage/emulated/0"
		        elif ls -U /sdcard/ &>/dev/null; then
		            storage_path="/sdcard"
		        else
		            storage_path=""
		        fi
		        if [ -n "\${storage_path}" ]; then
		            launch_command+=" --bind=\${storage_path}:/sdcard"
		            launch_command+=" --bind=\${storage_path}:/storage/emulated/0"
		            launch_command+=" --bind=\${storage_path}:/storage/self/primary"
		        fi
		        unset storage_path
		    fi
		fi

		# Bind the tmp folder of the host system to the guest system (ignores --isolated)
		if \${share_tmp_dir}; then
		    launch_command+=" --bind=\${TMPDIR-${TERMUX_FILES_DIR}/usr/tmp}:/tmp"
		fi

		# Bind custom directories
		launch_command+="\${custom_bindings}"

		# Modify bindings to protected ports to use a higher port number.
		if \${protect_ports}; then
		    launch_command+=" -p"
		fi

		# Setup the default environment
		launch_command+=" /usr/bin/env -i HOME=/root LANG=C.UTF-8 TERM=\${TERM-xterm-256color} PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/games:/usr/local/bin:/usr/local/sbin:/usr/local/games:/system/bin:/system/xbin"

		# Enable audio support in distro (for root users, add option '--system')
		pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1

		# Execute launch command (exec replaces current shell)
		exec \${launch_command} \${distro_command}
	EOF
	if ln -sfT "${DISTRO_LAUNCHER}" "${DISTRO_SHORTCUT}" &>>"${LOG_FILE}" && termux-fix-shebang "${DISTRO_LAUNCHER}" && chmod 700 "${DISTRO_LAUNCHER}"; then
		msg -s "Command created successfully."
	else
		msg -qm0 "Unfortunately, I can't create the ${DISTRO_NAME} launcher."
	fi
}

################################################################################
# Creates a script used to launch the vnc server in the distro                 #
################################################################################
create_vnc_launcher() {
	msg -t "Lemme create a command to launch VNC in ${DISTRO_NAME}."
	local vnc_launcher="${ROOTFS_DIRECTORY}/usr/local/bin/vnc"
	mkdir -p "${ROOTFS_DIRECTORY}/usr/local/bin" && cat >"${vnc_launcher}" <<-EOF
		#!/bin/bash -e

		################################################################################
		#                                                                              #
		#     VNC launcher, version ${VERSION}                                             #
		#                                                                              #
		#     This script starts the VNC server.                                       #
		#                                                                              #
		#     Copyright (C) 2023  ${AUTHOR} <${GITHUB}>             #
		#                                                                              #
		################################################################################

		root_check() {
		    if [ "\${EUID}" = "0" ] || [ "\$(whoami)" = "root" ]; then
		        echo "Some applications are not meant to be run as root and may not work properly."
		        read -rep "Continue anyway? (y/N) " -n 1 reply
		        case "\${reply}" in
		        y | Y) return ;;
		        esac
		        echo "Abort."
		        exit 1
		    fi
		}

		clean_tmp() {
		    rm -rf "/tmp/.X\${DISPLAY_VALUE}-lock" "/tmp/.X11-unix/X\${DISPLAY_VALUE}"
		}

		set_geometry() {
		    case "\${ORIENTATION_STYLE}" in
		    "potrait")
		        geometry="\${WIDTH_VALUE}x\${HEIGHT_VALUE}"
		        ;;
		    *)
		        geometry="\${HEIGHT_VALUE}x\${WIDTH_VALUE}"
		        ;;
		    esac
		}

		set_passwd() {
		    if [ -x "\$(command -v vncpasswd)" ]; then
		        vncpasswd
		    else
		        echo "No VNC server found."
		        return 1
		    fi
		}

		start_server() {
		    if [ -x "\$(command -v vncserver)" ]; then
		        if [ -f "\${HOME}/.vnc/passwd" ] && [ -r "\${HOME}/.vnc/passwd" ]; then
		            export HOME="\${HOME-/root}"
		            export USER="\${USER-root}"
		            LD_PRELOAD="${LIB_GCC_PATH}"
		            # nohup \\
		            vncserver ":\${DISPLAY_VALUE}" -geometry "\${geometry}" -depth "\${DEPTH_VALUE}" "\${@}" && echo "VNC server started successfully."
		        else
		            set_passwd && start_server
		        fi
		    else
		        echo "No VNC server found."
		    fi
		}

		kill_server() {
		    if [ -x "\$(command -v vncserver)" ]; then
		        vncserver -clean -kill ":\${DISPLAY_VALUE}" && clean_tmp
		        return \${?}
		    else
		        echo "No VNC server found."
		    fi
		}

		print_usage() {
		    echo "Usage \$(basename "\${0}") [option]..."
		    echo ""
		    echo "Start the VNC server."
		    echo ""
		    echo "Options:"
		    echo "   -p, --potrait"
		    echo "         Use potrait (\${WIDTH_VALUE}x\${HEIGHT_VALUE}) orientation."
		    echo "   -l, --landscape"
		    echo "         Use landscape (\${HEIGHT_VALUE}x\${WIDTH_VALUE}) orientation. (default)"
		    echo "   --password"
		    echo "         Set or change the VNC password."
		    echo "   -k, --kill"
		    echo "         Kill the vncserver."
		    echo "   -h, --help"
		    echo "          Print this message and exit."
		    echo ""
		    echo "Extra options are parsed to the installed VNC server."
		}

		#############
		# Entry point
		#############

		DEPTH_VALUE=24
		WIDTH_VALUE=720
		HEIGHT_VALUE=1600
		ORIENTATION_STYLE="landscape"
		DISPLAY_VALUE="\$(cut -d: -f2 <<< "\${DISPLAY}")"

		extra_opts=()
		while [ "\${#}" -gt 0 ]; do
		    case "\${1}" in
		    -p | --potrait)
		        ORIENTATION_STYLE=potrait
		        ;;
		    -l | --landscape)
		        ORIENTATION_STYLE=landscape
		        ;;
		    --password)
		        set_passwd
		        exit
		        ;;
		    -k | --kill)
		        kill_server
		        exit
		        ;;
		    -h | --help)
		        print_usage
		        exit 0
		        ;;
		    *) extra_opts=("\${extra_opts[@]}" "\${1}") ;;
		    esac
		    shift
		done
		set -- "\${extra_opts[@]}"
		unset extra_opts

		# Start VNC server
		root_check && clean_tmp && set_geometry && start_server "\${@}"
	EOF
	if chmod 700 "${vnc_launcher}"; then
		msg -s "Command created successfully."
	else
		msg -e "Unfortunately, I can't create the VNC launcher."
	fi
}

################################################################################
# Makes all the required configurations in the distro                          #
################################################################################
make_configurations() {
	msg -t "Now let me make some configurations for you."
	for config in fake_proc_setup android_ids_setup settings_configurations environment_variables_setup; do
		status="$(${config} 2>"${LOG_FILE}")"
		if ! [ -z "${status//-0/}" ]; then
			msg -e "Oops, ${config//_/ } failed with error code: (${status})"
		fi
	done
	msg -s "Yup, that should fix some startup issues."
	unset config status
	set_user_shell
	set_zone_info
}

################################################################################
# Makes the necessary clean ups                                                #
################################################################################
clean_up() {
	if [ -z "${KEEP_ROOTFS_DIRECTORY}" ] && [ -z "${KEEP_ROOTFS_ARCHIVE}" ] && [ -f "${ARCHIVE_NAME}" ]; then
		if ask -n -- -t "Should I remove the downloaded the rootfs archive to save space?"; then
			msg -e "Okay, removing '${ARCHIVE_NAME}'"
			if rm -rf "${ARCHIVE_NAME}"; then
				msg -s "Done! The rootfs archive is gone."
			else
				msg -e "Unfortunately, I can't remove the rootfs archive."
			fi
		else
			msg "Alright, lemme leave the rootfs archive."
		fi
	fi
}

################################################################################
# Prints a message for successful installation with other useful information   #
################################################################################
complete_msg() {
	msg -st "That's it! We have successfuly installed ${DISTRO_NAME}."
	msg "You can launch it by executing:"
	msg "'${Y}$(basename "${DISTRO_LAUNCHER}") root${C}' to login as root user."
	msg "or"
	msg "'${Y}$(basename "${DISTRO_LAUNCHER}") kali${C}' to login as a normal user."
	msg -t "I also figured you might need a short form for '${Y}$(basename "${DISTRO_LAUNCHER}")${C}'."
	msg "In that case, I created '${Y}$(basename "${DISTRO_SHORTCUT}")${C}' that does the same thing."
	msg -t "If you have further inquiries, read the documentation at:"
	msg "${U}${GITHUB}/${REPOSITORY}${L}"
	if ${ACTION_INSTALL} && [ -n "${SELECTED_INSTALLATION}" ] && [ "${SELECTED_INSTALLATION}" != "full" ]; then
		msg -te "Remember, this is a ${SELECTED_INSTALLATION} installation of ${DISTRO_NAME}."
		msg "If you need to install additional packages, read the docs for a detailed guide."
	fi
}

################################################################################
# Uninstalls the rootfs                                                        #
################################################################################
uninstall_rootfs() {
	if [ -d "${ROOTFS_DIRECTORY}" ] && [ -n "$(ls -AU "${ROOTFS_DIRECTORY}")" ]; then
		msg -ate "You are about to uninstall ${DISTRO_NAME} from '${ROOTFS_DIRECTORY}'."
		if ask -n0 -- -a "Confirm action."; then
			msg -a "Uninstalling ${DISTRO_NAME}, just a sec..."
			if rm -rf "${ROOTFS_DIRECTORY}"; then
				msg -as "Done! ${DISTRO_NAME} uninstalled successfully."
				msg -a "Removing commands."
				if rm -rf "${DISTRO_LAUNCHER}" "${DISTRO_SHORTCUT}"; then
					msg -as "Commands removed successfully."
				else
					msg -ae "Unfortunately, I can't remove the commnds."
				fi
			else
				msg -aqm0 "Unfortunately, I can't uninstall ${DISTRO_NAME}."
			fi
		else
			msg -a "Uninstallation aborted."
		fi
	else
		msg -a "No rootfs found in '${ROOTFS_DIRECTORY}'."
	fi
}

################################################################################
# Prints the program version information                                       #
################################################################################
print_version() {
	msg -a "${DISTRO_NAME} installer, version ${VERSION}."
	msg -a "Copyright (C) 2023 ${AUTHOR} <${U}${GITHUB}${L}>."
	msg -a "License GPLv3+: GNU GPL version 3 or later <${U}http://gnu.org/licenses/gpl.html${L}>."
	msg -aN "This is free software, you are free to change and redistribute it."
	msg -a "There is NO WARRANTY, to the extent permitted by law."
}

################################################################################
# Prints the program usage information                                       #
################################################################################
print_usage() {
	msg -a "Usage: ${NAME} [OPTION]... [DIR]"
	msg -aN "Install ${DISTRO_NAME} in directory DIR."
	msg -a "(default='${DEFAULT_ROOTFS_DIR}')"
	msg -aN "Options:"
	msg -- "--cd[=DIR]"
	msg "        Change to directory DIR before execution."
	msg -- "--no-install"
	msg "        Skip the installation steps."
	msg -- "--no-configs"
	msg "        Skip the configuration steps."
	msg -- "--uninstall"
	msg "        Uninstall ${DISTRO_NAME}."
	msg -- "-h, --help"
	msg "        Print this information and exit."
	msg -- "-v, --version"
	msg "        Print program/distro version and exit."
	msg -- "--color[=ARG]"
	msg "        Enable/Disable color output. (default='on' if supported)"
	msg "        Valid arguments are: [on|yes|auto] or [off|no|none]"
	msg -aN "Installation directory DIR must be within ${TERMUX_FILES_DIR}"
	msg -a "(or its sub-folders) to prevent permission issues."
	msg -aN "Documentation: ${U}${GITHUB}/${REPOSITORY}${L}"
}

################################################################################
# Prepares fake content for certain /proc entries                              #
# Entries are based on values retrieved from Arch Linux (x86_64) running a VM  #
# with 8 CPUs and 8GiB memory (some values edited to fit the distro)           #
# Date: 2023.03.28, Linux 6.2.1                                                #
################################################################################
fake_proc_setup() {
	local status=""
	mkdir -p "${ROOTFS_DIRECTORY}/proc"
	chmod 700 "${ROOTFS_DIRECTORY}/proc"
	if [ ! -f "${ROOTFS_DIRECTORY}/proc/.loadavg" ]; then
		cat <<-EOF >"${ROOTFS_DIRECTORY}/proc/.loadavg"
			0.12 0.07 0.02 2/165 765
		EOF
	fi
	status+="-${?}"
	if [ ! -f "${ROOTFS_DIRECTORY}/proc/.stat" ]; then
		cat <<-EOF >"${ROOTFS_DIRECTORY}/proc/.stat"
			cpu  1957 0 2877 93280 262 342 254 87 0 0
			cpu0 31 0 226 12027 82 10 4 9 0 0
			cpu1 45 0 664 11144 21 263 233 12 0 0
			cpu2 494 0 537 11283 27 10 3 8 0 0
			cpu3 359 0 234 11723 24 26 5 7 0 0
			cpu4 295 0 268 11772 10 12 2 12 0 0
			cpu5 270 0 251 11833 15 3 1 10 0 0
			cpu6 430 0 520 11386 30 8 1 12 0 0
			cpu7 30 0 172 12108 50 8 1 13 0 0
			intr 127541 38 290 0 0 0 0 4 0 1 0 0 25329 258 0 5777 277 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
			ctxt 140223
			btime 1680020856
			processes 772
			procs_running 2
			procs_blocked 0
			softirq 75663 0 5903 6 25375 10774 0 243 11685 0 21677
		EOF
	fi
	status+="-${?}"
	if [ ! -f "${ROOTFS_DIRECTORY}/proc/.uptime" ]; then
		cat <<-EOF >"${ROOTFS_DIRECTORY}/proc/.uptime"
			124.08 932.80
		EOF
	fi
	status+="-${?}"
	if [ ! -f "${ROOTFS_DIRECTORY}/proc/.version" ]; then
		cat <<-EOF >"${ROOTFS_DIRECTORY}/proc/.version"
			Linux version ${KERNEL_RELEASE} (proot@termux) (gcc (GCC) 12.2.1 20230201, GNU ld (GNU Binutils) 2.40) #1 SMP PREEMPT_DYNAMIC Wed, 01 Mar 2023 00:00:00 +0000
		EOF
	fi
	status+="-${?}"
	if [ ! -f "${ROOTFS_DIRECTORY}/proc/.vmstat" ]; then
		cat <<-EOF >"${ROOTFS_DIRECTORY}/proc/.vmstat"
			nr_free_pages 1743136
			nr_zone_inactive_anon 179281
			nr_zone_active_anon 7183
			nr_zone_inactive_file 22858
			nr_zone_active_file 51328
			nr_zone_unevictable 642
			nr_zone_write_pending 0
			nr_mlock 0
			nr_bounce 0
			nr_zspages 0
			nr_free_cma 0
			numa_hit 1259626
			numa_miss 0
			numa_foreign 0
			numa_interleave 720
			numa_local 1259626
			numa_other 0
			nr_inactive_anon 179281
			nr_active_anon 7183
			nr_inactive_file 22858
			nr_active_file 51328
			nr_unevictable 642
			nr_slab_reclaimable 8091
			nr_slab_unreclaimable 7804
			nr_isolated_anon 0
			nr_isolated_file 0
			workingset_nodes 0
			workingset_refault_anon 0
			workingset_refault_file 0
			workingset_activate_anon 0
			workingset_activate_file 0
			workingset_restore_anon 0
			workingset_restore_file 0
			workingset_nodereclaim 0
			nr_anon_pages 7723
			nr_mapped 8905
			nr_file_pages 253569
			nr_dirty 0
			nr_writeback 0
			nr_writeback_temp 0
			nr_shmem 178741
			nr_shmem_hugepages 0
			nr_shmem_pmdmapped 0
			nr_file_hugepages 0
			nr_file_pmdmapped 0
			nr_anon_transparent_hugepages 1
			nr_vmscan_write 0
			nr_vmscan_immediate_reclaim 0
			nr_dirtied 0
			nr_written 0
			nr_throttled_written 0
			nr_kernel_misc_reclaimable 0
			nr_foll_pin_acquired 0
			nr_foll_pin_released 0
			nr_kernel_stack 2780
			nr_page_table_pages 344
			nr_sec_page_table_pages 0
			nr_swapcached 0
			pgpromote_success 0
			pgpromote_candidate 0
			nr_dirty_threshold 356564
			nr_dirty_background_threshold 178064
			pgpgin 890508
			pgpgout 0
			pswpin 0
			pswpout 0
			pgalloc_dma 272
			pgalloc_dma32 261
			pgalloc_normal 1328079
			pgalloc_movable 0
			pgalloc_device 0
			allocstall_dma 0
			allocstall_dma32 0
			allocstall_normal 0
			allocstall_movable 0
			allocstall_device 0
			pgskip_dma 0
			pgskip_dma32 0
			pgskip_normal 0
			pgskip_movable 0
			pgskip_device 0
			pgfree 3077011
			pgactivate 0
			pgdeactivate 0
			pglazyfree 0
			pgfault 176973
			pgmajfault 488
			pglazyfreed 0
			pgrefill 0
			pgreuse 19230
			pgsteal_kswapd 0
			pgsteal_direct 0
			pgsteal_khugepaged 0
			pgdemote_kswapd 0
			pgdemote_direct 0
			pgdemote_khugepaged 0
			pgscan_kswapd 0
			pgscan_direct 0
			pgscan_khugepaged 0
			pgscan_direct_throttle 0
			pgscan_anon 0
			pgscan_file 0
			pgsteal_anon 0
			pgsteal_file 0
			zone_reclaim_failed 0
			pginodesteal 0
			slabs_scanned 0
			kswapd_inodesteal 0
			kswapd_low_wmark_hit_quickly 0
			kswapd_high_wmark_hit_quickly 0
			pageoutrun 0
			pgrotated 0
			drop_pagecache 0
			drop_slab 0
			oom_kill 0
			numa_pte_updates 0
			numa_huge_pte_updates 0
			numa_hint_faults 0
			numa_hint_faults_local 0
			numa_pages_migrated 0
			pgmigrate_success 0
			pgmigrate_fail 0
			thp_migration_success 0
			thp_migration_fail 0
			thp_migration_split 0
			compact_migrate_scanned 0
			compact_free_scanned 0
			compact_isolated 0
			compact_stall 0
			compact_fail 0
			compact_success 0
			compact_daemon_wake 0
			compact_daemon_migrate_scanned 0
			compact_daemon_free_scanned 0
			htlb_buddy_alloc_success 0
			htlb_buddy_alloc_fail 0
			cma_alloc_success 0
			cma_alloc_fail 0
			unevictable_pgs_culled 27002
			unevictable_pgs_scanned 0
			unevictable_pgs_rescued 744
			unevictable_pgs_mlocked 744
			unevictable_pgs_munlocked 744
			unevictable_pgs_cleared 0
			unevictable_pgs_stranded 0
			thp_fault_alloc 13
			thp_fault_fallback 0
			thp_fault_fallback_charge 0
			thp_collapse_alloc 4
			thp_collapse_alloc_failed 0
			thp_file_alloc 0
			thp_file_fallback 0
			thp_file_fallback_charge 0
			thp_file_mapped 0
			thp_split_page 0
			thp_split_page_failed 0
			thp_deferred_split_page 1
			thp_split_pmd 1
			thp_scan_exceed_none_pte 0
			thp_scan_exceed_swap_pte 0
			thp_scan_exceed_share_pte 0
			thp_split_pud 0
			thp_zero_page_alloc 0
			thp_zero_page_alloc_failed 0
			thp_swpout 0
			thp_swpout_fallback 0
			balloon_inflate 0
			balloon_deflate 0
			balloon_migrate 0
			swap_ra 0
			swap_ra_hit 0
			ksm_swpin_copy 0
			cow_ksm 0
			zswpin 0
			zswpout 0
			direct_map_level2_splits 29
			direct_map_level3_splits 0
			nr_unstable 0
		EOF
	fi
	status+="-${?}"
	if [ ! -f "${ROOTFS_DIRECTORY}/proc/.sysctl_entry_cap_last_cap" ]; then
		cat <<-EOF >"${ROOTFS_DIRECTORY}/proc/.sysctl_entry_cap_last_cap"
			40
		EOF
	fi
	status+="-${?}"
	echo -n "${status}"
}

################################################################################
# Creates a srcript in /etc/profile.d containing the required environment      #
# variables in the distro                                                      #
################################################################################
environment_variables_setup() {
	local status=""
	local profile_script="${ROOTFS_DIRECTORY}/etc/profile.d/setvars.sh"
	mkdir -p "${ROOTFS_DIRECTORY}/etc/profile.d/"
	cat /dev/null >"${profile_script}"
	cat >>"${profile_script}" <<-EOF
		# Environment variables
		export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/games:/usr/local/bin:/usr/local/sbin:/usr/local/games:/system/bin:/system/xbin:${TERMUX_FILES_DIR}/usr/bin"
		export TERM="${TERM-xterm-256color}"
		if [ -z "\${LANG}" ]; then
		    export LANG="C.UTF-8"
		fi

		# pulseaudio server
		export PULSE_SERVER=127.0.0.1

		# Display (for VNC)
		if [ "\${EUID}" -eq 0 ] || [ "\$(id -u)" -eq 0 ] || [ "\$(whoami)" = "root" ]; then
		    export DISPLAY=:0
		else
		    export DISPLAY=:1
		fi

		# Misc variables
		export MOZ_FAKE_NO_SANDBOX=1
		export TMPDIR="/tmp"
	EOF
	status+="-${?}"
	local java_home
	if [[ ${SYS_ARCH} == "armhf" ]]; then
		java_home="/usr/lib/jvm/java-*-openjdk-armhf"
	else
		java_home="/usr/lib/jvm/java-*-openjdk-aarch64"
	fi
	cat >>"${profile_script}" <<-EOF

		# JDK variables
		export JAVA_HOME="${java_home}"
		export PATH="\${PATH}:\${JAVA_HOME}/bin"
	EOF
	status+="-${?}"
	echo -e "\n# Host system variables" >>"${profile_script}"
	for var in COLORTERM ANDROID_DATA ANDROID_ROOT ANDROID_ART_ROOT ANDROID_I18N_ROOT ANDROID_RUNTIME_ROOT ANDROID_TZDATA_ROOT BOOTCLASSPATH DEX2OATBOOTCLASSPATH; do
		if [ -n "${!var}" ]; then
			echo "export ${var}=\"${!var}\"" >>"${profile_script}"
		fi
	done
	unset var
	status+="-${?}"
	echo -n "${status}"
}

################################################################################
# Adds android-specific UIDs/GIDs to /etc/group and /etc/gshadow               #
################################################################################
android_ids_setup() {
	local status=""
	chmod u+rw "${ROOTFS_DIRECTORY}/etc/passwd" "${ROOTFS_DIRECTORY}/etc/shadow" "${ROOTFS_DIRECTORY}/etc/group" "${ROOTFS_DIRECTORY}/etc/gshadow" &>>"${LOG_FILE}"
	status+="-${?}"
	if ! grep -qe ':Termux:/:/sbin/nologin' "${ROOTFS_DIRECTORY}/etc/passwd"; then
		echo "aid_$(id -un):x:$(id -u):$(id -g):Termux:/:/sbin/nologin" >>"${ROOTFS_DIRECTORY}/etc/passwd"
	fi
	status+="-${?}"
	if ! grep -qe ':18446:0:99999:7:' "${ROOTFS_DIRECTORY}/etc/shadow"; then
		echo "aid_$(id -un):*:18446:0:99999:7:::" >>"${ROOTFS_DIRECTORY}/etc/shadow"
	fi
	status+="-${?}"
	while read -r group_name group_id; do
		if ! grep -qe "${group_name}" "${ROOTFS_DIRECTORY}/etc/group"; then
			echo "aid_${group_name}:x:${group_id}:root,aid_$(id -un)" >>"${ROOTFS_DIRECTORY}/etc/group"
		fi
		if ! grep -qe "${group_name}" "${ROOTFS_DIRECTORY}/etc/gshadow"; then
			echo "aid_${group_name}:*::root,aid_$(id -un)" >>"${ROOTFS_DIRECTORY}/etc/gshadow"
		fi
	done < <(paste <(id -Gn | tr ' ' '\n') <(id -G | tr ' ' '\n'))
	unset group_name group_id
	status+="-${?}"
	echo -n "${status}"
}

################################################################################
# Configures root access, sets the nameservers and sets host information       #
################################################################################
settings_configurations() {
	local status=""
	if [ -f "${ROOTFS_DIRECTORY}/root/.bash_profile" ]; then
		sed -i '/^if/,/^fi/d' "${ROOTFS_DIRECTORY}/root/.bash_profile"
	fi
	status+="-${?}"
	if [ -x "${ROOTFS_DIRECTORY}/usr/bin/passwd" ]; then
		distro_exec "/usr/bin/passwd" -d root
		distro_exec "/usr/bin/passwd" -d kali
	fi &>>"${LOG_FILE}"
	status+="-${?}"
	local dir="${ROOTFS_DIRECTORY}/usr/bin"
	if [ -x "${dir}/sudo" ]; then
		chmod +s "${dir}/sudo"
		echo "kali   ALL=(ALL:ALL) NOPASSWD: ALL" >"${ROOTFS_DIRECTORY}/etc/sudoers.d/kali"
		echo "Set disable_coredump false" >"${ROOTFS_DIRECTORY}/etc/sudo.conf"
	fi
	if [ -x "${dir}/su" ]; then
		chmod +s "${dir}/su"
	fi
	status+="-${?}"
	local resol_conf="${ROOTFS_DIRECTORY}/etc/resolv.conf"
	if touch "${resol_conf}" && chmod +w "${resol_conf}"; then
		cat >"${resol_conf}" <<-EOF
			nameserver 8.8.8.8
			nameserver 8.8.4.4
		EOF
	fi
	status+="-${?}"
	cat >"${ROOTFS_DIRECTORY}/etc/hosts" <<-EOF
		# IPv4
		127.0.0.1   localhost.localdomain localhost

		# IPv6
		::1         localhost.localdomain localhost ip6-localhost ip6-loopback
		fe00::0     ip6-localnet
		ff00::0     ip6-mcastprefix
		ff02::1     ip6-allnodes
		ff02::2     ip6-allrouters
		ff02::3     ip6-allhosts
	EOF
	status+="-${?}"
	echo -n "${status}"
}

################################################################################
# Sets a custom login shell in distro                                          #
################################################################################
set_user_shell() {
	if [ -x "${ROOTFS_DIRECTORY}/usr/bin/chsh" ] && { if [ -z "${shell}" ]; then ask -n -- -t "Should I change the default login shell?"; fi; }; then
		local shells=("bash" "zsh" "fish" "dash" "tcsh" "csh" "ksh")
		msg "Available shells: ${shells[*]}"
		msg -n "Enter shell name:"
		read -rep " " -i "${shells[0]}" shell
		if [[ ${shells[*]} == *"${shell}"* ]] && [ -x "${ROOTFS_DIRECTORY}/usr/bin/${shell}" ] && distro_exec /usr/bin/chsh -s "/usr/bin/${shell}" kali && distro_exec /usr/bin/chsh -s "/usr/bin/${shell}" root; then
			msg -s "The default login shell is now '${shell}'."
		else
			msg -e "Unfortunately, I can't set the default login shell."
			ask -n -- " Should I try again?" && set_user_shell
		fi
		unset shell
	fi
}

################################################################################
# Sets a custom time zone in distro                                            #
################################################################################
set_zone_info() {
	if [ -x "${ROOTFS_DIRECTORY}/usr/bin/ln" ] && { if [ -z "${zone}" ]; then ask -n -- -t "Should I change the default time zone?"; fi; }; then
		msg -n "Enter time zone (format='Country/City'):"
		read -rep " " -i "America/New_York" zone
		if [ -f "${ROOTFS_DIRECTORY}/usr/share/zoneinfo/${zone}" ] && echo "${zone}" >"${ROOTFS_DIRECTORY}/etc/timezone" && distro_exec /usr/bin/ln -fs -T "/usr/share/zoneinfo/${zone}" /etc/localtime; then
			msg -s "The default time zone is now '${zone}'."
		else
			msg -e "Unfortunately, I can't set the default time zone."
			ask -n -- " Should I try again?" && set_zone_info
		fi
		unset zone
	fi
}

################################################################################
# Executes a command in the distro.                                            #
################################################################################
distro_exec() {
	unset LD_PRELOAD
	proot -L \
		--cwd=/ \
		--root-id \
		--bind=/dev \
		--bind="/dev/urandom:/dev/random" \
		--bind=/proc \
		--bind="/proc/self/fd:/dev/fd" \
		--bind="/proc/self/fd/0:/dev/stdin" \
		--bind="/proc/self/fd/1:/dev/stdout" \
		--bind="/proc/self/fd/2:/dev/stderr" \
		--bind=/sys \
		--bind="${ROOTFS_DIRECTORY}/proc/.loadavg:/proc/loadavg" \
		--bind="${ROOTFS_DIRECTORY}/proc/.stat:/proc/stat" \
		--bind="${ROOTFS_DIRECTORY}/proc/.uptime:/proc/uptime" \
		--bind="${ROOTFS_DIRECTORY}/proc/.version:/proc/version" \
		--bind="${ROOTFS_DIRECTORY}/proc/.vmstat:/proc/vmstat" \
		--bind="${ROOTFS_DIRECTORY}/proc/.sysctl_entry_cap_last_cap:/proc/sys/kernel/cap_last_cap" \
		--kernel-release="${KERNEL_RELEASE}" \
		--rootfs="${ROOTFS_DIRECTORY}" \
		--link2symlink \
		--kill-on-exit \
		/usr/bin/env -i \
		"HOME=/root" \
		"LANG=C.UTF-8" \
		"PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
		"TERM=${TERM-xterm-256color}" \
		"TMPDIR=/tmp" \
		"${@}"
}

################################################################################
# Initializes the color variables                                              #
################################################################################
colors() {
	if [ -x "$(command -v tput)" ] && [ "$(tput colors)" -ge 8 ] && [[ ${COLOR_SUPPORT} =~ "on"|"yes"|"auto" ]]; then
		R="$(echo -e "sgr0\nbold\nsetaf 1" | tput -S)"
		G="$(echo -e "sgr0\nbold\nsetaf 2" | tput -S)"
		Y="$(echo -e "sgr0\nbold\nsetaf 3" | tput -S)"
		C="$(echo -e "sgr0\nbold\nsetaf 6" | tput -S)"
		I="$(tput civis)" # hide cursor
		V="$(tput cvvis)" # show cursor
		U="$(tput smul)"  # underline
		L="$(tput rmul)"  # remove underline
		N="$(tput sgr0)"  # remove color
	else
		R=""
		G=""
		Y=""
		C=""
		I=""
		V=""
		U=""
		L=""
		N=""
	fi
}

################################################################################
# Prints parsed message to the standard output. All messages MUST be printed   #
# with this function                                                           #
# Allows options (see case inside)                                             #
################################################################################
msg() {
	local color="${C}"
	local prefix="   "
	local postfix=""
	local quit=false
	local append=false
	local extra_msg=""
	local list_items=false
	local lead_newline=false
	local trail_newline=true
	while getopts ":tseanNqm:l" opt; do
		case "${opt}" in
			t)
				prefix="\n ${Y}✔ "
				continue
				;;
			s)
				color="${G}"
				continue
				;;
			e)
				color="${R}"
				continue
				;;
			a)
				append=true
				continue
				;;
			n)
				trail_newline=false
				continue
				;;
			N)
				lead_newline=true
				continue
				;;
			q)
				color="${R}"
				quit=true
				continue
				;;
			m)
				local msgs=(
					"Try running this script again"
					"An active internet connection is required"
					"Try '${NAME} --help' for more information")
				extra_msg="${C}${msgs[${OPTARG}]}${N}"
				continue
				;;
			l)
				list_items=true
				color="${G}"
				continue
				;;
			*) ;;
		esac
	done
	shift $((OPTIND - 1))
	unset OPTARG OPTIND opt
	if ${list_items}; then
		local i=1
		for item in "${@}"; do
			echo -ne "\r${prefix}    ${color}<${Y}${i}${color}> ${item}${postfix}${N}\n"
			((i++))
		done
		unset item
	else
		local args
		local message="${*}"
		if [ -z "${message}" ] && [ -n "${extra_msg}" ]; then
			message="${extra_msg}"
			extra_msg=""
		fi
		while true; do
			args=""
			${lead_newline} && args+="\n"
			${append} || args+="\r${prefix}"
			args+="${color}${message}${postfix}${N}"
			${trail_newline} && args+="\n"
			echo -ne "${args}"
			if [ -n "${extra_msg}" ]; then
				message="${extra_msg}"
				extra_msg=""
			else
				break
			fi
		done
	fi
	if ${quit}; then
		exit 1
	fi
}

################################################################################
# Asks the user a Y/N question and returns 0/1 respectively                    #
# Allows options (see case inside)                                             #
# Options after -- are parsed to msg (see msg description)                     #
################################################################################
ask() {
	local prompt
	local default
	local retries=1
	while getopts ":yn0123456789" opt; do
		case "${opt}" in
			y)
				prompt="Y/n"
				default="Y"
				continue
				;;
			n)
				prompt="y/N"
				default="N"
				continue
				;;
			[0-9])
				retries=${opt}
				continue
				;;
			*)
				prompt="y/n"
				default=""
				;;
		esac
	done
	shift $((OPTIND - 1))
	unset OPTARG OPTIND opt
	while true; do
		msg -n "${@}" "(${prompt}): "
		read -ren 1 reply
		if [ -z "${reply}" ]; then
			reply="${default}"
		fi
		case "${reply}" in
			Y | y) return 0 ;;
			N | n) return 1 ;;
		esac
		if [ -n "${default}" ] && [ "${retries}" -eq 0 ]; then
			case "${default}" in
				y | Y) return 0 ;;
				n | N) return 1 ;;
			esac
		fi
		((retries--))
	done
	unset reply
}

################################################################################
# Entry point of program                                                       #
################################################################################

# Name of the distro
DISTRO_NAME="Kali NetHunter"

# Termux directory
TERMUX_FILES_DIR="/data/data/com.termux/files"

# Disro launcher files
DISTRO_SHORTCUT="${TERMUX_FILES_DIR}/usr/bin/nh"
DISTRO_LAUNCHER="${TERMUX_FILES_DIR}/usr/bin/nethunter"

# Base url of rootfs archive
BASE_URL="https://kali.download/nethunter-images/kali-${VERSION}/rootfs"

# Fake host system kernel
KERNEL_RELEASE="6.2.1-nethunter-proot"

# Default installation directory
DEFAULT_ROOTFS_DIR="${TERMUX_FILES_DIR}/kali"

# Output for unwanted messages
LOG_FILE="/dev/null" # "${NAME}.log"

# Enable color by default
COLOR_SUPPORT=on

# Update color variables
colors

# Main actions
ACTION_INSTALL=true
ACTION_CONFIGURE=true
ACTION_UNINSTALL=false

ARGS=()
while [ "${#}" -gt 0 ]; do
	case "${1}" in
		--cd*)
			optarg="${1//--cd/}"
			optarg="${optarg//=/}"
			if [ -z "${optarg}" ]; then
				shift 1
				optarg="${1-}"
			fi
			if [ -z "${optarg}" ]; then
				msg -aqm2 "Option '--cd' requires an argument."
			fi
			if [ -d "${optarg}" ] && [ -r "${optarg}" ]; then
				cd "${optarg}"
			else
				msg -aq "Invalid directory path '${optarg}'."
			fi
			unset optarg
			;;
		--no-install) ACTION_INSTALL=false ;;
		--no-configs) ACTION_CONFIGURE=false ;;
		--uninstall) ACTION_UNINSTALL=true ;;
		-v | --version)
			print_version
			exit 0
			;;
		-h | --help)
			print_usage
			exit 0
			;;
		--color*)
			optarg="${1//--color/}"
			optarg="${optarg//=/}"
			if [ -z "${optarg}" ]; then
				shift 1
				optarg="${1-}"
			fi
			case "${optarg}" in
				on | yes | auto | off | no | never)
					COLOR_SUPPORT="${optarg}"
					colors
					;;
				"") msg -aqm2 "Option '--color' requires an argument." ;;
				*)
					msg -ae "Unrecognized argument '${optarg}' for '--color'."
					msg -a "Valid arguments are:"
					msg "'on'  | 'yes' | 'auto'"
					msg "'off' | 'no'  | 'none'"
					msg -aqm2
					;;
			esac
			unset optarg
			;;
		-*) msg -aqm2 "Unrecognized option '${1}'." ;;
		*) ARGS=("${ARGS[@]}" "${1}") ;;
	esac
	shift 1
done
set -- "${ARGS[@]}"
unset ARGS

# Prevent extra arguments
if [ "${#}" -gt 1 ]; then
	msg -aqm2 "Too many arguments."
fi

# Set the rootfs directory
if [ -n "${1}" ]; then
	ROOTFS_DIRECTORY="$(realpath "${1}")"
	if [[ "${ROOTFS_DIRECTORY}" != "${TERMUX_FILES_DIR}"* ]]; then
		msg -aqm2 "The supplied directory '${ROOTFS_DIRECTORY}' is not within '${TERMUX_FILES_DIR}'."
	fi
else
	ROOTFS_DIRECTORY="${DEFAULT_ROOTFS_DIR}"
fi

# Uninstall rootfs
if ${ACTION_UNINSTALL}; then
	uninstall_rootfs
	exit 0
fi

# Pre install actions
if ${ACTION_INSTALL} || ${ACTION_CONFIGURE}; then
	root_check
	print_intro
	check_arch
	check_pkgs
	msg -t "I shall now install ${DISTRO_NAME} in '${ROOTFS_DIRECTORY}'."
fi

# Install actions
if ${ACTION_INSTALL}; then
	check_rootfs_directory
	[ -z "${KEEP_ROOTFS_DIRECTORY}" ] && select_installation
	ARCHIVE_NAME="kali-nethunter-rootfs-${SELECTED_INSTALLATION}-${SYS_ARCH}.tar.xz"
	download_rootfs_archive
	verify_rootfs_archive
	extract_rootfs_archive
fi

# Create launchers
if ${ACTION_INSTALL} || ${ACTION_CONFIGURE}; then
	create_rootfs_launcher
	create_vnc_launcher
fi

# Post install configurations
if ${ACTION_CONFIGURE}; then
	make_configurations
fi

# Clean up files
if ${ACTION_INSTALL}; then
	clean_up
fi

# Print message for successful completion
if ${ACTION_INSTALL} || ${ACTION_CONFIGURE}; then
	complete_msg
fi

# Exit successfully
exit 0
