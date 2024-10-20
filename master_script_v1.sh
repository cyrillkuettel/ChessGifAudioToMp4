#!/bin/bash

# ffmpeg -i input.gif output.mp4

# clean up
rm *.opus
rm *.gif
rm *.webm

# Delete all .mp4 files except those ending with *_.mp4
find . -type f -name "*.mp4" ! -name "*_.mp4" -exec rm {} \;

# Set static variables (replace with actual values)
GIF_URL="https://lichess1.org/game/export/gif/black/bXCaVefv.gif?theme=blue3&piece=cburnett"

#danish
# GIF_URL="https://lichess1.org/game/export/gif/white/eDEBFpai.gif?theme=blue3&piece=cburnett"

MUSIC_URL="https://www.youtube.com/watch?v=lTH1EJZKB-I"


# Get the audio using yt-dlp and store in file music.opus
# yt-dlp -x "$MUSIC_URL" -o music -k

# Get the video using curl and create an MP4 from the GIF
curl "$GIF_URL" --output foo.gif
ffmpeg -i foo.gif input.mp4  # Convert GIF to MP4

factor=$(python3 <<EOF
import subprocess

def get_duration(filename):
    result = subprocess.run(
        ['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'default=noprint_wrappers=1:nokey=1', filename],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT
    )
    return float(result.stdout)

video_duration = get_duration('input.mp4')
audio_duration = get_duration('music.mp3')

factor = video_duration / audio_duration
print(factor)
EOF
)


# The mp4 is stretched to the lenght of the audio.
# Strategy: len(video) = len(song) 
# The original duration of the soundtrack is preserved. 
# The $factor denotes the ratio between the length of the music & video. 

ffmpeg -i input.mp4 -filter_complex "setpts=PTS/$factor" stretched.mp4


# filename: Generate a random two-letter string with letters and numbers
# output: Combine audio and video using ffmpeg 
timestamp=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 2 | head -n 1)
output_file="${timestamp}_.mp4"
ffmpeg -i stretched.mp4 -i music.mp3 -c:v copy -c:a aac -strict experimental "$output_file"
echo "File created: $output_file"
