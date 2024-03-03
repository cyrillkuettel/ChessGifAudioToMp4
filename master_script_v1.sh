#!/bin/bash

rm *.mp4 
rm *.opus
rm *.gif
rm *.webm


# Set static variables (replace with actual values)
GIF_URL="https://lichess1.org/game/export/gif/black/bXCaVefv.gif?theme=blue3&piece=cburnett"

MUSIC_URL="https://www.youtube.com/watch?v=lTH1EJZKB-I"

# Get the audio using yt-dlp and store in music.opus
yt-dlp -x "$MUSIC_URL" -o music -k

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
audio_duration = get_duration('music.opus')

factor = video_duration / audio_duration
print(factor)
EOF
)


# this approach is used:

    # len(video) = len(song)
    #
# to prevent changing the original duration of the soundtrack.

ffmpeg -i input.mp4 -filter_complex "setpts=PTS/$factor" stretched.mp4

# Overlay audio
# Combine audio and video using ffmpeg
# ffmpeg -i input_1.mp4 -i music.opus -c:v copy -c:a aac -strict experimental _.mp4