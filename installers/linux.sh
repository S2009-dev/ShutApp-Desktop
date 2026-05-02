#!/bin/bash

# ==========================
# AUTO-ELEVATE TO ROOT
# ==========================
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run the installer as root user!"
    exec sudo "$0" "$@"
fi

# ==========================
# VARIABLES
# ==========================
REPO_OWNER="S2009-dev"
REPO_NAME="ShutApp-Desktop"
SERVICE_FILE="/etc/systemd/system/shutapp-desktop.service"
SERVICE_NAME="shutapp-desktop"
BINARY_NAME="shutapp-desktop"
INSTALL_DIR="/usr/local/bin"
TEMP_DIR="/tmp/shutapp_install"

# ==========================
# DETECT ARCHITECTURE
# ==========================
ARCH=$(uname -m)
case "$ARCH" in
    "x86_64") ASSET_NAME="ShutApp-linux-x86_64" ;;
    "aarch64"|"arm64") ASSET_NAME="ShutApp-linux-arm" ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# ==========================
# DOWNLOAD LATEST RELEASE ASSET
# ==========================
echo "Detected architecture: $ARCH"
echo "Downloading $ASSET_NAME..."

mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR" || exit 1

# Utiliser l'API GitHub pour récupérer l'URL de téléchargement de l'asset
API_URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest"
DOWNLOAD_URL=$(curl -s "$API_URL" | grep -o "https://.*/download/.*$ASSET_NAME" | head -n 1)

if [ -z "$DOWNLOAD_URL" ]; then
    echo "Failed to find download URL for $ASSET_NAME"
    exit 1
fi

echo "Downloading from: $DOWNLOAD_URL"
if ! curl -L -o "$ASSET_NAME" "$DOWNLOAD_URL"; then
    echo "Failed to download $ASSET_NAME"
    exit 1
fi

chmod +x "$ASSET_NAME"
mv "$ASSET_NAME" "$INSTALL_DIR/$BINARY_NAME"
rm -rf "$TEMP_DIR"

# ==========================
# CREATE SERVICE FILE
# ==========================
cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=ShutApp Desktop service
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
User=$USER
ExecStart=$INSTALL_DIR/$BINARY_NAME

[Install]
WantedBy=multi-user.target
EOF

# ==========================
# ENABLE AND START SERVICE
# ==========================
systemctl daemon-reload
systemctl enable "$SERVICE_NAME.service"
systemctl start "$SERVICE_NAME.service"

echo "ShutApp Desktop is now installed and running!"