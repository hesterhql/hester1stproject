#!/bin/bash
# define ERROR_FILE location

# root privileges check return exit 1 if not root
#
#
if [[ ${UID} -ne 0 ]]
then
  echo "Only root can executes this script, please sudo or switch to root" >&2
  exit 1
fi

#echo "Parameter number is ${#}"
# provides a user statement much like you would find in a man page if user does not supply an account name on the command line and return exit status of 1
if [[ "${#}" -lt 1 ]]
then
  echo "Usge: ${0} USER_NAME [COMMENTS]... "  >&2
  exit 1
fi

#Uses the first argument provided on the commend line as username for the account.
USER_NAME="${1}"

# Any remaining arguments on the commend line will be treated as the comment for the account.
shift
COMMENTS="${@}"
#Automatically generates a password for the new account.
PASSWORD=$(date +%s%N | sha256sum | head -c48)

#informs the user if the account was not ablle to becreated for some reason. if not return 1
useradd -m "${USER_NAME}" -c "${COMMENTS}" &> /dev/null
if [[ "${?}" -ne 0 ]]
then
  echo "create user failed."  >&2
  exit 1
fi
#add password on new user
echo ${PASSWORD} | passwd --stdin ${USER_NAME} &> /dev/null
if [[ ${?} -ne 0 ]]
then
  echo "create user failed."  >&2
  exit 1
fi
#set expired to force user to change the password.
passwd -e 1 ${USER_NAME} &> /dev/null

#Display username, password and host where the account was created.
echo user information is shown as blew:
echo "username: ${USER_NAME}"
echo "password: ${PASSWORD}"
echo "hostname: ${HOSTNAME}"

#Clean up
rm ${ERROR_FILE}

#end
