set -gx FISH_CONFIG_DIR $HOME/.config/fish
set -g fish_greeting

# Load configurable variables.
if test -e $FISH_CONFIG_DIR/vars.fish
    . $FISH_CONFIG_DIR/vars.fish
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
    set hname ''
    if [ "$SSH_CONNECTION" != "" ]
        set hname [ssh (hostname)] ''
    end
    if [ "$TMUX" != "" ]
        set hname "$hname@tmux "
    end
    if [ "$hname" != "" ]
        echo $hname
    end
end

function git_prompt_info
    set ref (git symbolic-ref -q --short HEAD 2> /dev/null; or git describe --tags --exact-match 2> /dev/null; or git rev-parse --short HEAD 2> /dev/null)

    if test -z "$ref"
        return
    end

    printf '%s %s %s%s' (set_color 424242) (echo $ref) (set_color normal) (parse_git_dirty)
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
    printf "\n%s→%s " (set_color 607D8B) (set_color normal)
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
                $HOME/.cargo/bin
# user path
for p in $bin_path
    if test -d $p
        if not contains $p $PATH
            set -x PATH $PATH $p
        end
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
alias vimrc="vim $HOME/.vim/vimrc"
alias gostatic="env CGO_ENABLED=0 go build -ldflags '-w -extldflags \"-static\"'"

# direnv
if type -q direnv
    eval (direnv hook fish)
end

switch (uname -s)
case "Linux"
    alias pbcopy="env DISPLAY=:0 xclip -selection clipboard"
    set -l brew_path /home/linuxbrew/.linuxbrew/bin
    if not contains $brew_path $PATH
        set -x PATH $PATH $brew_path
    end
    set -gx SSH_AUTH_SOCK /var/run/user/(id -u)/keyring/ssh
case "Darwin"
    set -gx ICLOUD $HOME/Library/Mobile\ Documents/com\~apple\~CloudDocs/
end

##########################################
#            Utility functions           #
##########################################

function proxy
    switch $argv[1]
    case "on"
        set -gx http_proxy (get_custom_var http_proxy http://localhost:1235)
        set -gx https_proxy (get_custom_var https_proxy http://localhost:1235)
        set -gx no_proxy (get_custom_var no_proxy)
    case "off"
        set -e http_proxy
        set -e https_proxy
        set -e HTTPS_PROXY
        set -e HTTP_PROXY
        set -e no_proxy
    end
end

# reload fish config
function reload
    source $HOME/.config/fish/config.fish
end

function gitprivate -d "Apply private git configs"
    if test -z "$argv[1]"
        echo "Usage: gitprivate <gpg_key_id>" 1>&2
        return 1
    end
    git config user.name maralla
    git config user.email maralla.ai@gmail.com
    git config user.signingkey $argv[1]
end

if test -e $FISH_CONFIG_DIR/local.fish
    . $FISH_CONFIG_DIR/local.fish
end
