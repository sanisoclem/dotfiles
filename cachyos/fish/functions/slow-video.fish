function slow-video --description 'Slow a video down by a factor (2 = half speed)'
    if test (count $argv) -lt 2
        echo 'usage: slow-video INPUT FACTOR [OUTPUT]' >&2
        return 1
    end

    set -l input $argv[1]
    set -l factor $argv[2]
    set -l output $argv[3]
    test -n "$output"; or set output (__slow_video_default_output $input)

    ffmpeg -i $input \
        -filter:v "setpts=$factor*PTS" \
        -filter:a (__slow_video_atempo_chain $factor) \
        -c:v libx264 -crf 18 -preset medium -c:a aac -b:a 192k \
        $output
end

function __slow_video_default_output --argument-names input
    echo (path change-extension '' $input)-slow(path extension $input)
end

function __slow_video_atempo_chain --argument-names factor
    set -l slowest_atempo 0.5
    set -l tempo (math 1 / $factor)
    set -l chain
    while test $tempo -lt $slowest_atempo
        set -a chain atempo=$slowest_atempo
        set tempo (math $tempo / $slowest_atempo)
    end
    set -a chain atempo=$tempo
    string join , $chain
end
