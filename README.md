# SyncX: Intelligent Sync & Backup Tool

SyncX is a user-friendly CLI tool for Linux designed to sync and backup your folders efficiently. It uses `rsync` under the hood to perform differential backups, meaning it only copies files that have changed, saving you time and disk space.

## Features

- **Efficient Syncing**: Only copies new, modified, or deleted files.
- **Configurable**: Easily set your source and destination folders using a graphical interface.
- **Persistent Settings**: Your configuration is saved in `~/.syncxrc`.
- **User-Friendly**: Includes a clear onboarding process and progress bar.
- **Automated Installation**: Simple flag-based installation to `/usr/local/bin`.

## Installation

To install SyncX to your system, follow these steps:

1.  **Clone the Repository** (or download the script):
    ```bash
    git clone https://github.com/your-username/syncx.git
    cd syncx
    ```

2.  **Make the script executable**:
    ```bash
    chmod +x syncx.sh
    ```

3.  **Run the automated install**:
    ```bash
    ./syncx.sh --install
    ```

Once installed, you can simply run `syncx` from any terminal.

## Usage

### First-Time Setup
When you run `syncx` for the first time, it will automatically guide you through selecting your **Source** (e.g., your projects folder) and **Destination** (e.g., your external backup drive).

### Common Commands
- **Start Sync**: Simply type `syncx` to begin the backup process.
- **Modify Configuration**: Use `syncx --config` to change your sync folders at any time.
- **Help**: Run `syncx --help` to see a full list of features and flags.

## Prerequisites

SyncX requires the following tools to be installed:
- `rsync`
- `zenity`
- `notify-send` (standard on most Linux distributions)

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
