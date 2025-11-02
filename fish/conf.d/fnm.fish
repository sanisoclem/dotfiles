
# fnm
set FNM_PATH "/opt/homebrew/opt/fnm/bin"
if [ -d "$FNM_PATH" ]
  fnm env | source
end

# fnm
set FNM_PATH "/home/mel/.local/share/fnm"
if [ -d "$FNM_PATH" ]
  set PATH "$FNM_PATH" $PATH
  fnm env | source
end
