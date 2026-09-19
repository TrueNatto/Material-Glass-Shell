#!/bin/bash
set -e

REPO_URL="https://github.com/TrueNatto/Material-Glass-Shell"
CONFIG_DIR="$HOME/.config"

echo "📦 [Dotfiles Launcher] Bắt đầu thiết lập hệ thống từ Material-Glass-Shell..."

# 1. Tự động kéo Dotfiles về nếu là máy mới
if [ ! -d "$CONFIG_DIR/.git" ]; then
    echo "🌐 Đang thiết lập cấu hình máy mới..."

    if [ -d "$CONFIG_DIR" ]; then
        echo "⚠️  Phát hiện thư mục .config cũ, đang sao lưu thành .config.bak..."
        mv "$CONFIG_DIR" "${CONFIG_DIR}.bak"
    fi

    echo "📥 Đang clone repo Material-Glass-Shell..."
    git clone "$REPO_URL" /tmp/material-glass
    mv /tmp/material-glass/.config "$CONFIG_DIR"
    rm -rf /tmp/material-glass
else
    echo "✅ Dotfiles đã tồn tại. Bỏ qua bước clone."
fi

# 2. Cài đặt yay nếu chưa có
if ! command -v yay &> /dev/null; then
    echo "⚙️  Không tìm thấy yay, đang cài đặt..."
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd ~
fi

# 3. Cập nhật hệ thống
echo "🔄 Đang cập nhật hệ thống..."
yay -Syu --noconfirm

# 4. Danh sách gói
packages=(

  # Hyprland WM
  "hyprland" "hyprpolkitagent"
  "quickshell" "waybar" "mako" "wlogout"
  "rofi" "rofi-bluetooth-git" "matugen"

  # Terminal & Shell
  "fish" "foot" "fastfetch"
  "yazi" "neovim" "btop" "ncdu" "nano"

  # Multimedia & Utilities
  "brave-bin" "mpv" "cava" "imv"
  "brightnessctl" "cliphist" "wl-clipboard"
  "grim" "slurp" "playerctl" "jq"

  # Network & Hardware
  "networkmanager" "network-manager-applet" "networkmanager-dmenu"
  "bluez" "bluez-utils" "sof-firmware" "intel-ucode"
  "btrfs-progs" "compsize" "cpupower" "rofi-bluetooth"
  "smem" "zram-generator" "ufw" "grub"

  # Fonts & Themes
  "inter-font" "maplemono-nf-cn-unhinted"
  "otf-atkinsonhyperlegiblemono-nerd"
  "noto-fonts-emoji" "rose-pine-cursor"

  # Fcitx5 (tiếng Việt)
  "fcitx5" "fcitx5-configtool" "fcitx5-gtk" "fcitx5-qt" "fcitx5-lotus"

  # Misc
  "awww"
)

echo "📥 Đang cài đặt các gói..."
yay -S --needed --noconfirm "${packages[@]}"

# 5. Cài 3 công cụ Rofi của TrueNatto
echo "🚀 Đang cài đặt Rofi tools của TrueNatto..."

if ! command -v rofi-sink &> /dev/null; then
    git clone https://github.com/TrueNatto/rofi-audio-sink /tmp/rofi-audio-sink
    sudo install -Dm755 /tmp/rofi-audio-sink/rofi-audio-sink.sh /usr/local/bin/rofi-sink
    rm -rf /tmp/rofi-audio-sink
fi

if ! command -v rofi-clipboard &> /dev/null; then
    git clone https://github.com/TrueNatto/rofi-clipboard /tmp/rofi-clipboard
    sudo install -Dm755 /tmp/rofi-clipboard/rofi-clipboard.sh /usr/local/bin/rofi-clipboard
    rm -rf /tmp/rofi-clipboard
fi

if ! command -v rofi-notify &> /dev/null; then
    git clone https://github.com/TrueNatto/rofi-mako-notify /tmp/rofi-mako-notify
    sudo install -Dm755 /tmp/rofi-mako-notify/rofi-mako-notify.sh /usr/local/bin/rofi-notify
    rm -rf /tmp/rofi-mako-notify
fi

# 6. Kích hoạt services
echo "⚙️  Kích hoạt Systemd services..."
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth
sudo systemctl enable --now ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

echo "🎉 Hoàn tất! Môi trường Material-Glass-Shell đã sẵn sàng."
