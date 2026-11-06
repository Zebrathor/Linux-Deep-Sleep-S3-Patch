# Linux Deep Sleep (S3) Patch

A lightweight, safe, and interactive Bash utility to switch Linux laptops from Modern Standby (`s2idle`) to S3 Suspend-to-RAM (`deep` sleep) and make the configuration persistent across reboots.

Designed for **CachyOS**, Arch Linux, and any modern `systemd`-based Linux distribution where battery drain during sleep is an issue.

---

## Why?

Many modern laptops default to `s2idle` (Modern Standby / S0ix) instead of traditional `deep` sleep (ACPI S3). On Linux, `s2idle` often causes excessive battery drain while the laptop lid is closed.

Instead of modifying bootloader configurations (GRUB, systemd-boot, rEFInd) which we have the risk of breaking your boot process or creating heavy custom `systemd` services, this tool uses native **`systemd-tmpfiles`** (`/etc/tmpfiles.d/mem-sleep.conf`).

### Key Features
* **100% Boot-Safe:** Uses `/etc/tmpfiles.d/` instead of touching bootloader configs.
* **Hardware Validation:** Automatically checks if your BIOS/hardware supports `deep` sleep before applying any changes.
* **Instant Application:** Applies or reverts the sleep mode immediately in the live kernel session no reboot required.
* **Interactive Menu:** Easily check current status, apply the patch, or revert to factory defaults.

---

## Prerequisites

1. **A `systemd`-based Linux distribution** (CachyOS, Arch, Fedora, Ubuntu, Debian, openSUSE, etc.).
2. **Hardware S3 (`deep`) support enabled in BIOS/UEFI.**

You can verify if your laptop supports `deep` sleep by running:
```bash
cat /sys/power/mem_sleep
```
* If the output contains `deep` (example: `[s2idle] deep`), your hardware is compatible.
* If it only outputs `[s2idle]`, you may need to enter your BIOS/UEFI settings and change the *Sleep State* from "Windows / Modern Standby" to **"Linux / S3"**.

---

## Installation & Usage

1. **Clone the repository or download the script:**
   ```bash
   git clone https://github.com/Zebrathor/Linux-Deep-Sleep-S3-Patch.git
   cd Linux-Deep-Sleep-S3-Patch
   ```

2. **Make the script executable:**
   ```bash
   chmod +x deep-sleep-patch.sh
   ```

3. **Run the script with `sudo`:**
   ```bash
   sudo ./deep-sleep-patch.sh
   ```

---

## Interface Preview

```text
**************************************************
               Suspend Mode Manager      
**************************************************
Current status : s2idle [deep]
Patch status   : INSTALLED (/etc/tmpfiles.d/mem-sleep.conf)
--------------------------------------------------
1) Apply patch, enable 'deep' sleep mode
2) Revert patch, restore 's2idle' and remove conf
3) Exit
--------------------------------------------------
Select an option [1-3]: 
```

---

## How It Works

### Applying the Patch (Option 1)
1. Verifies that `deep` is listed inside `/sys/power/mem_sleep`.
2. Creates `/etc/tmpfiles.d/mem-sleep.conf` with the rule:
   ```text
   w /sys/power/mem_sleep - - - - deep
   ```
3. Runs `systemd-tmpfiles --create /etc/tmpfiles.d/mem-sleep.conf` to immediately switch the active kernel mode to `[deep]` for the current session.

### Reverting the Patch (Option 2)
1. Deletes `/etc/tmpfiles.d/mem-sleep.conf` so future boots return to system defaults.
2. Writes `s2idle` directly back into `/sys/power/mem_sleep` so the current session is restored without needing a reboot.

---

## License

This project is open-source and available under the [GNU General Public License v3.0](LICENSE).
