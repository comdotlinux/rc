# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples
export USER=guruprasadk
export HOME=/home/$USER

if [ "$PS1" ]; then
complete -cf sudo
fi

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

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

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

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
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -ltrha'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

alias ag='sudo apt-get'
alias agi='sudo apt-get install'
alias acs='sudo apt search'

alias opf="pgrep -fl"
alias pf="ps aux | grep"

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
#if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
#    . /etc/bash_completion
#fi
. ~/.liquidprompt/liquidprompt
[ -r $HOME/.byobu/prompt ] && . $HOME/.byobu/prompt   #byobu-prompt#

#### KEEP BELOW IN CURRENT ORDER ####
declare -A ADD_TO_PATH

ADD_TO_PATH["ANT_HOME"]=$HOME/springsource/Libraries/apache-ant-1.9.4
ADD_TO_PATH["CXF_HOME"]=$HOME/springsource/Libraries/apache-cxf-3.0.0
ADD_TO_PATH["M2_HOME"]=$HOME/springsource/Libraries/apache-maven-3.2.1
ADD_TO_PATH["TOMCAT_HOME"]=$HOME/springsource/Libraries/apache-tomcat-7.0.54
ADD_TO_PATH["GRADLE_HOME"]=$HOME/springsource/Libraries/gradle-2.0

for k in "${!ADD_TO_PATH[@]}"
do
        echo "Adding $k = ${ADD_TO_PATH[$k]} to Path"
        export $k=${ADD_TO_PATH[$k]}
        if [ -d ${ADD_TO_PATH[$k]}/bin ] ; then
                export PATH=$PATH:${ADD_TO_PATH[$k]}/bin
        fi
done

#### KEEP ORDER ENDS ####

export WS=$HOME/Documents/workspace-sts-3.6.0.M1


info(){
        if [ $# -eq 1 ] ; then
                zenity --info --timeout=5 --text="$1";
        else
                zenity --info --timeout=5;
        fi
}

mb(){
        if [ $# -eq 0 ] ; then
                echo "please provide path to project with pom.xml"
                echo "you can optionally provide -debug as first parameter to enable debug"
        else
                #mvnc="mvn exec:exec -Dexec.executable=\"telnet\" -Dexec.args=\"localhost 43155\""
                if [ $1 = "-debug" ] ; then
                        mvnc="mvn --debug"
                        shift
                else
                        mvnc="mvn"
                fi


                if [ -d $1 ] ; then
                        cd $1
                        if [ $? -eq 0 ] ; then
                                mvn clean 
                                sleep 5
                                $mvnc -Dmaven.test.skip=true install -P development
                        fi
                fi
        cd -
        fi
}

refresh_workspace(){
        sleep 10
        telnet localhost 43155
        sleep 2
        telnet localhost 43155
        sleep 2
        telnet localhost 43155
        sleep 2
        telnet localhost 43155
}


st(){
        OPT=jpda\ run
        [ $# -gt 0 ] && [ "x${1}" = "x-debug" ] && OPT=jpda\ start
       if [ -d $TOMCAT_HOME ] && [ -d $TOMCAT_HOME/bin ] ; then
                cd $TOMCAT_HOME/bin
                ./catalina.sh $OPT
        fi
}

pb(){
        mb $HOME/Documents/workspace-sts-3.6.0.M1-2/platform;
        refresh_workspace
}

stcb(){
        mb $HOME/Documents/workspace-sts-3.6.0.M1/platform/;
        mb $HOME/Documents/workspace-sts-3.6.0.M1/stc/;
        refresh_workspace
        info "mvn build done for platform and stc"
}

cb(){
        mb $HOME/Documents/workspace-sts-3.6.0.M1-2/platform/;
        mb $HOME/Documents/workspace-sts-3.6.0.M1-2/celcom;
        refresh_workspace
        info "mvn build done for platform and celcom"
}

dub(){
        mb $HOME/Documents/workspace-sts-3.6.0.M1/platform/;
        mb $HOME/Documents/workspace-sts-3.6.0.M1/du;
        refresh_workspace
        info "mvn build done for platform and du"
}

eeb(){
        mb $HOME/Documents/workspace-sts-3.6.0.M1-2/etisalategypt;
        refresh_workspace
        info "mvn build done for etisalategypt"
}


alias k9t="pkill -9 -f \"apache-tomcat-7.0.54\/bin\/tomcat-juli.jar\""

