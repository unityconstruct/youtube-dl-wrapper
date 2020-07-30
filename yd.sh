#!/bin/sh
#------------------------------------
# YouTubeDL Wrapper Script
# youtube-dl DOWNLOAD URL
#------------------------------------
# http://ytdl-org.github.io/youtube-dl/download.html
# To install it right away for all UNIX users (Linux, OS X, etc.), type:
#   sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
#   sudo chmod a+rx /usr/local/bin/youtube-dl
# If you do not have curl, you can alternatively use a recent wget:
#   sudo wget https://yt-dl.org/downloads/latest/youtube-dl -O /usr/local/bin/youtube-dl
#   sudo chmod a+rx /usr/local/bin/youtube-dl
#------------------------------------
# https://askubuntu.com/questions/438376/how-to-download-all-videos-on-a-youtube-channel
# https://github.com/ytdl-org/youtube-dl/blob/master/README.md#options
#------------------------------------
# YouTube JS for scripting playlist items
#
# els = $x('//a[@id="thumbnail" and contains(@href,"list=RDEMUQpJPFvIsr9_f191PAyFNA&index=")]')
# for (each in els){
#   console.log(els[each].href)
# }
#------------------------------------

# setver version manually here
ydver="v2020.0721.10" ;  echo "--------------------"; echo "yd Version: $ydver"; echo "--------------------";





#
# If URL has no value, call function prompting to 
#   USE LIST or ENTER URL
#
use_list_yn () {
	echo "(IN use_list_yn....)" ;
	print_settings urllist
	if [ -n "$URL" ] ; then
		OPT_USE_LIST="N";
	else 
		read_list_option;
	fi

}

#
# Prompt for USE LIST or ENTER URL/DATE
#
read_list_option () {
	echo "( IN read_list_option.... )" ;
	print_settings "lists"
	echo "---------------------------------";
	echo "-----  READ from LIST? Y/N ------ ";
	echo "-----  OR    TAIL LOG? T -------- ";
	echo "--------------------------------- ";
	read -p "Select Option...: " RESPLIST
	echo "Selected:  $RESPLIST"
	echo "---------------------------------";
	
	if [ "$RESPLIST" = "T" -o  "$RESPLIST" = "t" ] ; then
		taillog
		exiting
	elif [ "$RESPLIST" = "Y" -o  "$RESPLIST" = "y" ] ; then
		OPT_USE_LIST="Y";
	else 
		OPT_USE_LIST="N";
		set_url_date
	fi

}

#
# Prompt for Audio/Video/Both
#   assign 
#
set_media_type () {
	quit_if_noUrl_NoPlaylist

	echo "---------------------------------";
	echo "Current media type: $OPT_MEDIATYPE";
	echo "  -----  Set media type ------   ";
	echo "---------------------------------";
	echo "V - VIDEO";
	echo "A - AUDIO";
	echo "B - BOTH";
	read -p "Select Option...: " OPT_AV ;
	echo "---------------------------------";
	echo "Selected: $OPT_AV"

	# set OPT_MEDIATYPE & OPT_ARCHIVE_FILE based on format selected
	if [ "$OPT_AV" = "A" -o  "$OPT_AV" = "a" ] ; then
		OPT_MEDIATYPE="-f bestaudio[ext=mp3]/bestaudio/best -x --audio-format mp3  --audio-quality 0 --keep-video --embed-thumbnail" ;
		OPT_ARCHIVE_FILE="$OPT_ARCHIVE_FILE_AUDIO" ;
	elif [ "$OPT_AV" = "B" -o  "$OPT_AV" = "b" ] ; then
		OPT_MEDIATYPE="-f best/bestvideo+bestaudio,bestaudio[ext=mp3] -x --audio-format mp3  --audio-quality 0  --keep-video --embed-thumbnail" ;
		OPT_ARCHIVE_FILE="$OPT_ARCHIVE_FILE_VIDEO" ;
	else 
		OPT_MEDIATYPE="-f best/bestvideo+bestaudio" ; #-f bestvideo+bestaudio/best
		OPT_ARCHIVE_FILE="$OPT_ARCHIVE_FILE_VIDEO" ; 
	fi
	print_settings "mediatype"	
	
}

set_job_type () {
	echo "----------------------------------------------------";
	echo "----------- SELECT JOB TYPE ------------------------";
	echo "----------------------------------------------------";
	echo "1 - SINGLE VIDEO      - list=$OPT_BATCH_FILE_URLS";  # https://www.youtube.com/watch?v=hECs8372M8A
	echo "2 - PLAYLIST BY URL   - ";
	echo "----------------------------------------------------";
	echo "3 - PLAYLIST PAGE ALL - list=$YTU_PLAYLIST";
	echo "4 - VIDEOS   PAGE ALL - list=$YTU_VIDEOSLIST";
	echo "5 - CHANNEL  PAGE ALL - list=$YTU_CHANNELLIST";
	echo "---------------------------------------------------";
	echo "6 - SINGLE VIDEO      - list=NOLIST" ;  
	echo "7 - View LOG:                   - $YTU_LOG";
	echo "8 - READ URL and DATEAFTER";  
	echo "----------------------------------------------------";
	echo " 0 - EXIT";
	read -p "Select option and press ENTER or CTRL-C to ABORT:  " OPTS
	OPT_JOB_TYPE="$OPTS"
	echo "----------------------------------------------------"
	echo "----------------------------------------------------"
	echo " ENTERED  : $OPT_JOB_TYPE";	
	#echo " TARGET URL: $URL";
	#echo " DATEAFTER SET TO: _ $OPTS_DATEAFTER _";	
	#echo "----------------------------------------------------";	
	
}

set_output_file () {
	WHAT="$1";

	case "$WHAT" in
	"single") #
		OPT_PLAYLIST_YESNO="${OPT_PLAYLIST_NO}";
		
		if [ "$OPT_AV" = "A" -o  "$OPT_AV" = "a" ] ; then
			OPT_OUTPUT_FILE="$OPT_OUTPUT_FILE_SINGLE_AUDIO"
		else 
			OPT_OUTPUT_FILE="$OPT_OUTPUT_FILE_SINGLE_VIDEO"
		fi
		;;
	"playlist") #
		OPT_PLAYLIST_YESNO="${OPT_PLAYLIST_YES}";
		
		if [ "$OPT_AV" = "A" -o  "$OPT_AV" = "a" ] ; then
			OPT_OUTPUT_FILE="$OPT_OUTPUT_FILE_PLAYLIST_AUDIO"
		else 
			OPT_OUTPUT_FILE="$OPT_OUTPUT_FILE_PLAYLIST_VIDEO"
		fi
		;;
	*)  #
		;;
	esac

}

ytuExecute () {
	
	case "$OPT_JOB_TYPE" in

	## NO BATCHFILE -------------------------------------------------------------------------
	 
	"6") echo "Getting download urls from list: $YTU_LIST";
		set_output_file "single" ;
		run_command
		;;
		
	"2") echo "Geting single URL ( get entire playlist )";      # https://www.youtube.com/watch?v=QYrjvLFT_B4&list=PLUjQ3tZwzZPG3tA6BjnjhAJVnZ8n4smUQ&index=4
		set_output_file "playlist"
		run_command 
		;;

	## USE BATCHFILE -------------------------------------------------------------------------
		
	# URL SINGLE	
	"1") echo "Geting single URL ( dont get entire playlist )"; # https://www.youtube.com/watch?v=hECs8372M8A
		set_output_file "single" ;
		OPT_BATCH_FILE="$OPT_BATCH_FILE_URLS";
		run_command
		;;		
	# PLAYLIST PAGE
	"3") echo "Geting playlist by URL";     # https://www.youtube.com/playlist?list=PLUjQ3tZwzZPG3tA6BjnjhAJVnZ8n4smUQ
		set_output_file "playlist"
	OPT_BATCH_FILE="$OPT_BATCH_FILE_PLAYLIST"
		run_command
		;;
	# VIDEOS PAGE
	"4") echo "Geting all videos by URL";   # https://www.youtube.com/channel/UC8butISFwT-Wl7EV0hUK0BQ/videos
		set_output_file "single" ;
	OPT_BATCH_FILE="$OPT_BATCH_FILE_VIDEOS"
		set_date
		run_command
		;;
	# CHANNEL PAGE
	"5") echo "Geting entire channel by URL";  # https://www.youtube.com/channel/UCIJGI_3XgnfUaSNQD8D2IMQ
		set_output_file "single" ;
	OPT_BATCH_FILE="$OPT_BATCH_FILE_CHANNEL"
		set_date
		run_command
		;;



	## MISC -------------------------------------------------------------------------

	"7") 
		echo "-------------------------------------------------"
		echo "REVIEW LOGFILE: ${YTU_LOG}"
		echo "Press ENTER or CTRL-C to ABORT"
		echo "-------------------------------------------------"
		read -p ">" pausing
		viewlog
		;;
	"8") echo "Read URL and DATEAFTER"
		read -p "Type...>" URL RESP
		
		if [ "$RESP" = "" ] ; then
			OPTS_DATEAFTER=
		else
			OPTS_DATEAFTER="--dateafter ${RESP}"
		fi
		
		if [ "$URL" = "" ] ; then
			echo "URL is empty, exiting.."
			exit 1
		fi
		run_command
		;;
	"0") exit 0;
		;;
	*)
		;;
	esac;
	
	# write DONE msg to log
	annotate_file_dldone
	
}

run_command () {
	read -p "READY TO START???? Press ENTER or CTRL-C to ABORT" pausing ;
	
	#OPTIONS that are always used
	OPTS_STATIC="$OPT_CONSOLE_TITLE $OPT_VERBOSE $OPT_MEDIATYPE  $OPT_WRITETHUMBNAIL_ALL $OPT_WRITE_DESCRIPTION $OPT_WRITE_INFO_JSON $OPT_IGNORE_ERRORS $OPT_NO_OVERWRITES $OPT_RESTRICT_FILENAMES $OPT_ARCHIVE_FILE";
	
	#OPTIONS that changed based on job-type
	OPTS_DYNAMIC="${OPT_PLAYLIST_YESNO}  ${OPT_OUTPUT_FILE} ${OPTS_DATEAFTER}";

	# add '--batch-file' if reading from a LIST
	if [ "$OPT_USE_LIST" = "Y" -o "$OPT_USE_LIST" = "y" ] ; then
		echo "updating option string: BEFORE: $OPTS_DYNAMIC" ;
		URL= ; 
		OPTS_DYNAMIC="$OPTS_DYNAMIC $OPT_BATCH_FILE" ;
		echo "updating option string: AFTER : $OPTS_DYNAMIC" ;
	else
		echo "NOT using BATCHFILE, using $URL" ;
	fi

	# echo "RUNNING: youtube-dl $OPTS_ALL $OPTS_JOB $URL";
	CMD="${YTU_APP_DIR}/youtube-dl -v ${OPTS_STATIC} ${OPTS_DYNAMIC} ${URL}" ;
	echo "COMMAND STRING: ${CMD}" ;

	## CALL YOUTUBE-DL   # https://www.youtube.com/watch?v=BpqlOB1AzCQ
	annotate_file_dlstart
	$CMD >> "$YTU_LOG" 2>&1 & tail --lines=100 "$YTU_LOG"  
	want_to_tail ;

}

#
# Prompt to tail the LOG after starting yd
#
want_to_tail () {
	read -p "Tail the logfile? ( or exit? )" RESP ;
	echo "Typed: $RESP" ;
	if [ "$RESP" = "Y" -o  "$RESP" = "y" ] ; then
		tail -f "$YTU_LOG" ;
	else
		exit 0 ; 
	fi

}


getTimestamp () {
 TIMESTAMP=`date +"%Y-%m%d-%H%M"`
 echo "Timestamp: ${today}" ;

}

exiting () {
	echo "EXITING.....";
	exit 0;
	
}

annotate_file_dlstart () {
	getTimestamp
	local MESSAGE="


############################################################################
####    DOWNLOADS STARTED
####    ${JOB} ON : ${TIMESTAMP} 
############################################################################


" 
	echo "$MESSAGE"  >> "$YTU_LOG"
	
}

annotate_file_dldone () {
	getTimestamp 
	local MESSAGE="


############################################################################
####    DOWNLOADS COMPLETE
####    ${JOB} ON : ${TIMESTAMP} 
############################################################################


" 
	echo "$MESSAGE"  >> "$YTU_LOG"
	
}

viewlog () {
	less "${YTU_LOG}"
	echo "EXITING.....";
	
}

taillog () {
 echo "Showing Logfile at $YTU_LOG";
 tail --lines=30 -f "$YTU_LOG";
 
}

set_date () {

	echo "Read DATEAFTER ( ie. 20201031) ..."
	echo "Press ENTER for NO DAT FILTERING"
	read -p "Type...>" RESP

	if [ "$RESP" = "" ] ; then
		OPTS_DATEAFTER=
	else
		OPTS_DATEAFTER="--dateafter ${RESP}"
	fi

}

set_url_date () {

	echo "Read URL and DATEAFTER"
	read -p "Type...>" URL RESP
	
	if [ "$RESP" = "" ] ; then
		OPTS_DATEAFTER=
	else
		OPTS_DATEAFTER="--dateafter ${RESP}"
	fi
}



#
# Common function for printing settigs
#
print_settings () {
	echo "( IN print settings )" ;
	WHAT="$1" ;
	if [ -z "$WHAT" ] ; then
		WHAT="urllist" ;
	fi
	
	
	echo "---------------------------------" ;
	case "$WHAT" in
	"lists") # print list locations
		echo "Current List Location URLS    : $OPT_BATCH_FILE_URLS" ;
		echo "Current List Location PLAYLIST: $OPT_BATCH_FILE_PLAYLIST" ;
		echo "Current List Location CHANNEL : $OPT_BATCH_FILE_CHANNELLIST" ;
		echo "Current List Location VIDEOS  : $OPT_BATCH_FILE_VIDEOSLIST" ;
	;;
	"urllist") # print url, dateafter, and uselist values
		echo "Current URL                   : $URL" ;
		echo "Current DATEAFTER             : $OPTS_DATEAFTER" ;
		echo "Current List Setting          : $OPT_USE_LIST" ;
	;;
	"mediatype") # print mediatype for audio/video
		echo "OPT_MEDIATYPE                 : $OPT_MEDIATYPE" ;
		echo "OPT_ARCHIVE_FILE              : $OPT_ARCHIVE_FILE" ;
	;;
	"envvars") #
		echo ".CONFIG PARAMS in .env";
		echo "---------------------------------" ;
		echo "SCRIPT_DIR			        : $SCRIPT_DIR"
		echo "YTU_DEST  			        : $YTU_DEST"
		echo "YTU_LOG   			        : $YTU_LOG"
		echo "YTU_LIST  			        : $YTU_LIST"
		echo "OPT_USE_LIST			        : $OPT_USE_LIST"
		echo "OPT_ARCHIVE_FILE_VIDEO        : $OPT_ARCHIVE_FILE_VIDEO"
		echo "OPT_ARCHIVE_FILE_AUDIO        : $OPT_ARCHIVE_FILE_AUDIO"
		echo "OPT_ARCHIVE_FILE              : $OPT_ARCHIVE_FILE"
		echo "OPT_BATCH_FILE                : $OPT_BATCH_FILE"
		echo "OPT_BATCH_FILE_URLS           : $OPT_BATCH_FILE_URLS"
		echo "OPT_BATCH_FILE_PLAYLIST       : $OPT_BATCH_FILE_PLAYLIST"
		echo "OPT_BATCH_FILE_CHANNEL        : $OPT_BATCH_FILE_CHANNEL"
		echo "OPT_BATCH_FILE_VIDEOS         : $OPT_BATCH_FILE_VIDEOS"
	;;
	*)  # print nothing
	;;
	esac
	echo "---------------------------------" ;

}

#
# QUIT if URL=null & USE PLAYLIST = N
#
quit_if_noUrl_NoPlaylist () {
	# if no url and use playlist = n, just QUIT!
	if [ -z "$URL" -a  "$OPT_USE_LIST" = "N" ] ; then
		echo "EXITING!!! No URL, OPT_USE_LIST = N" ;
		exit 0 ;
	fi
}



init_getvars () {
	# export .env vars & clear screen 
	VARFILE_REMOTE="/media/media2/ytu/.ytu";
	VARFILE_LOCAL="/mnt/media2/ytu/.ytu";
	
	if [ -e "$VARFILE_REMOTE" ] ; then
		VARFILE="$VARFILE_REMOTE" ;
	elif [ -e "$VARFILE_LOCAL" ] ; then
		VARFILE="$VARFILE_LOCAL" ;
	else
		echo "ERROR: FILE NOT FOUND: $VARFILE_REMOTE  ::OR:: $VARFILE_LOCAL" ;
	 	exit 1 ;
	fi
	
	echo "exporting env vars from: $VARFILE."
	export $(grep -v '^#' "$VARFILE"  | xargs)
	
	#export $(grep -v '^#' /home/uc/s/.env | xargs)
	#export $(grep -v '^#' /home/silosix/s/.env | xargs)

	#
	#clear
	#

}


# https://www.youtube.com/watch?v=nO9N0TgAblE
echo "#########################################################################";
echo "######################### INIT  #########################################";
echo "#########################################################################";

init_getvars


#cd to remote ytu app dir so .env & other items are local
curDir="$(pwd)" ;                     printf "Current dir: $curDir \n" ; 
echo "Change dir to : $YTU_APP_DIR" ; cd "$YTU_APP_DIR" ;
curDir="$(pwd)" ;                     printf "Current dir: $curDir \n" ;

# 1ST PARAM = URL | 2ND PARAM = DATEAFTER ( 20191231 )
URL="$1" ;                 # assign 1st param to URL
OPTS_DATEAFTER="$2" ;      # assign 2nd param to DATE
print_settings "urllist" ; # echo the passed args


echo "######################### STATIC VARS #########################################";
# STATIC VARS - ALWAYS USED
OPT_CONSOLE_TITLE="--console-title"
OPT_VERBOSE="--verbose"
OPT_WRITETHUMBNAIL="--write-thumbnail"
OPT_WRITETHUMBNAIL_ALL="--write-all-thumbnails"
OPT_WRITE_DESCRIPTION="--write-description"
OPT_WRITE_INFO_JSON="--write-info-json"
OPT_IGNORE_ERRORS="--ignore-errors"
OPT_NO_OVERWRITES="--no-overwrites"
OPT_RESTRICT_FILENAMES="--restrict-filenames"
OPT_ARCHIVE_FILE_VIDEO="--download-archive $YTU_APP_DIR/archive-video.txt"
OPT_ARCHIVE_FILE_AUDIO="--download-archive $YTU_APP_DIR/archive-audio.txt"
OPT_ARCHIVE_FILE="$OPT_ARCHIVE_FILE_VIDEO"
OPT_BATCH_FILE="--batch-file $YTU_APP_DIR/$YTU_LIST"
OPT_BATCH_FILE_URLS="--batch-file $YTU_APP_DIR/$YTU_LIST"
OPT_BATCH_FILE_PLAYLIST="--batch-file $YTU_APP_DIR/$YTU_PLAYLIST"
OPT_BATCH_FILE_CHANNEL="--batch-file $YTU_APP_DIR/$YTU_CHANNELLIST"
OPT_BATCH_FILE_VIDEOS="--batch-file $YTU_APP_DIR/$YTU_VIDEOSLIST"

echo "######################### DYNAMIC VARS ########################################";	
# DYNAMIC VARS
OPT_JOB_TYPE=
OPT_PLAYLIST_YESNO=
OPT_PLAYLIST_YN=""
OPT_AV="V"
OPT_MEDIATYPE="-f best/bestvideo+bestaudio"
OPT_OUTPUT_FILE=
OPT_JOB_SPECIFIC=
# set in function()
OPT_PLAYLIST_NO="--no-playlist";
OPT_OUTPUT_FILE_SINGLE_VIDEO="--output $YTU_DEST/%(uploader)s/%(title)s-%(id)s.%(ext)s";
OPT_OUTPUT_FILE_SINGLE_AUDIO="--output $YTU_DEST/%(uploader)s/audio/%(title)s-%(id)s-audio.%(ext)s";
OPT_PLAYLIST_YES="--yes-playlist" ;
# Creating Filename: By playlist
OPT_OUTPUT_FILE_PLAYLIST_VIDEO="--output       $YTU_DEST/%(uploader)s/%(playlist)s/%(playlist)s-%(playlist_index)s-%(uploader)s-%(title)s-%(id)s.%(ext)s";
OPT_OUTPUT_FILE_PLAYLIST_AUDIO="--output $YTU_DEST/%(uploader)s/audio/%(playlist)s/%(playlist)s-%(playlist_index)s-%(uploader)s-%(title)s-%(id)s.%(ext)s";
		# Creating Filename: By uploader
		#OPT_OUTPUT_FILE_PLAYLIST_VIDEO="--output $YTU_DEST/%(uploader)s/%(playlist)s/%(playlist_index)s-%(title)s-%(id)s.%(ext)s";
		#OPT_OUTPUT_FILE_PLAYLIST_VIDEO="--output $YTU_DEST/%(uploader)s/%(playlist)s/%(playlist_index)s-%(title)s-%(id)s.%(ext)s";
# AGGREGATE ALL VARS TO THESE THEN CALL YTDL
OPTS_DYNAMIC=
OPTS_ALL=	





echo "######################### CALL: START #####################################################";
print_settings "envvars" ; 
use_list_yn ;				# prompt to use list or enter URL 
set_media_type "$URL" "$2" ;	# prompt for Audio or Video
set_job_type ;				# prompt for Type of Job ( playlist, channel, single URL
ytuExecute ;				# call youtube-dl with options

echo "######################### CALL: END   #####################################################";
exit 0;





# SPARE OPTIONS	
# --config-location PATH
# --playlist-reverse
# --download-archive FILE
# --batch-file FILE
# --console-title

#"$OPT_CONSOLE_TITLE"
#"$OPT_VERBOSE"
#"$OPT_MEDIATYPE"         
#"$OPT_WRITETHUMBNAIL"
#"$OPT_WRITE_DESCRIPTION"
#"$OPT_WRITE_INFO_JSON"
#"$OPT_IGNORE_ERRORS"
#"$OPT_NO_OVERWRITES"
#"$OPT_RESTRICT_FILENAMES"

#  YOUTUBE-DL OPTION INIT PER JOB - NEVER USED
#JOB_SINGLEPLAYLIST_NO=
#JOB_SINGLEPLAYLIST_YES=
#JOB_PLAYLIST_ALL=
#JOB_VIDEOS_ALL=
#JOB_CHANNEL_ALL=


# -------------------------------------------------------------------------
#  NOT USED 
# -------------------------------------------------------------------------


#run_command () {  # $URL, $OPTS_ALL, $OPTS_JOB
#	OPTS_ALL="--console-title --verbose -f $OPT_MEDIATYPE --write-thumbnail --write-description --write-info-json --ignore-errors --no-overwrites --restrict-filenames $OPTS_DATEAFTER";
#
#	# echo "RUNNING: youtube-dl $OPTS_ALL $OPTS_JOB $URL";
#	CMD="youtube-dl $OPTS_ALL  $OPTS_JOB $OPTS_DATEAFTER $URL"
#	echo "COMMAND STRING: $CMD" 
#	$CMD
#} 



	move_mp3 () {
		# NOT NEEDED, UNLESS THE FILENAME CONTAINS SPACES & SPECIALS CHARS THAT INDUCE THE '<FILENAME>' QUOTE WRAPPING BY LINUX OS
		if [ "$OPT_AV" = "A" -o  "$OPT_AV" = "a" ] ; then
			mv *.mp3 "$YTU_DEST_MP3"
		fi
		
	}


	cliSetURLOrUsePlaylist () {
	
		echo "IN cliSetURLOrUsePlaylist...";
		echo "CURRENT - OPT_USE_LIST: $OPT_USE_LIST"
		echo "CURRENT - URL PASSED  : _ $URL _";
	
		# $1 ($URL ) from MAIN = $1 for THIS function
		if [ "$1" = "" ] ; then
			echo "URL is EMPTY..."
			use_list_yn
		else
			URL="$1";
			echo "URL PASSED: _ $URL _";
			# if there's a 2nd arg, set it as the date for --dateafter=OPTS_DATEAFTER 
			cliSetDateAfter "$2"
		fi
		
	}
	
	cliSetDateAfter () {
		# set date if entered & valid ( add len check )
		if [ "$1" != "" ]; then # $2 from MAIN, but $1 for THIS function
			OPTS_DATEAFTER="--dateafter $2"; #YYYYMMDD OR now/#days/#months/#years
		else
			OPTS_DATEAFTER=      # ASSIGN TO EMPTY SO IT WON'T BE USED
		fi
		
	}

#	
#	cliEchoPassedArgs () {
#	
#		echo "IN cliEchoPassedArgs...";
#	
#		echo "------------------------"
#		echo "PASSED PARAMS: "
#		echo "------------------------"
#		echo "1-URL           : $URL"
#		echo "2-OPTS_DATEAFTER: $OPTS_DATEAFTER"
#		echo "3-OPT_USE_LIST  : $OPT_USE_LIST"
#		echo "------------------------"
#		
#	}

# -------------------------------------------------------------------------
# NOT USED
# -------------------------------------------------------------------------


