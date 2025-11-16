#!/bin/bash

VIDEO_CODEC="libx264"       # Video codec to use: libx264 (H.264), libx265 (H.265/HEVC), etc.
PRESET="slow"               # Encoding speed to compression ratio: ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow
PROFILE="high"              # H.264 profile: baseline, main, high
PIX_FMT="yuv420p"           # Pixel format
LEVEL="41"                  # H.264 level: 3.0, 3.1, 4.0, 4.1, 4.2, 5.0, etc.
CRF=23                      # Constant Rate Factor: lower is better quality (range 0-51)
CA="aac"                    # Audio codec to use: AAC, AC3, etc.
AC="2"                      # Number of audio channels
BA="192k"                   # Audio bitrate


FFMPEG_OPTS="-codec:v:0 $VIDEO_CODEC -preset $PRESET -profile:v:0 $PROFILE -level $LEVEL -crf $CRF -c:a $CA -ac $AC -b:a $BA -pix_fmt $PIX_FMT -movflags +faststart"

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
	local FILE="$(basename "${FILE_PATH}")"
	local NEW_FILE=$(echo ${OLD_FILE} | sed 's/\.[^.]*$/ x264&/')
	local CMD="ffmpeg -i '${FILE_PATH}' ${FFMPEG_OPTS} '${DIR}/${FILE%.*}.mp4'"
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

function check_dependencies() {
    if ! command -v ffprobe &> /dev/null; then
        echo -e "${RED}Error: ffprobe is not installed. Please install ffmpeg.${NC}"
        exit 1
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

check_dependencies

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
