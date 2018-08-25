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
    printf "%s%s%s" (set_color 8BC34A) (hostname_suffix) (set_color normal)
    printf "%s%s%s" (set_color FF9800) (prompt_pwd) (set_color normal)
    printf "%s" (git_prompt_info)
    printf "\n%s\uf021%s " (set_color 607D8B) (set_color normal)
end

function fish_right_prompt
    if test "$VIRTUAL_ENV" != ""
        printf '(env: %s%s%s)' \
            (set_color -o 4CAF50) (basename $VIRTUAL_ENV) (set_color normal)
    end
end

# setup python virtual env
# eval (python -m virtualfish compat_aliases)
set -g VIRTUALFISH_VERSION 1.0.6
set -g VIRTUALFISH_PYTHON_EXEC $HOME/.dotfiles/virtualenvs/py2/bin/python
set -g VIRTUALFISH_HOME $HOME/.dotfiles/virtualenvs
. $HOME/.dotfiles/virtualenvs/py2/lib/python2.7/site-packages/virtualfish/virtual.fish
. $HOME/.dotfiles/virtualenvs/py2/lib/python2.7/site-packages/virtualfish/compat_aliases.fish
emit virtualfish_did_setup_plugins

set -l bin_path /usr/local/sbin \
                $HOME/Workspace/app/bin \
                $HOME/.cargo/bin \
                /usr/local/var/pyenv/shims

# user path
for path in $bin_path
    if test -d $path
        set PATH $path $PATH
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
set LC_ALL en_US.UTF-8
set LANG en_US.UTF-8

# Alias
alias g=git

# direnv
eval (direnv hook fish)
