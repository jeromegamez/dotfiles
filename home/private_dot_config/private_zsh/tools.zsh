# Initialize shell tools and integrations

# Cache generated completions until the corresponding executable changes.
_load_completion_cache() {
    local cache_name=$1 command_name=$2
    shift 2

    local executable=${commands[$command_name]}
    [[ -n "$executable" ]] || return

    local cache_dir="$XDG_CACHE_HOME/zsh/completions"
    local cache_file="$cache_dir/$cache_name.zsh"
    local cache_tmp="$cache_file.$$"
    mkdir -p "$cache_dir"

    if [[ ! -s "$cache_file" || "$executable" -nt "$cache_file" ]]; then
        if command "$@" >| "$cache_tmp"; then
            mv "$cache_tmp" "$cache_file"
        else
            rm -f "$cache_tmp"
        fi
    fi

    [[ -s "$cache_file" ]] && source "$cache_file"
}

_load_completion_cache uv uv uv generate-shell-completion zsh
_load_completion_cache uvx uvx uvx --generate-shell-completion zsh
_load_completion_cache chezmoi chezmoi chezmoi completion zsh
unfunction _load_completion_cache

if command -v aws_completer &>/dev/null; then
    autoload -Uz bashcompinit
    bashcompinit
    complete -C "${commands[aws_completer]}" aws
fi

if command -v op &>/dev/null; then
    # eval "$(op completion zsh)"; compdef _op op
    [[ -f "${XDG_CONFIG_HOME}/op/plugins.sh" ]] && source "${XDG_CONFIG_HOME}/op/plugins.sh"
fi

if [[ -f "$XDG_DATA_HOME/google-cloud-sdk/completion.zsh.inc" ]]; then
    source "$XDG_DATA_HOME/google-cloud-sdk/completion.zsh.inc"
fi

if command -v direnv &>/dev/null; then
    eval "$(direnv hook zsh)"
fi

# Initialize zoxide
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

# Initialize fzf (fuzzy finder)
if command -v fzf &>/dev/null; then
    # Use fd if available (respects .gitignore by default)
    if command -v fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f'
        export FZF_CTRL_T_COMMAND='fd --type f'
        export FZF_ALT_C_COMMAND='fd --type d'
    fi

    source <(fzf --zsh)
fi
