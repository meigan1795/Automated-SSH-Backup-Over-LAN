#!/bin/bash

###############################################
#              User Variables                 #
###############################################
orisrc="${orisrc:-/home/meigan1795/TEST}"
src="${1:-/home/meigan1795/backup_source}"
dst="${2:-/home/meigan1795/Downloads}"
remote="${3:-192.168.100.2}"
backupDepth=${backupDepth:-7}
timeout=${timeout:-1800}
pathBak0="${pathBak0:-currentbackup}"
partialFolderName="${partialFolderName:-.rsync-partial}"
rotationLockFileName="${rotationLockFileName:-.rsync-rotation-lock}"
pathBakN="${pathBakN:-backup}"
nameBakN="${nameBakN:-Day}"
exclusionFileName="${exclusionFileName:-exclude.txt}"
dateCmd="${dateCmd:-date}"
logName="${logName:-rsync-incremental-backup_$(${dateCmd} -Id)_$(${dateCmd} +%H-%M-%S).log}"
ownFolderName="${ownFolderName:-.rsync-incremental-backup}"
logFolderName="${logFolderName:-log}"
interactiveMode="${interactiveMode:-no}"
email=1
emailaddr=meigan1795@gmail.com
emailsubj="$HOSTNAME Backup"
weekfoldername="${weekfoldername:-Week}"

###############################################
#            Application Variables            #
###############################################
ownFolderPath="${HOME}/${ownFolderName}"
tempLogPath="${ownFolderPath}/${remote}_${dst//[\/]/\\}"
exclusionFilePath="${ownFolderPath}/${exclusionFileName}"
remoteDst="${remote}:${dst}"
bak8="${dst}/${pathBak0}"
remoteBak0="${remoteDst}/${pathBak0}"
partialFolderPath="${dst}/${partialFolderName}"
rotationLockFilePath="${dst}/${rotationLockFileName}"
logPath="${dst}/${pathBakN}/${logFolderName}"
remoteLogPath="${remote}:${logPath}"
logFile="${tempLogPath}/${logName}"
weekPath="${dst}/${weekfoldername}"

# FUNCTIONS
rotatebackup() {
	printf "Start backup rotation!!! \n"
	if (ssh "${sshParams[@]}" "${remote}" "[ -d ${!bakOldPath} ]")
	then
		ssh "${sshParams[@]}" "${remote}" "mv ${!bakOldPath} ${!bakNewPath}"
	fi
}

weekfolder(){
	printf "WEEK folder!!! \n"
	ssh "${sshParams[@]}" "${remote}" "cd ${dst}"
	prefix="Day_"
	l=1
	ssh "${sshParams[@]}" "${remote}" "mv -v -f ${dst}${prefix}* '-t ${weekPath}${{weekfoldername}_${l}}'"
	true "$((l = l + 1))"
}

# Prepare own folder
mkdir -p "${tempLogPath}" 
touch "${logFile}"
touch "${exclusionFilePath}"

writeToLog() {
	echo -e "${1}" | tee -a "${logFile}"
}

writeToLog "********************************"
writeToLog "*                              *"
writeToLog "*   rsync-incremental-backup   *"
writeToLog "*                              *"
writeToLog "********************************"

# Prepare backup paths
i=1
k=1
while [ "${i}" -le "${backupDepth}" ]
do
	export "bak${i}=${dst}/${pathBakN}/${nameBakN}_${i}"
	export "bak${j}=bak${i}"
	true "$((i = i + 1))"
done 

writeToLog "\\n[$(${dateCmd} -Is)] You are going to backup"
writeToLog "\\tfrom:  ${src}"
writeToLog "\\tto:    ${remoteBak0}"

# Prepare ssh parameters for socket connection, reused by following sessions
sshParams=(-o "ControlPath=\"${ownFolderPath}/ssh_connection_socket_%h_%p_%r\"" -o "ControlMaster=auto" \
	-o "ControlPersist=10")

# Prepare rsync transport shell with ssh parameters (escape for proper space handling)
rsyncShellParams=(-e "ssh$(for i in "${sshParams[@]}"; do echo -n " '${i}'"; done)")

batchMode="yes"
if [ "${interactiveMode}" = "yes" ]
then
	batchMode="no"
fi

# Check remote connection and create master socket connection
if ! ssh "${sshParams[@]}" -q -o BatchMode="${batchMode}" -o ConnectTimeout=10 "${remote}" exit
then
	writeToLog "\\n[$(${dateCmd} -Is)] Remote destination is not reachable"
	exit 1
fi

# Prepare paths at destination
ssh "${sshParams[@]}" "${remote}" "mkdir -p ${dst} ${logPath}"

writeToLog "\\n[$(${dateCmd} -Is)] Old logs sending begins\\n"

# Send old pending logs to destination
rsync "${rsyncShellParams[@]}" -rhvz --remove-source-files --exclude="${logName}" --log-file="${logFile}" \
	"${tempLogPath}/" "${remoteLogPath}/"

writeToLog "\\n[$(${dateCmd} -Is)] Old logs sending finished"

# Rotate backups if last rsync succeeded ..
if (ssh "${sshParams[@]}" "${remote}" "[ ! -d ${partialFolderPath} ] && [ ! -e ${rotationLockFilePath} ]")
then
	# .. and there is previous data
	if (ssh "${sshParams[@]}" "${remote}" "[ -d ${bak8} ]")
	then
		writeToLog "\\n[$(${dateCmd} -Is)] Backups rotation begins"

		# Rotate the previous backups
		while [ "${i}" -eq 8 ] 
		do	
			printf "The currentbackup folder does exist.\n"
			# To test whether it is the 
			if (ssh "${sshParams[@]}" "${remote}" "[ ! -e ${bak1} ]")
			then
				printf "TEST 1!!!\n"
				bakOldPath="bak${i}"
				true "$((j = i - 7))"
				printf "THE value of j is ${j}.\n"
				true "$((i = i - 7))"
				bakNewPath="bak${i}"
				rotatebackup
				true "$((k = 2))"
				backPath="${bak1}/"
				printf "TEST 1 END!!!\n"
			elif (ssh "${sshParams[@]}" "${remote}" "[ -e ${bak1} ] && [ ! -e ${bak2} ]") 
			then
				printf "TEST 2!!!\n"
				bakOldPath="bak${i}"
				true "$((j = i - 6))"
				printf "THE value of j is ${j}.\n"
				true "$((i = i - 6))"
				bakNewPath="bak${i}"
				rotatebackup
				true "$((k = 3))"
				backPath="${bak2}/"
				printf "TEST 2 END!!!\n"
			elif (ssh "${sshParams[@]}" "${remote}" "[ -e ${bak2} ] && [ ! -e ${bak3} ]")
			then
				printf "TEST 3!!!\n"
				bakOldPath="bak${i}"
				true "$((j = i - 5))"
				printf "THE value of j is ${j}.\n"
				true "$((i = i - 5))"
				bakNewPath="bak${i}"
				rotatebackup
				true "$((k = 4))"
				backPath="${bak3}/"
				printf "TEST 3 END!!!\n"
			elif (ssh "${sshParams[@]}" "${remote}" "[ -e ${bak3} ] && [ ! -e ${bak4} ]")
			then
				printf "TEST 4!!!\n"
				bakOldPath="bak${i}"
				true "$((j = i - 4))"
				printf "THE value of j is ${j}.\n"
				true "$((i = i - 4))"
				bakNewPath="bak${i}"
				rotatebackup
				true "$((k = 5))"
				backPath="${bak4}/"
				printf "TEST 4 END!!!\n"
			elif (ssh "${sshParams[@]}" "${remote}" "[ -e ${bak4} ] && [ ! -e ${bak5} ]")
			then
				printf "TEST 5!!!\n"
				bakOldPath="bak${i}"
				true "$((j = i - 3))"
				printf "THE value of j is ${j}.\n"
				true "$((i = i - 3))"
				bakNewPath="bak${i}"
				rotatebackup
				true "$((k = 6))"
				backPath="${bak5}/"
				printf "TEST 5 END!!!\n"
			elif (ssh "${sshParams[@]}" "${remote}" "[ -e ${bak5} ] && [ ! -e ${bak6} ]") 
			then
				printf "TEST 6!!!\n"
				bakOldPath="bak${i}"
				true "$((j = i - 2))"
				printf "THE value of j is ${j}.\n"
				true "$((i = i - 2))"
				bakNewPath="bak${i}"
				rotatebackup
				true "$((k = 7))"
				backPath="${bak6}/"
				printf "TEST 6 END!!!\n"
			elif (ssh "${sshParams[@]}" "${remote}" "[ -e ${bak6} ] && [ ! -e ${bak7} ]") 
			then
				printf "TEST 7!!!\n"
				bakOldPath="bak${i}"
				true "$((j = i - 1))"
				printf "THE value of j is ${j}.\n"
				true "$((i = i - 1))"
				bakNewPath="bak${i}"
				rotatebackup
				weekfolder
				true "$((k = 8))"
				backPath="${bak7}/"
				printf "TEST 7 END!!!\n"
			fi
		done

		writeToLog "[$(${dateCmd} -Is)] Backups rotation finished\\n"
	else
		writeToLog "\\n[$(${dateCmd} -Is)] No previous data found, there is no backups to be rotated\\n"
	fi
else
	writeToLog "\\n[$(${dateCmd} -Is)] Last backup failed, backups will not be rotated\\n"
fi


# Set rotation lock file to detect in next run when backup fails
ssh "${sshParams[@]}" "${remote}" "touch ${rotationLockFilePath}"

writeToLog "[$(${dateCmd} -Is)] Encryption begins\\n"

# Do encryption
printf "Start ENCRYPTION!!! \n"
if [ ! -d "${src}" ]
then
	mkdir "${src}"
else
	printf "the file does exist.\n"
fi

cd "${src}"
pwd

gpg-zip --encrypt --output ${k}.gpg --gpg-args '-r meigan1795@hotmail.com' ${orisrc}

writeToLog "[$(${dateCmd} -Is)] Backup begins\\n"

# Do the backup
printf "Start RSYNC BACKUP!!! \n"
if rsync "${rsyncShellParams[@]}" -achvz --progress --timeout="${timeout}" --delete --no-W \
	--partial-dir="${partialFolderPath}" --link-dest="${backPath}/" --log-file="${logFile}" --exclude="${ownFolderPath}" \
	--chmod=+r --exclude-from="${exclusionFilePath}" "${src}/" "${remoteBak0}/"
then
	printf "2. WHAT IS THE LOCATION ${backPath} ???"
	writeToLog "\\n[$(${dateCmd} -Is)] Backup completed successfully\\n"

	# Clear unneeded partials and lock file
	ssh "${sshParams[@]}" "${remote}" "rm -rf ${partialFolderPath} ${rotationLockFilePath}"
	rsyncFail=0
else
	writeToLog "\\n[$(${dateCmd} -Is)] Backup failed, try again later\\n"
	rsyncFail=1
fi 

# Send the complete log file to email address
if [ $email -eq 1 ]
  then cat "${logFile}" | mail -s "$emailsubj" $emailaddr 
else
	echo "The email is failed to send !!!\n"
fi

# Send the complete log file to destination
if scp "${sshParams[@]}" "${logFile}" "${remoteLogPath}"
then
	rm "${logFile}"
fi

# Close master socket connection quietly
ssh "${sshParams[@]}" -q -O exit "${remote}"

exit "${rsyncFail}"
