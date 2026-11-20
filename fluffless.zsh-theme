# Fluffless Prompt — Oh My Zsh theme
# Warm, quiet and dense. No boxes, no glyphs, no retro phosphor glow.

setopt PROMPT_SUBST

: ${FLUFFLESS_FG:=250}
: ${FLUFFLESS_DIM:=244}
: ${FLUFFLESS_MUTED:=238}
: ${FLUFFLESS_ACCENT:=181}
: ${FLUFFLESS_ERROR:=203}
: ${FLUFFLESS_GIT_CACHE_TTL:=5}
: ${FLUFFLESS_SHOW_GIT:=1}
: ${FLUFFLESS_SHOW_CLOCK:=1}
: "${FLUFFLESS_GIT_CACHE_DIR:=${PWD}}"
if (( ! ${+_fluffless_prompt_initialized} )); then
    _fluffless_prompt_dim="%F{$FLUFFLESS_DIM}"
    _fluffless_prompt_muted="%F{$FLUFFLESS_MUTED}"
    _fluffless_prompt_accent="%F{$FLUFFLESS_ACCENT}"
    _fluffless_prompt_error="%F{$FLUFFLESS_ERROR}"
    _fluffless_prompt_reset='%f'

    _fluffless_prompt_git_segment='${_fluffless_prompt_git_cache_out:+ ${_fluffless_prompt_git_cache_out}}'
    [[ "$FLUFFLESS_SHOW_GIT" == 1 ]] || _fluffless_prompt_git_segment=''

    PROMPT="${_fluffless_prompt_dim}%~${_fluffless_prompt_reset}${_fluffless_prompt_git_segment} ${_fluffless_prompt_reset}${_fluffless_prompt_muted}%(?||${_fluffless_prompt_error}%?${_fluffless_prompt_reset} )${_fluffless_prompt_accent}❯${_fluffless_prompt_reset} "
    if [[ "$FLUFFLESS_SHOW_CLOCK" == 1 ]]; then
        RPROMPT="${_fluffless_prompt_muted}%D{%H:%M}${_fluffless_prompt_reset}"
    else
        RPROMPT=''
    fi
    typeset -g _fluffless_prompt_initialized=1
fi

_fluffless_prompt_git_cache_epoch=0
_fluffless_prompt_git_cache_dir=""
_fluffless_prompt_git_cache_out=""
_fluffless_prompt_version="1.0.0"

# 0 = clean, 1 = dirty, 2 = no-repo
_fluffless_git_is_dirty() {
    git diff --quiet --ignore-submodules=dirty 2>/dev/null || return 1
    git diff --cached --quiet --ignore-submodules=dirty 2>/dev/null || return 1
    git ls-files --others --exclude-standard 2>/dev/null | grep -q . || return 1
    return 0
}

_fluffless_prompt_git() {
    local now
    now=$EPOCHSECONDS

    if [[ "$FLUFFLESS_SHOW_GIT" != 1 ]]; then
        _fluffless_prompt_git_cache_out=""
        return
    fi

    # Cache by directory so deep prompt cycles do not fork git all the time.
    if [[ "$_fluffless_prompt_git_cache_dir" == "$PWD" && $(( now - _fluffless_prompt_git_cache_epoch )) -lt $FLUFFLESS_GIT_CACHE_TTL ]]; then
        [[ -z "$_fluffless_prompt_git_cache_out" ]]
        return
    fi

    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        _fluffless_prompt_git_cache_out=""
        _fluffless_prompt_git_cache_epoch=$now
        _fluffless_prompt_git_cache_dir="$PWD"
        return
    fi

    local branch dot=""
    branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null) || branch=""

    if [[ -n "$branch" ]]; then
        if _fluffless_git_is_dirty; then
            dot="•"
        fi
        _fluffless_prompt_git_cache_out="%F{$FLUFFLESS_DIM}$branch%F{$FLUFFLESS_ACCENT}$dot%f"
    else
        _fluffless_prompt_git_cache_out=""
    fi

    _fluffless_prompt_git_cache_epoch=$now
    _fluffless_prompt_git_cache_dir="$PWD"
}

# Update the cached segment before each prompt is drawn.
_fluffless_prompt_precmd() {
    _fluffless_prompt_git
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _fluffless_prompt_precmd
