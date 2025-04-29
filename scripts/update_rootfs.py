import requests
import re
import sys
import json
import os

BASE_URL = "https://kali.download/nethunter-images"
INSTALLER_SCRIPT = "install-nethunter.sh"
STATUS_SCRIPT = "status.json"
README = "README.md"


def fetch_all_versions():
    try:
        r = requests.get(BASE_URL, timeout=10)
        r.raise_for_status()
        matches = re.findall(r'(\d{4}\.\d[a-z]?)\/', r.text)
        if not matches:
            raise Exception(f"No versions found on page '{BASE_URL}'.")
        return sorted(set(matches), reverse=True)
    except Exception as e:
        raise Exception(f"Failed to fetch available versions: {str(e)}")


def get_current_version(script_path):
    try:
        with open(script_path, "r") as f:
            content = f.read()
        match = re.search(r'VERSION_NAME="(.+?)"', content)
        if not match:
            raise Exception(f"Current version not found in '{script_path}'.")
        return match.group(1)
    except Exception as e:
        raise Exception(f"Failed to get current version from script: {str(e)}")


def fetch_latest_checksums(version):
    try:
        url = f"{BASE_URL}/kali-{version}/rootfs/SHA256SUMS"
        r = requests.get(url, timeout=10)
        r.raise_for_status()
        raw_checksums = r.text.strip().splitlines()
        expected_suffixes = [
            "rootfs-full-arm64.tar.xz",
            "rootfs-full-armhf.tar.xz",
            "rootfs-minimal-arm64.tar.xz",
            "rootfs-minimal-armhf.tar.xz",
            "rootfs-nano-arm64.tar.xz",
            "rootfs-nano-armhf.tar.xz",
        ]
        filtered = []
        for line in raw_checksums:
            line = line.strip()
            match = re.match(
                r'^([a-f0-9]+)\s+(kali-nethunter-\d{4}\.\d[a-z]?-(rootfs-.+))$', line)
            if match:
                checksum = match.group(1)
                cleaned_filename = f'kali-nethunter-{match.group(3)}'
                for suffix in expected_suffixes:
                    if cleaned_filename.endswith(suffix):
                        filtered.append(f"{checksum}  {cleaned_filename}")
                        break
        if not filtered:
            raise Exception("No matching trusted checksums found.")
        return "\n".join(filtered)
    except Exception as e:
        raise Exception(
            f"Failed to fetch and filter latest checksums: {
                str(e)}")


def verify_rootfs_links(version, checksums_text):
    try:
        base_url = f"{BASE_URL}/kali-{version}/rootfs"
        missing_files = []
        for line in checksums_text.strip().splitlines():
            filename = line.strip().split()[1]
            url = f"{base_url}/{filename}"
            try:
                head_response = requests.head(url, timeout=10)
                if head_response.status_code != 200:
                    missing_files.append(filename)
            except Exception as e:
                missing_files.append(filename)
        if missing_files:
            raise Exception(
                f"Missing or inaccessible files: {', '.join(missing_files)}")
        print("[+] All required rootfs archives are accessible.")
    except Exception as e:
        raise Exception(f"Failed to verify rootfs archive links: {str(e)}")


def update_script(script_path, new_version, new_checksums):
    try:
        with open(script_path, "r") as f:
            content = f.read()
        content = re.sub(
            r'VERSION_NAME=".+?"',
            f'VERSION_NAME="{new_version}"',
            content)
        new_shasums_formatted = '\n\t\t'.join(new_checksums.splitlines())
        new_shasums_block = f'TRUSTED_SHASUMS="$(\n\tcat <<-EOF\n\t\t{new_shasums_formatted}\n\tEOF\n)"'
        content = re.sub(
            r'TRUSTED_SHASUMS="\$\([\s\S]+?EOF\n\)"',
            new_shasums_block,
            content
        )
        with open(script_path, "w") as f:
            f.write(content)
        print(f"[+] Updated {script_path} to version '{new_version}'.")
    except Exception as e:
        raise Exception(f"Failed to update installer script: {str(e)}")


def update_status_json(status_path, status):
    try:
        status_data = {"status": status}
        with open(status_path, "w") as f:
            json.dump(status_data, f, indent=2)
        print(f"[+] Updated {status_path} to status '{status}'.")
    except Exception as e:
        print(f"[-] Failed to update {status_path}: {str(e)}")


def update_readme(readme_path, new_version):
    try:
        with open(readme_path, "r") as f:
            content = f.read()
        updated_content = re.sub(
            r'(<a href="https:\/\/kali\.download\/nethunter-images\/kali-)(\d{4}\.\d[a-z]?)(\/rootfs">)',
            fr'\g<1>{new_version}\g<3>',
            content
        )
        if content != updated_content:
            with open(readme_path, "w") as f:
                f.write(updated_content)
            print(
                f"[+] Updated {readme_path} badge link to version '{new_version}'.")
        else:
            print(f"[!] No matching link found in {readme_path} to update.")
    except Exception as e:
        raise Exception(f"Failed to update {readme_path}: {str(e)}")


def main():
    update_success = False
    try:
        if not all(os.path.exists(f)
                   for f in [INSTALLER_SCRIPT, STATUS_SCRIPT, README]):
            raise FileNotFoundError(
                f"One or more required files are missing: {INSTALLER_SCRIPT}, {STATUS_SCRIPT}, {README}".format())
        print("[+] Fetching available versions...")
        all_versions = fetch_all_versions()
        desired_version = sys.argv[1] if len(sys.argv) > 1 else None
        selected_version = None
        if desired_version:
            if desired_version in all_versions:
                selected_version = desired_version
                print(
                    f"[+] Requested version '{desired_version}' is available.")
            else:
                selected_version = all_versions[0]
                print(
                    f"[!] Requested version '{desired_version}' not found. Falling back to latest '{selected_version}'.")
        else:
            selected_version = all_versions[0]
            print(
                f"[+] Upgrading to latest version '{selected_version}'.")
        print("[+] Checking current script version...")
        current_version = get_current_version(INSTALLER_SCRIPT)
        print(f"[+] Current version: {current_version}")
        print(f"[+] Target version: {selected_version}")
        if current_version == selected_version:
            print("[*] RootFS is already up-to-date.")
            update_success = True
            return
        print("[!] Updating to new version...")
        print("[+] Fetching latest checksums...")
        latest_checksums = fetch_latest_checksums(selected_version)
        print("[+] Verifying rootfs archive links...")
        verify_rootfs_links(selected_version, latest_checksums)
        print("[+] Updating installer script...")
        update_script(INSTALLER_SCRIPT, selected_version, latest_checksums)
        print("[+] Updating README...")
        update_readme(README, selected_version)
        update_success = True
        print("[*] All files updated successfully.")
    except Exception as e:
        print(f"[-] {e}")
    finally:
        if update_success:
            update_status_json(STATUS_SCRIPT, "Available")
        else:
            update_status_json(STATUS_SCRIPT, "Unavailable")
        if not update_success:
            sys.exit(1)


if __name__ == "__main__":
    main()
