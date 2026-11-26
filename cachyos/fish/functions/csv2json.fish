function csv2json --description 'Convert simple CSV (header row, no quoted commas) to a JSON array'
    jq -Rn '[inputs | sub("\r$";"") | split(",")] | .[0] as $h | .[1:] | map([$h, .] | transpose | map({(.[0]): .[1]}) | add)' $argv
end
