#!/bin/bash

readonly CLITIFY_VERSION="0.1"
readonly CLITIFY_HOST="127.0.0.1"
readonly CLITIFY_PORT="4030"
readonly CLITIFY_NAME="CLItify-bash"
readonly CLITIFY_EXECUTABLE_NAME=$(basename $0)

CLITIFY_VERBOSE=0

readonly PACKET_START="\$"
readonly PACKET_END="#"
readonly PACKET_IDENTIFIER_SEPARATOR="§"
readonly PACKET_ARGUMENT_SEPARATOR="|"

readonly CLITIFY_PACKET_ID_FILE_PATH="/tmp/clitify_packet_id"

packet_id=$(cat $CLITIFY_PACKET_ID_FILE_PATH)

if [ -z "$packet_id" ]
then
	packet_id=0
	$(echo $packet_id > $CLITIFY_PACKET_ID_FILE_PATH)
fi

usage()
{	
	cat <<- EOF
	Usage: $CLITIFY_EXECUTABLE_NAME ([-v] [<command>]) | [--help] [--version]
	
	Bash client used for controlling SpotDaDaemon Spotify daemon.
	
	COMMANDS:
	   login		Expects arguments <username> and <password>(optional - prompted for keyboard input if left out)
	   play			Play currently active track
	   pause		Pause track
	   logout		Log out current session
	   status		Get current session status
	   track		Control playback or get info about a track
	   playlist		Control playback or create/get info about playlists
	OPTIONS:
	   -v			Verbose output 
	   --version		Display version information.
	   --help		Show this help.
	   
	   
	Examples:
	   Log on and start playing a song
	   $CLITIFY_EXECUTABLE_NAME login myusername mypassword
	   $CLITIFY_EXECUTABLE_NAME track play spotify:track:6vyStw2mr0Eq3izsBjJj4R
	   
	EOF
	
	#echo "  play" 1>&2
	#echo "  select" 1>&2
	#echo "  list" 1>&2
}

main()
{
	while getopts ":v" opt; do
	  case $opt in
	    v)
		  CLITIFY_VERBOSE=1
		  shift
	      ;;
	    #\?)
	      #echo "Invalid option: -$OPTARG" >&2
	      #;;
	  esac
	done
	
	
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
			clitify_login "$2" "$3"
			exit 0
			;;
		logout)
			clitify_logout
			exit 0
			;;
		status)
			clitify_status
			exit 0
			;;
		play)
			clitify_play
			exit 0
			;;
		track)
			clitify_track "$2" "$3"
			exit 0
			;;
		playlist)
			clitify_playlist "$2" "$3"
			exit 0
			;;
		pause)
			clitify_pause
			exit 0
			;;
		user)
			clitify_user
			exit 0;
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
	
	if [ -z "$password" ]
	then
		echo "Enter password for $username:"
		read password
	fi
	
	if [ $CLITIFY_VERBOSE -eq 1 ]
	then
		echo "will send login command with following credentials"
		echo "username: $username"
		echo "password: $password"
	fi
	
	local sd_command="login"
	local sd_args=(
		"$username"
		"$password"
	)
	
	sendcommand "$sd_command" ${sd_args[@]}
}

clitify_logout()
{
	sendcommand "logout"
}

clitify_status()
{
	sendcommand "status"
}

clitify_track()
{
	local subcommand="$1"
	local track="$2"
	
	if [ "$subcommand" == "play" ]
	then
		sendcommand "track" "play" "$track"
	fi
}

clitify_playlist()
{
	local subcommand="$1"
	local track="$2"
	
	if [ "$subcommand" == "create" ]
	then
		sendcommand "playlist" "create" "$track"
	fi
}

clitify_play()
{
	sendcommand "play"
}

clitify_pause()
{
	sendcommand "pause"
}

clitify_user()
{
	local subcommand="$2"
	sendcommand "user" "$subcommand"
}

# command as first argument, then n number of arguments
sendcommand()
{
	local send_command="$1"
	
	local sleep_time="0.5"
	
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
	packet="$packet\r\n" # packets end with CRLF
	
	if [ $CLITIFY_VERBOSE -eq 1 ]
	then
		echo "sending packet: $packet"
		echo "to: $CLITIFY_HOST:$CLITIFY_PORT"
	fi
	
	# the echo line break in a while loop is a hack to make nc stay open until the socket is closed by server, then exit
	local response=$((echo -e $packet; (while true; do echo -e " "; sleep $sleep_time; done))| nc -c $CLITIFY_HOST $CLITIFY_PORT)
	
	if [ $CLITIFY_VERBOSE -eq 1 ]
	then
		echo "got response:"
		echo $response
	fi
	
	packet_id=$(($packet_id+1))
	
	if [ $packet_id -gt 9999 ]
	then
		packet_id=0
	fi
	
	$(echo $packet_id > $CLITIFY_PACKET_ID_FILE_PATH)
}

set -e
#set -u´

main "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
