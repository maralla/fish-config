set -g fish_prompt_pwd_dir_length 0

function hostname_suffix
    if [ "$TMUX" != "" ]
        echo 'tmux '
    end
end

function git_prompt_info
    set -l branches (command git branch 2> /dev/null)
    set -l ref (command git symbolic-ref HEAD 2> /dev/null)
    if test -z ref
        set -l ref (command git rev-parse --short HEAD 2> /dev/null)
    end

    if test -z ref
        return
    end

    if test "$branches" != ""
        set -l ref (command echo $branches | grep '*' | sed 's/^\* //' | sed 's/(.*detached.* \(.*\))/\1/' 2> /dev/null)
    end
    printf '%s%s %s%s' (set_color 424242) (string replace 'refs/heads/' '' $ref) (set_color normal) (parse_git_dirty)
end

function parse_git_dirty
    set -l GIT_STATUS ''
    if test "$DISABLE_UNTRACKED_FILES_DIRTY" = "true"
        set -l GIT_STATUS (command git status -s -uno 2> /dev/null | tail -n1)
    else
        set -l GIT_STATUS (command git status -s 2> /dev/null | tail -n1)
    end
    if test -n $GIT_STATUS
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
    printf '%s%s%s%s%s%s %s\n%s➡ %s' \
        (set_color 8BC34A) (hostname_suffix) (set_color normal) \
        (set_color FF9800) (prompt_pwd) (set_color normal) \
        (git_prompt_info) \
        (set_color 607D8B) (set_color normal)
end

function fish_right_prompt
    if test "$VIRTUAL_ENV" != ""
        printf '(env: %s%s%s)' \
            (set_color -o 4CAF50) (basename $VIRTUAL_ENV) (set_color normal)
    end
end

# setup python virtual env
eval (python -m virtualfish compat_aliases)

# user path
set fish_user_paths /usr/local/sbin $HOME/Workspace/app/bin $HOME/.cargo/bin $fish_user_paths
