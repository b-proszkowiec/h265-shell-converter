#!/bin/bash

FRAME_RATE=24

function usage  {
	echo "Usage: ${0} [-r]" >&2
	echo '-r 		Convert files recursive.' >&2
	echo '-d 		Delete input file after convert.' >&2
	echo '-c 		Set custom frame rate.' >&2
	echo '-h		Show options' >&2
	exit 1
}

function convert {
	local FILE_PATH=${1}
	local DIR="$(dirname "${FILE_PATH}")"
	local OLD_FILE="$(basename "${FILE_PATH}")"
	local NEW_FILE=$(echo ${OLD_FILE} | sed 's/\.[^.]*$/ x265&/')
	local CMD="ffmpeg -i '${FILE_PATH}' -vcodec libx265 -crf ${FRAME_RATE} '${DIR}/${NEW_FILE}'"
	eval "$CMD"

	# Check to see if command succeeded
	if [[ "${?}" -ne 0 ]]
	then
  		echo "Error occurred while converting ${OLD_FILE}" >&2
  		exit 1
	fi

	# If delete flag is set remove original file
	if [[ ${DELETE_OLD} == 'true' ]]
	then
		mv "${DIR}/${NEW_FILE}" "${DIR}/${OLD_FILE}"
	fi
}

while getopts rc:dh OPTION
do
	case "${OPTION}" in
		r)
			RECURSE='true'
			;;
		c)
			FRAME_RATE="${OPTARG}"
			;;
		d)
			DELETE_OLD='true'
			;;
		h)
			usage
			;;
		?)
			usage
			;;
	esac
done

# Check whether ffmpeg is installed
if ! [ -x "$(command -v ffmpeg)" ]
then
  echo 'Error: ffmpeg is not installed.' >&2
  exit 1
fi

# Remove the options while leaving the remainning arguments
shift "$(( OPTIND - 1 ))"

# Do not allow file name argument while recursive
if [[ "${#}" -ne 0 && ${RECURSE} == 'true' ]]
then
	echo 'Invalid arguments while recursive' >&2
	exit 1
fi

# Convert files that were given in arguments
for FILE_PATH in "${@}"
do
	convert "${FILE_PATH}"
done

# Convert files recursive
if [[ ${RECURSE} == 'true' ]]
then
	for FILE_PATH in *
	do
	  if [[ $FILE_PATH == *.mp4 || $FILE_PATH == *.mkv ]]
	  then
			convert "${FILE_PATH}"
	  fi
	done
fi

exit 0
