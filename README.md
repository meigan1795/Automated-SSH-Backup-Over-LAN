# Automated Incremental Secured Data Backup/Restore Process over LAN
## Project Overview
This project emphasizes the design and development of an automated data backup and restore process using Secure Socket Shell (SSH) over Local Area Network (LAN). The solution supports compression, deduplication, and encryption for enhanced data protection. The backup tools employed include Rsync over SSH, GPG key, and cron for automation. Webmin is utilized for user-friendly administration.

## Flowcharts
### Overall Flowchart
![Screenshot 2023-09-21 163102](https://github.com/meigan1795/Automated-SSH-Backup-Over-LAN/assets/38165998/b0838b9a-941d-48ef-9b2e-226fb002cba7)

### Backup Process Flowchart
![data backup](https://github.com/meigan1795/Automated-SSH-Backup-Over-LAN/assets/38165998/0c2c2c1a-7b56-45e1-92b7-3ed9839b2db8)

### Pseudocode of Data Backup Script
![pseudocode fyp](https://github.com/meigan1795/Automated-SSH-Backup-Over-LAN/assets/38165998/1bde3f33-ec73-4f59-bf78-1d36652c8198)

### Data Restore Process Flowchart
![DATA BACKUP PROCESS](https://github.com/meigan1795/Automated-SSH-Backup-Over-LAN/assets/38165998/06dec352-b084-460a-a36b-48de164170de)

## Linux-based Machines
Two Linux-based machines are used in this project, with CentOS chosen for its stability and security compared to Ubuntu. CentOS Minimal is preferred to minimize disk space usage and maintain a functional system.

Specification  | Lenovo Z50-70 Notebook | Samsung NP-N148 Netbook |
:---: | :---: | :---: |
Processor  | Intel (R) Core TM i5-4210U CPU @ 1.70GHz 2.40Ghz | Intel (R) Atom TM CPU N455 @ 1.66GHz * 2 |
RAM  | 4.00 GB | 1.00 GB |
System Type | 64-bit | 64-bit |
Disk | 1TB | 250 GB |
CentOS Edition | CentOS 7 | CentOS 7 |

## Local Area Network (LAN)
The local machine is connected to the backup machine through LAN, established using a switch and LAN cable. IP addresses are assigned to the respective interfaces of both machines for seamless data sharing.
![Picture7](https://github.com/meigan1795/Automated-SSH-Backup-Over-LAN/assets/38165998/e6c2c4c2-742d-45c5-b89d-536243bb62d0)
![Picture10](https://github.com/meigan1795/Automated-SSH-Backup-Over-LAN/assets/38165998/cc59d63a-b152-40f5-8967-f5bd2e96b4b8)

## Preliminary Settings
### Generating Secure Socket Shell (SSH) Key
To secure data transfer, SSH keys are generated, allowing encrypted communication between machines. The process involves:

1. Generating SSH key pair on the client machine.
2. Copying the public key to the server machine.
3. Disabling password login for the root user.

### Generating GNU Privacy Guard (GPG) Key
GPG is utilized for file encryption and decryption. The steps involve creating a new primary keypair and setting a passphrase.

### Setup of Rclone
Rclone is employed for syncing files to and from various cloud storage platforms, including Google Drive. The process includes installing Rclone, generating configuration files, and obtaining necessary credentials.

## Linux Shell Scripting
A shell script is developed to automate the backup process, utilizing SSH, Rsync, Rclone, and GPG for secure and efficient data transfer.

### Rsync
Rsync is employed for efficient file synchronization, offering options for compression, checksum verification, and partial transfers.

### Rsync with Hard Links
Hard links are used to optimize storage space by creating links to existing files. This allows for efficient incremental backups.
![Picture9](https://github.com/meigan1795/Automated-SSH-Backup-Over-LAN/assets/38165998/e3f2c65d-de73-4523-b287-29b345c6a8b1)

## Webmin
Webmin serves as a web-based system administration tool, providing an intuitive interface for managing server configurations.
![Picture8](https://github.com/meigan1795/Automated-SSH-Backup-Over-LAN/assets/38165998/f018b0fc-93c9-485c-a7fc-b5ba9d630079)

## Cron Job
Cron is utilized to schedule automated tasks, including the backup process. Tasks can be set to run at specified intervals.

## Backup Data
Data from the source directory is encrypted and compressed using GPG, then backed up to the destination directory via Rsync with hard links. Incremental backups are organized by day and week.

## Restore Data
Data restoration involves reversing the backup process. Files can be selectively restored, and decryption is performed to retrieve the original data.
