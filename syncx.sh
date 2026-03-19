#!/bin/bash

# --- SYNCX: CONFIGURABLE SYNC TOOL ---
CONFIG_FILE="$HOME/.syncxrc"
SCRIPT_PATH="$(realpath "$0")"

# Function to show description
show_description() {
    echo "=========================================================================="
    echo "                              SYNCX TOOL"
    echo "=========================================================================="
    echo "This tool is used for syncing files and folders. It intelligently only "
    echo "copies files that have changes (new, modified, or deleted). "
    echo ""
    echo "Features:"
    echo " - Efficient: Uses rsync for differential backups."
    echo " - Incremental: Only transfers changes, saving time and bandwidth."
    echo " - Mirroring: Can maintain a full copy of your source folder."
    echo ""
    echo "Commands:"
    echo "  --config     Change your source and destination folders"
    echo "  --install    Install syncx to /usr/local/bin (requires sudo)"
    echo "  --help       Show this help message"
    echo "=========================================================================="
    echo ""
}

# Function to handle installation
install_tool() {
    echo "Installing syncx to /usr/local/bin..."
    sudo cp "$SCRIPT_PATH" /usr/local/bin/syncx
    sudo chmod +x /usr/local/bin/syncx
    if [ $? -eq 0 ]; then
        echo "Successfully installed! You can now run 'syncx' from anywhere."
    else
        echo "Installation failed. Please ensure you have sudo privileges."
    fi
    exit
}

# Function to setup configuration
setup_config() {
    echo "Configuration Setup: Selecting source and destination folders..."
    
    # Select Source Folder
    SOURCE=$(zenity --file-selection --directory --title="Select Source Folder (Your Projects)")
    if [ -z "$SOURCE" ]; then echo "Setup cancelled."; exit 1; fi
    
    # Select Destination Folder
    DESTINATION=$(zenity --file-selection --directory --title="Select Destination Folder (Your Backup Drive)")
    if [ -z "$DESTINATION" ]; then echo "Setup cancelled."; exit 1; fi

    # Ensure paths end with a slash for rsync
    [[ "$SOURCE" != */ ]] && SOURCE="$SOURCE/"
    [[ "$DESTINATION" != */ ]] && DESTINATION="$DESTINATION/"

    # Save to config file
    echo "SYNCX_SOURCE=\"$SOURCE\"" > "$CONFIG_FILE"
    echo "SYNCX_DESTINATION=\"$DESTINATION\"" >> "$CONFIG_FILE"
    
    echo "Configuration saved to $CONFIG_FILE"
    echo ""
}

# 1. Handle command line flags
if [[ "$1" == "--install" ]]; then
    install_tool
elif [[ "$1" == "--config" ]]; then
    setup_config
    exit
elif [[ "$1" == "--help" ]]; then
    show_description
    exit
fi

# 2. Show descriptive banner
show_description

# 3. Load or Create Configuration
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    setup_config
    source "$CONFIG_FILE"
fi

# Use the loaded variables
SOURCE="$SYNCX_SOURCE"
DESTINATION="$SYNCX_DESTINATION"

echo "Current Configuration:"
echo " Source:      $SOURCE"
echo " Destination: $DESTINATION"
echo ""

# 4. Check if destination drive is mounted/accessible
if [ ! -d "$DESTINATION" ]; then
    zenity --error --text="Backup failed: Destination folder not found at:\n$DESTINATION\n\nPlease ensure your drive is connected."
    exit 1
fi

# 5. Confirm before sync
zenity --question --text="Start syncing from\n$SOURCE\nto\n$DESTINATION?" || exit 0

# 6. Run the sync with progress bar
rsync -av --delete --info=progress2 "$SOURCE" "$DESTINATION" | \
stdbuf -oL tr '\r' '\n' | \
awk '/%/ {print $2; fflush()}' | \
sed -u 's/%//' | \
zenity --progress \
  --title="Syncing Projects" \
  --text="Updating your backup..." \
  --percentage=0 \
  --auto-close

# Capture exit statuses
RSYNC_STATUS=${PIPESTATUS[0]}
ZENITY_STATUS=${PIPESTATUS[4]}

# 7. Final Notification
if [ $ZENITY_STATUS -eq 1 ]; then
    notify-send "Sync Cancelled" "The backup process was stopped by the user."
elif [ $RSYNC_STATUS -eq 0 ]; then
    notify-send "Sync Complete" "Your files are safely backed up."
    echo "Sync Complete!"
else
    zenity --error --text="Sync encountered an error (Rsync Code: $RSYNC_STATUS)."
    echo "Sync failed with error code $RSYNC_STATUS."
fi
