function trim-video --description 'Cut a video between two timestamps'
    argparse p/precise -- $argv
    or return

    if test (count $argv) -lt 3
        echo 'usage: trim-video [-p|--precise] INPUT START END [OUTPUT]' >&2
        return 1
    end

    set -l input $argv[1]
    set -l output $argv[4]
    test -n "$output"; or set output (__trim_video_default_output $input)

    set -l codec -c copy
    set -q _flag_precise; and set codec -c:v libx264 -crf 18 -preset medium -c:a aac -b:a 192k

    ffmpeg -ss $argv[2] -to $argv[3] -i $input $codec $output
end

function __trim_video_default_output --argument-names input
    echo (path change-extension '' $input)-trimmed(path extension $input)
end
