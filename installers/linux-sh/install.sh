#!/usr/bin/env bash

BRANCH="${1:-stable}"

if [[ ! "$BRANCH" =~ ^(stable|canary|ptb)$ ]]; then
    echo "Invalid branch: $BRANCH. Please choose 'stable', 'canary', or 'ptb'."
    exit 1
fi

GITHUB_ORG="MeguminSama"
REPO_NAME="Vencord-Launcher"

if [[ "$BRANCH" == "ptb" ]]; then
    BRANCH_UPPER="PTB"
    ASSET_NAME="Vencord${BRANCH^^}-"
else
    BRANCH_UPPER="${BRANCH^}"
    ASSET_NAME="Vencord${BRANCH^}-"
fi

LATEST_RELEASE=$(curl -s "https://api.github.com/repos/$GITHUB_ORG/$REPO_NAME/releases/latest")

VERSION=$(echo "$LATEST_RELEASE" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$VERSION" ]; then
    echo "Failed to fetch the latest release. Please try again or open an issue on GitHub."
    exit 1
fi

ASSET_FILENAME="${ASSET_NAME}${VERSION}.tar.gz"

echo "Downloading Vencord $BRANCH $VERSION ($ASSET_FILENAME) from GitHub..."

DOWNLOAD_URL=$(echo "$LATEST_RELEASE" | grep "browser_download_url" | grep "$ASSET_FILENAME" | cut -d '"' -f 4)

if [ -z "$DOWNLOAD_URL" ]; then
    echo "Failed to fetch the download URL. Please try again or open an issue on GitHub."
    exit 1
fi

TEMP_DIR=$(mktemp -d)

curl -L -o "$TEMP_DIR/$ASSET_FILENAME" "$DOWNLOAD_URL"

if [ $? -eq 0 ]; then
    echo "Download successful!"
else
    echo "Download failed. Please try again or open an issue on GitHub."
    exit 1
fi

tar -xzf "$TEMP_DIR/$ASSET_FILENAME" -C "$TEMP_DIR"

if [ $? -eq 0 ]; then
    echo "Extraction successful!"
else
    echo "Extraction failed. Please try again or open an issue on GitHub."
    rm -r "$TEMP_DIR"
    exit 1
fi

echo "Installing Vencord $BRANCH $VERSION..."

sudo install -Dm 755 "$TEMP_DIR/vencord-$BRANCH" /usr/bin/

OTHER_BRANCHES=$(ls /usr/bin | grep 'vencord-' | grep -v "vencord-$BRANCH")

if [ -n "$OTHER_BRANCHES" ]; then
    # TODO: Maybe add a version flag to check if the other branches are outdated?
    echo "Warning: The following Vencord branches are also installed. If they are outdated, consider updating them too:"
    echo "$OTHER_BRANCHES"
fi

sudo install -Dm 644 "$TEMP_DIR/libvencord_launcher.so" /usr/lib/
sudo ldconfig /usr/lib

if [[ $BRANCH == "stable" ]]; then
    DESKTOP_ENTRY_NAME="Vencord"
    DESKTOP_ENTRY_FILENAME="vencord.desktop"
else
    DESKTOP_ENTRY_NAME="Vencord $BRANCH_UPPER"
    DESKTOP_ENTRY_FILENAME="vencord-$BRANCH.desktop"
fi

HICOLOR="/usr/share/icons/hicolor"

sudo install -Dm644 "$TEMP_DIR/icons/icon-16x16.png" "$HICOLOR/16x16/vencord-$BRANCH.png"
sudo install -Dm644 "$TEMP_DIR/icons/icon-32x32.png" "$HICOLOR/32x32/vencord-$BRANCH.png"
sudo install -Dm644 "$TEMP_DIR/icons/icon-48x48.png" "$HICOLOR/48x48/vencord-$BRANCH.png"
sudo install -Dm644 "$TEMP_DIR/icons/icon-64x64.png" "$HICOLOR/64x64/vencord-$BRANCH.png"
sudo install -Dm644 "$TEMP_DIR/icons/icon-128x128.png" "$HICOLOR/128x128/vencord-$BRANCH.png"
sudo install -Dm644 "$TEMP_DIR/icons/icon-256x256.png" "$HICOLOR/256x256/vencord-$BRANCH.png"
sudo install -Dm644 "$TEMP_DIR/icons/icon-512x512.png" "$HICOLOR/512x512/vencord-$BRANCH.png"
sudo install -Dm644 "$TEMP_DIR/icons/icon-1024x1024.png" "$HICOLOR/1024x1024/vencord-$BRANCH.png"

sudo gtk-update-icon-cache /usr/share/icons/hicolor/ || true

DESKTOP_ENTRY="[Desktop Entry]
Name=$DESKTOP_ENTRY_NAME
Comment=$DESKTOP_ENTRY_NAME Launcher
GenericName=Internet Messenger
Exec=/usr/bin/vencord-$BRANCH
Icon=vencord-$BRANCH
Terminal=false
Type=Application
Categories=Network;InstantMessaging;
StartupWMClass=vencord-$BRANCH"

echo "$DESKTOP_ENTRY" | sudo tee "/usr/share/applications/$DESKTOP_ENTRY_FILENAME" > /dev/null

echo "Desktop entry written to /usr/share/applications/$DESKTOP_ENTRY_FILENAME"

rm -r "$TEMP_DIR"
