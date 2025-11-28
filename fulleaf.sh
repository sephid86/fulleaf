#!/usr/bin/env bash

#c-code execl("/usr/bin/env", "bash", script_path, "--userpw", "aa", "--rootpw", "bb", (char *)NULL);
error_handler() {
  echo "----------------------------------------"
  echo "ERROR"
  echo "Line : ${BASH_LINENO[0]}"
  echo "${BASH_COMMAND}"
  echo "----------------------------------------"
  exit 1
}

add_env() {
  local CONF_FILE="/etc/environment"
  local var_name="$1"
  local var_value="$2"
  local new_line="${var_name}=${var_value}"

  if ! grep -q "^${var_name}=" "$CONF_FILE" 2>/dev/null; then
    echo "$new_line" >> "$CONF_FILE"
    echo "[INFO] add env: $new_line"
  else
    echo "[INFO] skip: $var_name - variable already exists."
  fi
}

pacfile() {
  local all_packages=""
  for pkg_list_file in "$@"; do
    if [ -f "$pkg_list_file" ]; then
      all_packages="$all_packages $(cat "$pkg_list_file")"
    else
      echo "Error : $pkg_list_file file not found. skip"
    fi
  done
  
  if [ -n "$all_packages" ]; then
    arch-chroot /mnt pacman -Sy --noconfirm $all_packages
  fi
}

pac() {
  arch-chroot /mnt pacman -Sy --noconfirm "$@"
}

trap 'error_handler' ERR
set -e

USER_ID=""
USER_PW=""
ROOT_PW=""
INSTALL_GNOME="false"
INSTALL_HYPR="false"
INSTALL_SWAY="false"
tmode="false"

usage() {
  echo "usage: $0 --userid <ID> --userpw <PW> --rootpw <PW>"
  echo "        [--tmode] [--gnome] [--hypr] [--sway]"
  echo "        [--storage </dev/storage>] [--storage-mode <Number>]"
  echo " "
  echo "Required options: --userid, --userpw, --rootpw"
  echo " "
  echo "-- Caution --"
  echo "  If running in a terminal, do not use --userid <ID>, --userpw <PW>, --rootpw <PW>."
  echo " Use --tmode for security."
  echo " "
  echo "Note: "
  echo "  If the --storage </dev/storage> option is missing,"
  echo " the user can manually set up partitions and mount them to proceed with installation."
  echo " Required mount points: /mnt and /mnt/boot."
  echo " "
  echo "--storage-mode 0 : creating new partitions and formatting storage."
  echo "                  All data on the storage will be deleted."
  echo "--storage-mode 1 : Keep /boot and other partitions."
  echo "                  Format only the root (/) partition."
  exit 1
}

ARGS=$(getopt -o "" --long userid:,userpw:,rootpw:,tmode,storage:,storage-mode:,gnome,hypr,sway,help --name "$(basename "$0")" -- "$@") || true

if [ $? -ne 0 ]; then
  usage
fi

eval set -- "$ARGS"

while true; do
  case "$1" in
    --userid)
      USER_ID="$2"
      shift 2
      ;;
    --userpw)
      USER_PW="$2"
      shift 2
      ;;
    --rootpw)
      ROOT_PW="$2"
      shift 2
      ;;
    --storage)
      storage="$2"
      needs_storage=false
      shift 2
      ;;
    --storage-mode)
      storage="$2"
      shift 2
      ;;
    --gnome)
      INSTALL_GNOME="true"
      shift 1
      ;;
    --hypr)
      INSTALL_HYPR="true"
      shift 1
      ;;
    --sway)
      INSTALL_SWAY="true"
      shift 1
      ;;
    --tmode)
      tmode="true"
      shift 1
      ;;
    --help)
      usage
      ;;
    --)
      shift
      break
      ;;
    *)
      usage >&2
      exit 1
      ;;
  esac
done

if [ "$tmode" == "true" ]; then
  echo "----- Input User ID : "
  read USER_ID
  echo "----- Input User Password : "
  read -s USER_PW
  echo "----- Input Root Password : "
  read -s ROOT_PW
fi

if [[ -z "$USER_ID" || -z "$USER_PW" || -z "$ROOT_PW" ]]; then
  echo "Error: userid, userpw, rootpw are required options." >&2
  usage
fi

echo "-----------------------------------------"
echo "User ID : $USER_ID"
echo "Storage Device : $storage"
echo "Install GNOME: $INSTALL_GNOME"
echo "Install Hypralnd :  $INSTALL_HYPR"
echo "Install Sway:  $INSTALL_SWAY"
echo "-----------------------------------------"

#1-diskset
ROOT_MNT="/mnt"
BOOT_MNT="/mnt/boot"
PARTITION_LABEL="Fulleaf"

if [[ -n "$storage" && -n "$storage-mode" ]]; then
  echo "partition configuration is in progress..."

  if [[ "$storage-mode" -eq 0 ]]; then
    echo "Mode 0 : creating new partitions and formatting storage."
    echo "Mode 0 : All data on the storage will be deleted."

    # storage=/dev/nvme0n1 
    EFI_SIZE_MB=500

    echo "--> sgdisk를 사용하여 파티션 테이블 초기화 및 파티션 생성"
    sgdisk -Z "$storage" -n 1:0:+${EFI_SIZE_MB}MiB -c 1:"EFI System Partition" -t 1:EF00 -n 2:0:0 -c 2:"Fulleaf-btrfs" -t 2:8300

    boot_efi_partition="${storage}p1"
    btrfs_root_partition="${storage}p2"

    echo "--> EFI 파티션 포맷"
    mkfs.fat -F32 "$boot_efi_partition"

    echo "--> Btrfs 루트 파티션 포맷"
    mkfs.btrfs "$btrfs_root_partition"

    echo "--> Btrfs 파티션 임시 마운트 및 서브볼륨 생성"
    mount $btrfs_root_partition/mnt
    btrfs subvolume create "${mount_point}/@root"

    echo "--> EFI 파티션 /mnt/boot 에 마운트"
    mkdir -p /mnt/boot
    mount "$boot_efi_partition" "/mnt/boot"

  elif [[ "$storage-mode" -eq 1 ]]; then
    echo "Mode 1 : Keep /boot and other partitions."
    echo "Mode 1 : Format only the root (/) partition."

    PART_DEV_ROOT=$(lsblk "$storage" -o NAME,FSTYPE,MOUNTPOINT | grep -E 'ext4|btrfs|xfs|f2fs' | awk '{print "/dev/"$1}' | head -n 1)
    FSTYPE_ROOT=$(lsblk "$PART_DEV_ROOT" -o FSTYPE --noheadings)

    if [ -z "$PART_DEV_ROOT" ] || [ -z "$FSTYPE_ROOT" ]; then
      echo "Error : $storage " >&2
      exit 1
    fi

    echo "old / partition found.: $PART_DEV_ROOT (type: $FSTYPE_ROOT)"

    echo "$PART_DEV_ROOT unmount"
    umount -l "$PART_DEV_ROOT" 2>/dev/null
    umount "$PART_DEV_ROOT" 2>/dev/null

    echo "Formatting or cleaning root partition..."
    case "$FSTYPE_ROOT" in
      "btrfs")
        TEMP_MOUNT_DIR="/tmp/btrfs_top_mnt"
        mkdir -p "$TEMP_MOUNT_DIR"
        mount -o subvolid=5 "$PART_DEV_ROOT" "$TEMP_MOUNT_DIR"

        if [ -d "$TEMP_MOUNT_DIR/@" ]; then
          btrfs subvolume delete "$TEMP_MOUNT_DIR/@"
          echo "old @ subvol delated."
        fi
        btrfs subvolume create "$TEMP_MOUNT_DIR/@"
        echo "new @ subvol created."
        umount "$TEMP_MOUNT_DIR"
        rmdir "$TEMP_MOUNT_DIR"
        btrfs filesystem label "$PART_DEV_ROOT" "$PARTITION_LABEL"
        ;;
      *)
        mkfs."$FSTYPE_ROOT" -F -L "$PARTITION_LABEL" "$PART_DEV_ROOT"
        if [ $? -ne 0 ]; then echo "Error : format fail."; exit 1; fi
        ;;
    esac
    echo "/ Partition created successfully."

    mkdir -p "$ROOT_MNT"
    if [ "$FSTYPE_ROOT" == "btrfs" ]; then
      mount -o subvol=@ "$PART_DEV_ROOT" "$ROOT_MNT"
    else
      mount "$PART_DEV_ROOT" "$ROOT_MNT"
    fi
    echo "$PART_DEV_ROOT - $ROOT_MNT mounted."

    echo "$storage search boot partition..."

    PART_DEV_BOOT=$(lsblk "$storage" -o NAME,FSTYPE | grep -E 'vfat' | awk '{print "/dev/"$1}' | head -n 1)

    if [ -z "$PART_DEV_BOOT" ]; then
      echo "Error: $storage - EFI boot (vfat) partition not found." >&2
      exit 1
    fi

    echo "boot partition found: $PART_DEV_BOOT"

    echo "$PART_DEV_BOOT unmount..."
    umount -l "$PART_DEV_BOOT" 2>/dev/null
    umount "$PART_DEV_BOOT" 2>/dev/null

    mkdir -p "$BOOT_MNT"
    mount "$PART_DEV_BOOT" "$BOOT_MNT"

    if [ $? -eq 0 ]; then
      echo "$PART_DEV_BOOT - $BOOT_MNT mounted."
    else
      echo "Error: $PART_DEV_BOOT mount fail." >&2
      exit 1
    fi
  else
    echo "Error : You must choose a storage mode for the storage configuration." >&2
    exit 1
  fi
fi

if [ -z "$storage" ]; then
  echo "partition configuration is in progress..."
  echo "Mode   : User manual partition configuration and mounting."
fi

#2-pacstrap
pacstrap /mnt $(cat fulleaf-pacstrap)

#3-env
cp /etc/os-release /mnt/etc/os-release
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
echo ko_KR.EUC-KR EUC-KR > /mnt/etc/locale.gen
echo ko_KR.UTF-8 UTF-8 >> /mnt/etc/locale.gen
echo en_US.UTF-8 UTF-8 >> /mnt/etc/locale.gen 
arch-chroot /mnt locale-gen
echo LANG=ko_KR.UTF-8 > /mnt/etc/locale.conf
echo fulleaf > /mnt/etc/hostname
echo \"MAKEFLAGS='-j$(nproc)'\" >> /mnt/etc/makepkg.conf
cp /etc/DIR_COLORS /mnt/etc
cp /etc/bash.bashrc /mnt/etc
cp -rf skel /mnt/etc/
cp -rf skel/.config /mnt/root/
cp -rf /root/.bashrc /mnt/root/
arch-chroot /mnt sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers
arch-chroot /mnt su - %s -c 'git config --global core.editor nvim'

# arch-chroot /mnt su - %s -c 'ln --symbolic /usr/share/icons/Vimix-white-cursors ~/.local/share/icons/default'
# arch-chroot /mnt ln --symbolic /usr/share/icons/Vimix-white-cursors /etc/skel/.local/share/icons/default
sed -i '/^HOOKS=/s/udev /udev plymouth /' /mnt/etc/mkinitcpio.conf

# mirrorlist
# Server = ftp.harukasan.org
# Server = mirror.funman.xyz
# Server = mirror.premi.st

add_env EDITOR nvim
add_env VISUAL nvim
add_env ELECTRON_ENABLE_WAYLAND 1
add_env ELECTRON_OZONE_PLATFORM_HINT wayland
add_env GDK_BACKEND wayland
add_env QT_QPA_PLATFORM wayland;xcb
add_env CHROME_FLAGS "--enable-features=vulkan --use-angle=vulkan"
add_env MOZ_ENABLE_WAYLAND 1

add_env XCURSOR_THEME Vimix-white-cursors
add_env XCURSOR_SIZE 24

dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita'"
dconf write /org/gnome/desktop/interface/icon-theme "'Adwaita'"
dconf write /org/gnome/desktop/interface/cursor-theme "'Vimix-white-cursors'"
dconf write /org/gnome/desktop/interface/cursor-size "24"
dconf write /org/gnome/desktop/input-sources/sources "[('ibus','hangul')]"
dconf write /org/gnome/desktop/input-sources/xkb-options "['korean:ralt_hangul','korean:rctrl_hanja']"

gtk_settings="[Settings]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Adwaita
gtk-cursor-theme-name=Vimix-white-cursors
gtk-cursor-theme-size=24"

mkdir -p "/etc/skel/.config/gtk-3.0"
mkdir -p "/etc/skel/.config/gtk-4.0"
echo "$gtk_settings" > "/etc/skel/.config/gtk-3.0/settings.ini"
echo "$gtk_settings" > "/etc/skel/.config/gtk-4.0/settings.ini"

#4-user
echo root:$ROOT_PW | arch-chroot /mnt chpasswd
arch-chroot /mnt useradd -m -g users -G wheel -s /bin/bash $2
echo $USER_ID:$USER_PW | arch-chroot /mnt chpasswd

arch-chroot /mnt pacman -Sy --noconfirm $(cat fulleaf-font-n-theme)
#5-Boot loader

CPUINFO=$(grep "vendor_id" /proc/cpuinfo | head -n 1 | awk '{print $3}')
cpu_vendor=""

if grep -iq "amd" <<< "$CPUINFO"; then
  cpu_vendor="amd"
elif grep -iq "intel" <<< "$CPUINFO"; then
  cpu_vendor="intel"
else
  cpu_vendor="unknown"
fi

arch-chroot /mnt pacman -Syu
echo "CPU Vendor: $cpu_vendor"
if [[ "$cpu_vendor" == "intel" || "$cpu_vendor" == "amd" ]]; then
  arch-chroot /mnt pacman -Sy --noconfirm $cpu_vendor-ucode
  arch-chroot /mnt mkinitcpio -P
fi

#systemdboot
ENTRIES_DIR="$BOOT_MNT/loader/entries"
TEMP_MNT="/tmp/win_efi_temp"

echo "systemd-boot install..."
arch-chroot "$ROOT_MNT" bootctl install

echo "loader.conf make..."
mkdir -p "$BOOT_MNT/loader" # 실제 파일 경로
cat <<EOF > "$BOOT_MNT/loader/loader.conf"
default  Fulleaf
timeout  5
console-mode max
editor   no
EOF

echo "Fulleaf Linux make boot entries..."
mkdir -p "$ENTRIES_DIR"

ROOT_UUID=$(arch-chroot "$ROOT_MNT" findmnt / -no UUID)

cat <<EOF > "$ENTRIES_DIR/Fulleaf.conf"
title   Fulleaf Linux
linux   /vmlinuz-linux
initrd  /$cpu_vendor-ucode.img
initrd  /initramfs-linux.img
options root=UUID=$ROOT_UUID rw quiet splash
EOF

echo "find Microsoft Windows EFI ..."

VEC_PARTITIONS=$(blkid | grep "vfat")

mkdir -p "$TEMP_MNT"

COUNT=1

while read -r LINE; do
  PART_PATH=$(echo "$LINE" | awk -F':' '{print $1}')
  PART_UUID=$(echo "$LINE" | grep -o 'UUID="[^"]*"' | cut -d'"' -f2)

  # Arch ESP pass (chroot outside)
  ARCH_ESP_PATH=$(findmnt -n --raw -o SOURCE "$BOOT_MNT")
  if [ "$PART_PATH" == "$ARCH_ESP_PATH" ]; then
    continue
  fi

  mount "$PART_PATH" "$TEMP_MNT" 2>/dev/null

  if [ $? -eq 0 ]; then
    if [ -f "$TEMP_MNT/EFI/Microsoft/Boot/bootmgfw.efi" ]; then
      echo "  -> Windows bootloader found. ($PART_PATH)."

      cp -r "$TEMP_MNT/EFI/Microsoft" "$BOOT_MNT/EFI/"

      WIN_ENTRY_CONF="$ENTRIES_DIR/windows_$COUNT.conf"
      cat <<EOF > "$WIN_ENTRY_CONF"
title   Windows Boot Manager ($COUNT)
efi     /EFI/Microsoft/Boot/bootmgfw.efi
EOF

COUNT=$((COUNT + 1))
    fi

    umount "$TEMP_MNT"
  fi
done <<< "$VEC_PARTITIONS"
rmdir "$TEMP_MNT"

#7-GUI install
#gnome -
if [ "$INSTALL_GNOME" == "true" ]; then
  pacfile fulleaf-gui fulleaf-gnome
  arch-chroot /mnt pacman -R gnome-software gnome-console
  arch-chroot /mnt systemctl enable gdm
fi

#hyprland -
if [ "$INSTALL_HYPR" == "true" ]; then
  pacfile fulleaf-gui fulleaf-hypr

  #gnome 설치가 아니면 regreet 설치
  if [[ "$INSTALL_GNOME" != "true" || "$INSTALL_SWAY" != "true" ]]; then
    pac greetd greetd-regreet cage

# echo "[terminal]
# vt = 1
#
# [default_session]
# # 'cage' 안에서 'regreet'를 실행하도록 설정
# command = "cage -s -- regreet" 
# user = "greeter" 
# " > /etc/greetd/regreet.toml

arch-chroot /mnt systemctl enable regreet
  fi
fi
#sway -
if [ "$INSTALL_SWAY" == "true" ]; then
  echo "Error : Sway installation is not yet supported." >&2
  exit 1
  # arch-chroot /mnt pacman -Sy --noconfirm $(cat fulleaf-sway)
  #
  # cp -rf /usr/share/wayland-sessions /mnt/usr/share/"
  # cp /usr/bin/sway-fcitx /mnt/bin/"
  # chmod +x /mnt/bin/sway-fcitx", Widget);
  # # //		sprintf(tmp_str,"arch-chroot /mnt systemctl enable --now --user gnome-keyring-daemon");
  #
  # if [ "$INSTALL_GNOME" != "true" || "$INSTALL_HYPR" != "true"]; then
  #   # regreet 설치
  # fi
fi

#8-systemd
arCh-chroot /mnt systemctl enable NetworkManager
arch-chroot /mnt systemctl enable plymouth-start

if [[ "$INSTALL_GNOME" == "true" || "$INSTALL_HYPR" == "true" || "$INSTALL_SWAY" == "true" ]]; then
  arch-chroot /mnt systemctl enable rtkit-daemon
fi

#-fisnish-
arch-chroot /mnt mkinitcpio -P
