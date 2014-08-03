#!/bin/bash

CLITIFY_VERSION="0.1"

CLITIFY_HOST="127.0.0.1"
CLITIFY_PORT="4030"

CLITIFY_NAME="CLItify-bash"
CLITIFY_EXECUTABLE_NAME="clitify.sh"

PACKET_START="\$"
PACKET_END="#"
PACKET_IDENTIFIER_SEPARATOR="§"
PACKET_ARGUMENT_SEPARATOR="|"

packet_id=0

usage()
{	
	cat <<- EOF
	Usage: $CLITIFY_EXECUTABLE_NAME [<command>] | [--help] [--version]
	
	Bash client used for controlling SpotDaDaemon Spotify daemon.
	
	COMMANDS:
	   login		Expects arguments <username> and <password>
	   
	OPTIONS:
	   --version		Display version information.
	   --help		Show this help.
	   
	   
	Examples:
	   Log on and start playing a song
	   $CLITIFY_EXECUTABLE_NAME login myusername mypassword
	   $CLITIFY_EXECUTABLE_NAME play spotify:track:6vyStw2mr0Eq3izsBjJj4R
	EOF
	
	#echo "  play" 1>&2
	#echo "  select" 1>&2
	#echo "  list" 1>&2
}

main()
{
	case "$1" in
	    --help)
	        usage
			exit 0
	        ;;
		--version)
			echo "$CLITIFY_NAME v$CLITIFY_VERSION"
			exit 0
			;;
		login)
			echo "login"
			clitify_login "$2" "$3"
			exit 0
			;;
	    *)
	        usage
			exit 1
	        ;;
	esac
}

clitify_login()
{
	local username="$1"
	local password="$2"
	
	echo "username: $username"
	echo "password: $password"
	
	local sd_command="login"
	local sd_args=(
		"$username"
		"$password"
	)
	
	sendcommand "$sd_command" ${sd_args[@]}
	
	echo $PACKET_END
}


# command as first argument, then n number of arguments
sendcommand()
{
	local send_command="$1"
	
	local packet_data="$send_command"
	local packet="$PACKET_START$packet_id$PACKET_IDENTIFIER_SEPARATOR"
	
	local i=0
	for arg in "$@"
	do
		((i++))
		if [ $i -eq 1 ]
		then
			continue # skip command - just looking for arguments
		fi
		
		packet_data="$packet_data$PACKET_ARGUMENT_SEPARATOR$arg"
	done
	
	packet=$packet"$packet_data"$PACKET_END
	echo $packet | nc -cv $CLITIFY_HOST $CLITIFY_PORT
	
	packet_id=$(($packet_id+1))
}

set -e
#set -u

main $1 $2 $3 $4 $5 $6 $7 $8 $9
