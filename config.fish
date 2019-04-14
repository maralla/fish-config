# Load configurable variables.
set -l var_file ~/.config/fish/vars.fish
if test -e $var_file
    . $var_file
end

function get_custom_var
    set -l name __var_$argv[1]
    set -l value $$name
    if [ "$value" = "" ]
        echo $argv[2]
    else
        echo $value
    end
end

set -g fish_prompt_pwd_dir_length 0

function hostname_suffix
    if [ "$TMUX" != "" ]
        echo '@tmux '
    end
end

function git_prompt_info
    set branches (command git branch 2> /dev/null); or return
    set ref (command git symbolic-ref HEAD 2> /dev/null)
    if test -z ref
        set ref (command git rev-parse --short HEAD 2> /dev/null); or return
    end

    if test -z ref
        return
    end

    for br in $branches
        if echo $br | grep '*' > /dev/null
            set ref (command echo $br | sed 's/^\* //' | sed 's/(.*detached.* \(.*\))/\1/' 2> /dev/null); or return
            break
        end
    end
    printf '%s %s %s%s' (set_color 424242) (string replace 'refs/heads/' '' $ref) (set_color normal) (parse_git_dirty)
end

function parse_git_dirty
    set GIT_STATUS (command git status -s -uno 2> /dev/null | tail -n1)
    if test -n "$GIT_STATUS"
        set_color red
        echo ✗
        set_color normal
    else
        set_color green
        echo ✓
        set_color normal
    end
end

function fish_prompt
    printf "%s%s%s" (set_color 424242) (hostname_suffix) (set_color normal)
    printf "%s%s%s" (set_color bb4d00) (prompt_pwd) (set_color normal)
    printf "%s" (git_prompt_info)
    printf "\n%s\uf021%s " (set_color 607D8B) (set_color normal)
end

function fish_right_prompt
    if test "$VIRTUAL_ENV" != ""
        printf '%senv:%s %s%s%s' \
           (set_color 424242) (set_color normal) (set_color -o 607D8B) \
           (basename $VIRTUAL_ENV) (set_color normal)
    end
end

set -l bin_path /usr/local/sbin \
                $HOME/Workspace/app/bin \
                $HOME/.cargo/bin \
                /usr/local/var/pyenv/shims
# user path
for p in $bin_path
    if test -d $p
        if not contains $p $PATH
            set -x PATH $PATH $p
        end
    end
end

# pyenv
export PYENV_ROOT=/usr/local/var/pyenv
# status --is-interactive; and source (pyenv init -|psub)
set PYENV_SHELL fish
# . '/usr/local/Cellar/pyenv/1.0.7/libexec/../completions/pyenv.fish'
# command pyenv rehash 2>/dev/null
function pyenv
    set command $argv[1]
    set -e argv[1]
    switch "$command"
  case rehash shell
      . (pyenv "sh-$command" $argv|psub)
  case '*'
      command pyenv "$command" $argv
  end
end

# set locale
# set LC_ALL en_US.UTF-8
# set LANG en_US.UTF-8
set -x EDITOR vim

# Fish color scheme
set fish_color_command 2196f3

# Alias
alias g=git

# direnv
eval (direnv hook fish)

function proxy
    switch $argv[1]
    case "on"
        set -gx http_proxy (get_custom_var http_proxy http://localhost:1235)
        set -gx https_proxy (get_custom_var https_proxy http://localhost:1235)
        set -gx no_proxy (get_custom_var no_proxy)
    case "off"
        set -e http_proxy
        set -e https_proxy
        set -e no_proxy
    end
end

switch (uname -s)
case "Linux"
    alias pbcopy="env DISPLAY=:0 xclip -selection clipboard"
case "Darwin"
    set -gx ICLOUD $HOME/Library/Mobile\ Documents/com\~apple\~CloudDocs/
end

# reload fish config
function reload
    source $HOME/.config/fish/config.fish
end
