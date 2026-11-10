function __json_rename_keys --argument-names case
    jq --arg case $case '
        def words:
            gsub("(?<a>[a-z0-9])(?<b>[A-Z])"; "\(.a) \(.b)")
            | gsub("(?<a>[A-Z])(?<b>[A-Z][a-z])"; "\(.a) \(.b)")
            | [splits("[-_ ]+")]
            | map(select(length > 0))
            | map(if test("^[A-Z0-9]+$") then ascii_downcase else . end);
        def capitalize: (.[:1] | ascii_upcase) + .[1:];
        def pascal: words | map(capitalize) | join("");
        def camel: pascal | (.[:1] | ascii_downcase) + .[1:];
        def snake: words | map(ascii_downcase) | join("_");
        def kebab: words | map(ascii_downcase) | join("-");
        def rename:
            if $case == "camel" then camel
            elif $case == "pascal" then pascal
            elif $case == "snake" then snake
            else kebab
            end;
        walk(if type == "object" then with_entries(.key |= rename) else . end)
    '
end
