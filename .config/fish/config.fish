# HISTORY
set -g fish_history_limit 5000

# ALIASES
alias hypr="exec start-hyprland"
alias lt="eza --icons=always --color=always"
alias diskcheck="df -B1 --output=used,size,pcent,fstype / | awk 'NR==2 {printf \"Disk (/): %.2f GiB / %.2f GiB (%s) - %s\n\", \$1/1024/1024/1024, \$2/1024/1024/1024, \$3, \$4}'"
alias memcheck="free -b | awk 'NR==2 {printf \"Memory: %.2f GiB / %.2f GiB (%.0f%%)\n\", \$3/1024/1024/1024, \$2/1024/1024/1024, (\$3/\$2)*100}'"

# FUNCTIONS
function mem
    if not set -q argv[1]
    echo "Usage: mem <proc1> [proc2 ...]"
    return 1
end
    set -l proc_regex (string join "|" $argv)
    smem -P "^(?!.*smem).*($proc_regex)" -k -t -s pss -r
end

# EXPORTS
set -gx EDITOR "foot --app-id=nvim -e nvim"
set -gx VISUAL "foot --app-id=yazi -e yazi"

fish_add_path /home/natto/.local/bin
set -g fish_greeting ""

