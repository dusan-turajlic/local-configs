# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion || {
    # if not found in /usr/local/etc, try the brew --prefix location
    [ -f "$(brew --prefix)/etc/bash_completion.d/git-completion.bash" ] && \
        . $(brew --prefix)/etc/bash_completion.d/git-completion.bash
}

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -lGf'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

export PORT=80
function .. ()

{

    local arg=${1:-1};

    local dir=""

    while [ $arg -gt 0 ]; do

        dir="../$dir"

        arg=$(($arg - 1));

    done

    cd $dir >&/dev/null

}



function ... ()

{

    if [ -z "$1" ]; then

        return

    fi

    local maxlvl=16

    local dir=$1

    while [ $maxlvl -gt 0 ]; do

        dir="../$dir"

        maxlvl=$(($maxlvl - 1));

        if [ -d "$dir" ]; then

            cd $dir >&/dev/null

        fi

    done

}



# ==== Prompt stuff ==========================================================



if [ $TERM != "dumb" ]; then

         BLACK="\[\033[0;30m\]"

           RED="\[\033[0;31m\]"

         GREEN="\[\033[0;32m\]"

         BROWN="\[\033[0;33m\]"

          BLUE="\[\033[0;34m\]"

        PURPLE="\[\033[0;35m\]"

          CYAN="\[\033[0;36m\]"

    LIGHT_GRAY="\[\033[0;37m\]"

     DARK_GRAY="\[\033[1;30m\]"

     LIGHT_RED="\[\033[1;31m\]"

   LIGHT_GREEN="\[\033[1;32m\]"

        YELLOW="\[\033[1;33m\]"

    LIGHT_BLUE="\[\033[1;34m\]"

  LIGHT_PURPLE="\[\033[1;35m\]"

    LIGHT_CYAN="\[\033[1;36m\]"

         WHITE="\[\033[1;37m\]"

    COLOR_NONE="\[\033[0m\]"

   COLOR_RESET="\[\033[1;00m\]"



  function parse_git_branch {

    git rev-parse --git-dir &> /dev/null

    # Bail if not in git dir/subdir

    git branch >/dev/null 2>&1 || return 1



    git_status="$( git status 2>/dev/null )"



    # Set color based on clean/staged/dirty.

    if [[ ${git_status} =~ "working tree clean" ]]; then

       state="${GREEN}"

    elif [[ ${git_status} =~ ": needs merge" ]]; then

       state="${LIGHT_CYAN}"

    elif [[ ${git_status} =~ "Changes to be committed" ]]; then

       state="${YELLOW}"

    else

       state="${RED}"

    fi



    # Set arrow icon based on status against remote.

    remote_pattern="# Your branch is (ahead of|behind)"

    if [[ ${git_status} =~ ${remote_pattern} ]]; then

      if [[ ${BASH_REMATCH[1]} == "ahead of" ]]; then

        remote=" ↑"

      else

        remote=" ↓"

      fi

    fi

    diverge_pattern="# Your branch and (.*) have diverged"

    if [[ ${git_status} =~ ${diverge_pattern} ]]; then

      remote=" ↕"

    fi



    # Output prompt

    ref=$(git symbolic-ref HEAD 2> /dev/null) || return

    echo -ne "git:"${state}${ref#refs/heads/}${COLOR_RESET}${remote}" "

  }



  function prompt_func {

    # First line

    PS1="\n${YELLOW}\u${BROWN}@${YELLOW}\h${COLOR_RESET} in ${LIGHT_GREEN}\w${COLOR_RESET}"

    # Second line

    if [[ $( uname -m ) == "i686" && "$HOSTNAME" == "grimthwacker" ]];

    then

        PS1="${PS1}\n$( parse_git_branch ) 32-bit $ "

    else

        PS1="${PS1}\n$( parse_git_branch )$ "

    fi

  }



  PROMPT_COMMAND=prompt_func

else

  unset LS_COLORS

fi



if [ -n "$PS1" ]; then

    if [ -r /etc/profile.d/bash_completion.sh ]; then

        # Source completion code.

        . /etc/profile.d/bash_completion.sh

    fi

fi

[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

# Changing path to use brew path insted of default
export PATH="/usr/local/bin:$PATH"

export LDFLAGS="-L/usr/local/opt/curl/lib"
export CPPFLAGS="-I/usr/local/opt/curl/include"
export PKG_CONFIG_PATH="/usr/local/opt/curl/lib/pkgconfig"

