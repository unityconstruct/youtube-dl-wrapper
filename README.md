# youtube-dl-wrapper
bash wrapper script for youtube-dl with menu to fetch an entire Playlist, Channel or just 1 URL as video/audio/both

## A Bash Wrapper Script for youtube-dl Util
- Just a shell script that uses standard profiles to simplify using youtube-dl
- Uses an .env file for storing user-configuration for application dir, batch file location & where to save downloads.
- Allows reading from batch files dedicated to 'purpose' such as urls, channels, playlists
- Has profiles for getting videos, audio versions _(or extractions)_ , or both.
- See the youtube-dl site: <https://youtube-dl.org/>

## Terminal Prompts

### output from the REQUIRED .env settings
	---------------------------------
	.CONFIG PARAMS in .env
	---------------------------------
	SCRIPT_DIR                              : 
	YTU_DEST                                : /media/media2/v/ytu
	YTU_LOG                                 : ytu.log
	YTU_LIST                                : ytu-list.txt
	OPT_USE_LIST                            : 
	OPT_ARCHIVE_FILE_VIDEO        : --download-archive /media/media2/ytu/archive-video.txt
	OPT_ARCHIVE_FILE_AUDIO        : --download-archive /media/media2/ytu/archive-audio.txt
	OPT_ARCHIVE_FILE              : --download-archive /media/media2/ytu/archive-video.txt
	OPT_BATCH_FILE                : --batch-file /media/media2/ytu/ytu-list.txt
	OPT_BATCH_FILE_URLS           : --batch-file /media/media2/ytu/ytu-list.txt
	OPT_BATCH_FILE_PLAYLIST       : --batch-file /media/media2/ytu/ytu-playlist.txt
	OPT_BATCH_FILE_CHANNEL        : --batch-file /media/media2/ytu/ytu-channellist.txt
	OPT_BATCH_FILE_VIDEOS         : --batch-file /media/media2/ytu/ytu-videoslist.txt
	---------------------------------

### Passed Args ( if any )
	---------------------------------
	Current URL                   : 
	Current DATEAFTER             : 
	Current List Setting          : 
	---------------------------------

### List locations ( build from env vars )
	---------------------------------
	Current List Location URLS    : --batch-file /media/media2/ytu/ytu-list.txt
	Current List Location PLAYLIST: --batch-file /media/media2/ytu/ytu-playlist.txt
	Current List Location CHANNEL : 
	Current List Location VIDEOS  : 
	---------------------------------

### Prompt1 - Read from a 'batch' list ?
	---------------------------------
	-----  READ from LIST? Y/N ------
	-----  OR    TAIL LOG? T --------
	---------------------------------
	
### Prompt2 - If NO, ENTER URL
	---------------------------------
	Read URL and DATEAFTER
	Type...>https://youtu.be/PtdYnhnoGI0
  
- CTRL-V saves typing
- Any URL youtube-dl takes can be entered
- a second PARAM for the DATEAFTER option can be entered also in the form of: YYYYMMDD


  
### Prompt3 - Media Type: Audio, Video, or Both
	---------------------------------
	Current media type: -f best/bestvideo+bestaudio
	  -----  Set media type ------   
	---------------------------------
	V - VIDEO
	A - AUDIO
	B - BOTH
	Select Option...: a
	---------------------------------
	A
	---------------------------------
	OPT_MEDIATYPE                 : -f bestaudio[ext=mp3]/bestaudio/best -x --audio-format mp3  --audio-quality 0 --keep-video --embed-thumbnail
	OPT_ARCHIVE_FILE              : --download-archive /media/media2/ytu/archive-audio.txt
	---------------------------------

### Prompt4 - Job Type: Single URL, Entire Playlist, All Videos, Entire Channel
    ---------------------------------------------------
    ----------- SELECT JOB TYPE ------------------------
    ----------------------------------------------------
    1 - SINGLE VIDEO      - list=--batch-file /media/media2/ytu/ytu-list.txt
    2 - PLAYLIST BY URL   - 
  	----------------------------------------------------
  	3 - PLAYLIST PAGE ALL - list=ytu-playlist.txt
  	4 - VIDEOS   PAGE ALL - list=ytu-videoslist.txt
  	5 - CHANNEL  PAGE ALL - list=ytu-channellist.txt
  	---------------------------------------------------
    6 - SINGLE VIDEO      - list=NOLIST
    7 - View LOG:                   - ytu.log
    8 - READ URL and DATEAFTER
    ----------------------------------------------------
    0 - EXIT
    Select option and press ENTER or CTRL-C to ABORT:  1
    ----------------------------------------------------
    
- These options do assume URL types
- Channel Page download expects: 

	https://www.youtube.com/channel/ABCDEFGHIKJ

- Videos Page download expects:

	https://www.youtube.com/channel/ABCDEFGHIKJ/videos

- Playlist works best with a Playlist Page _( but should scrape the playlist from ANY URL in the playlist)_ :
https://www.youtube.com/playlist?listABCDEFGHIKJ

  
### Command Output 
    ----------------------------------------------------
    ENTERED  : 1
    Geting single URL ( dont get entire playlist )
    READY TO START???? Press ENTER or CTRL-C to ABORTy
    NOT using BATCHFILE, using https://youtu.be/PtdYnhnoGI0
    COMMAND STRING: /media/media2/ytu/youtube-dl --console-title --verbose -f bestaudio[ext=mp3]/bestaudio/best -x --audio-format mp3  --audio-quality 0 --keep-video --embed-thumbnail  --write-all-thumbnails --write-description --write-info-json --ignore-errors --no-overwrites --restrict-filenames --download-archive /media/media2/ytu/archive-audio.txt --no-playlist  --output /media/media2/v/ytu/%(uploader)s/audio/%(title)s-%(id)s-audio.%(ext)s  https://youtu.be/PtdYnhnoGI0

