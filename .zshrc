# -*- shell-script -*-

# {{{ User settings

# {{{ Environment
export HISTFILE="${HOME}/.zsh_history"
export HISTSIZE=1000000
export SAVEHIST=1000000
export LESSHISTFILE="-"
export PAGER="less"
export READNULLCMD="${PAGER}"
export BROWSER="firefox"
export XTERM="urxvtc"
export PATH="/opt/local/Library/Frameworks/Python.framework/Versions/2.6/bin:/opt/local/bin:/usr/local/graphviz-2.14/bin:$PATH"
export VIRTUAL_ENV_DISABLE_PROMPT=1
export LD_LIBRARY_PATH=/usr/local/lib:/opt/local/lib
export C_INCLUDE_PATH=/usr/local/include:/opt/local/include
export LIBRARY_PATH=/opt/local/lib

# }}}

# {{{ Manual pages
#     - colorize, since man-db fails to do so
export LESS_TERMCAP_mb=$'\E[01;31m'   # begin blinking
export LESS_TERMCAP_md=$'\E[01;31m'   # begin bold
export LESS_TERMCAP_me=$'\E[0m'       # end mode
export LESS_TERMCAP_se=$'\E[0m'       # end standout-mode
export LESS_TERMCAP_so=$'\E[1;33;40m' # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'       # end underline
export LESS_TERMCAP_us=$'\E[1;32m'    # begin underline
# }}}

# {{{ Aliases
alias ..="cd .."
alias ...="cd ../.."
alias grep="grep --color=always"
alias ls='pwd;ls -la --color'
alias c='clear'
alias rfind="find . -not -name \"*-all.js\" |xargs grep -nis --color"
alias rcoffeelint="find . -name '*.coffee' | xargs coffeelint"
alias todo="find . | xargs grep -is --color todo"
alias rm="rm -rf"
alias rebuild_ie_vms="curl -s https://raw.github.com/xdissent/ievms/master/ievms.sh | bash"
alias tree="git log --graph --decorate --pretty=oneline --abbrev-commit --all"

alias mlittrell1="ssh root@192.168.35.223"
alias mlittrell2="ssh root@192.168.35.224"
alias mlittrell3="ssh root@192.168.35.225"
alias mlittrell4="ssh root@192.168.35.226"

alias vm1="cd ~/mlittrell1"
alias vm2="cd ~/mlittrell2"
alias vm3="cd ~/mlittrell3"
alias vm4="cd ~/mlittrell4"
# }}}

# {{{ Git Aliases
alias status="git status"
alias pull="git pull --rebase"
alias spull="git pull --rebase;/SevOneNMS/development/SevOne-install-internal"
# }}}

# {{{ SevOne Aliases
alias api="php /SevOneNMS/personal/mlittrell/api_test.php"
alias doms="cd /SevOneNMS/www/htdocs/doms"
alias actions="cd /SevOneNMS/php/SevOne/actions"
alias rebuildwizard="/SevOneNMS/development/SevOne-Compress-Wizard.sh"
alias rebuildwizard-temp="cd /SevOneNMS/www/htdocs/doms/wizard/ && git checkout -- wiz.jsb3 && /opt/SenchaSDKTools-2.0.0-beta3/sencha build -v -p wiz.jsb3 -d . && git checkout -- development.php"
alias cleanwizard="git checkout /SevOneNMS/www/htdocs/doms/wizard/all-classes.js /SevOneNMS/www/htdocs/doms/wizard/app-all.js /SevOneNMS/www/htdocs/doms/wizard/wiz.jsb3"
alias rebuildapi="rm /www/htdocs/soap3/SevOneApi.php /www/htdocs/soap3/api.wsdl; SevOne-api-make-php; SevOne-api-make-wsdl; SevOne-api-change-ip 192.168.35.224; /etc/init.d/apache2 restart;"
alias rebuildvm="SevOne-build --full -L"
# }}}

# {{{ Completion
compctl -k "(add delete draft edit list import preview publish update)" nb
# }}}

# {{{ ZSH settings
setopt nohup
setopt autocd
setopt cdablevars
setopt nobgnice
setopt noclobber
setopt shwordsplit
setopt interactivecomments
setopt autopushd pushdminus pushdsilent pushdtohome
setopt histreduceblanks histignorespace inc_append_history
setopt nobeep

# keybindings
bindkey -e # emacs
bindkey "\e[A" up-line-or-search
bindkey "\e[B" down-line-or-search
zle -N backward-kill-partial-word
bindkey '^x/' backward-kill-partial-word

# Prompt requirements
setopt extended_glob prompt_subst
autoload colors zsh/terminfo

# New style completion system
autoload -U compinit; compinit
#  * List of completers to use
zstyle ":completion:*" completer _complete _match _approximate
#  * Allow approximate
zstyle ":completion:*:match:*" original only
zstyle ":completion:*:approximate:*" max-errors 1 numeric
#  * Selection prompt as menu
zstyle ":completion:*" menu select=1
#  * Menu selection for PID completion
zstyle ":completion:*:*:kill:*" menu yes select
zstyle ":completion:*:kill:*" force-list always
zstyle ":completion:*:processes" command "ps -au$USER"
zstyle ":completion:*:*:kill:*:processes" list-colors "=(#b) #([0-9]#)*=0=01;32"
#  * Don't select parent dir on cd
zstyle ":completion:*:cd:*" ignore-parents parent pwd
#  * Complete with colors
zstyle ":completion:*" list-colors ""
# Ignore user home direcotry completion
zstyle ':completion:*:*:*:users' ignored-patterns '*'

cdpath=(. ~)  # Set this to (.) if you only want directory completion from the path.

# vcs_info
autoload -Uz vcs_info
zstyle ':vcs_info:*' stagedstr '%F{28}●'
zstyle ':vcs_info:*' unstagedstr '%F{11}●'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:[svn]' format '[%c %b%u]'
zstyle ':vcs_info:*' enable bzr git svn

# }}}

# {{{ Functions

function destroyvm() {
    vagrant status > /dev/null 2>&1
    if [ $? -eq 3 ]; then
        echo "This command must be run within an initialized vagrant environment (where one has run vagrant init)"
        return
    fi

    if [ ! -n "$1" ]; then
        echo "Info: This is a wrapper for vagrant when using chef server.\n" \
             "It will remove the client and node with knife, then destroy\n" \
             "The VM with vagrant destroy." \
             "\n" \
             "Usage: destroyvm vm-name"
        return
    fi

    knife node delete $1 --yes > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Could not delete node from Chef!"
    fi
    knife client delete $1 --yes > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Could not delete client from Chef!"
    fi
    vagrant destroy $1 > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Could not destroy vagrant VM!"
    fi
    echo "Done!"
}

function chefkeys () {
    rm -f ~/.chef/$USER.pem > /dev/null 2>&1
    ssh -i $(vagrant ssh_config | grep IdentityFile | awk '{print $2}') vagrant@chef.local.vm 'knife client delete '$USER' --yes; knife client create '$USER' -n -a' > ~/.chef/$USER.pem
}

function dnsips () {
    if [ ! -n "$1" ]; then
        echo "Usage: dnsips [zone-filename]"
        return
    fi

    free_ips=()
    inactive_ips=()

    for ip in 10.1.0.{1..255} 10.1.1.{1..254}; do
      echo "Trying $ip"
      grep $ip $1 &> /dev/null
      if [ $? -ne 0 ]; then
        ping -c1 -t1 $ip &> /dev/null
        if [ $? -ne 0 ]; then
          free_ips=("${free_ips[@]}" "$ip")
          echo "Found free IP: $ip"
        fi
      else
        ping -c1 -t1 $ip &> /dev/null
        if [ $? -ne 0 ]; then
          inactive_ips=("${inactive_ips[@]}" "$ip")
          echo "Found inactive IP: $ip"
        fi
      fi
    done
    echo "\nInactive IPs:\n"
    printf "%s\n" ${inactive_ips[@]}

    echo "\nFree IPs:\n"
    printf "%s\n" ${free_ips[@]}
}

function cl () { cd $1 && ls }
function covtest () {
    nosetests --cover-package=$1 --cover-erase --with-coverage
}
function backward-kill-partial-word {
    local WORDCHARS="${WORDCHARS//[\/.]/}"
    zle backward-kill-word "$@"
}
function eave () { diff <(lsof -p $1) <(sleep 10; lsof -p $1) }

function chpwd() {
    emulate -LR zsh
    ls -a
}

# {{{ Terminal and prompt


function precmd {
    # Terminal width = width - 1 (for lineup)
    local TERMWIDTH
    ((TERMWIDTH=${COLUMNS} - 1))

    # Truncate long paths
    PR_FILLBAR=""
    PR_PWDLEN=""

    local PROMPTSIZE="${#${(%):---(%n@%m:%l)---()--}}"
    local PWDSIZE="${#${(%):-%~}}"

    if [[ "${PROMPTSIZE} + ${PWDSIZE}" -gt ${TERMWIDTH} ]]; then
        ((PR_PWDLEN=${TERMWIDTH} - ${PROMPTSIZE}))
    else
        PR_FILLBAR="\${(l.((${TERMWIDTH} - (${PROMPTSIZE} + ${PWDSIZE})))..${PR_HBAR}.)}"
    fi

    # VCS
    CHANGES1=$(git ls-files --other --exclude-standard 2> /dev/null)
    CHANGES2=$(git status -s 2> /dev/null)

    zstyle ':vcs_info:*' formats ' [%F{green}%b %c%u%F{white}]'

    if [[ -n $CHANGES1 ]] {
        zstyle ':vcs_info:*' formats ' [%F{green}%b %c%u%F{red}●%F{white}]'
    }

    if [[ -n $CHANGES2 ]] {
        zstyle ':vcs_info:*' formats ' [%F{green}%b %c%u%F{yellow}●%F{white}]'
    }

    if [[ -n $CHANGES1 && -n $CHANGES2 ]] {
        zstyle ':vcs_info:*' formats ' [%F{green}%b %c%u%F{red}●%F{yellow}●%F{white}]'
    }

    if [[ -n $VIRTUAL_ENV ]] {
        PR_VIRTUALENV="%{${fg_bold[white]}%}(virtualenv: %{${fg[green]}%}`basename \"$VIRTUAL_ENV\"`%{${fg_bold[white]}%})%{${reset_color}%}"
    } else {
        PR_VIRTUALENV=""
    }

    #
    # if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null)
    #         && -z $(bzr ls -R --unknown 2> /dev/null) ]]; then
    #     if [[ -z $(bzr st -V 2> /dev/null) ]]; then
    #         zstyle ':vcs_info:*' formats '  %F{white}[%F{green}%c %b%u%F{white}]'
    #     else
    #         zstyle ':vcs_info:*' formats '  %F{white}[%F{green}%c %b%u%F{red}●%F{white}]'
    #     fi
    # else
    #     if [[ -z $(bzr st -V 2> /dev/null) ]]; then
    #         zstyle ':vcs_info:*' formats ' %F{white}[%c %b%u%F{red}●%F{white}]'
    #     else
    #         zstyle ':vcs_info:*' formats ' %F{white}[%c %b%u%F{red}●%F{28}●%F{white}]'
    #     fi
    # fi
    vcs_info
}

function preexec () {
    # Screen window titles as currently running programs
    if [[ "${TERM}" == "screen-256color" ]]; then
        local CMD="${1[(wr)^(*=*|sudo|-*)]}"
        echo -n "\ek$CMD\e\\"
    fi
}

function setprompt () {

    if [[ "${terminfo[colors]}" -ge 8 ]]; then
        colors
    fi

    for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
        eval PR_"${color}"="%{${terminfo[bold]}$fg[${(L)color}]%}"
        eval PR_LIGHT_"${color}"="%{$fg[${(L)color}]%}"
    done

    PR_NO_COLOUR="%{${terminfo[sgr0]}%}"

    # Try to use extended characters to look nicer
    typeset -A altchar
    set -A altchar ${(s..)terminfo[acsc]}
    PR_SET_CHARSET="%{${terminfo[enacs]}%}"
    PR_SHIFT_IN="%{${terminfo[smacs]}%}"
    PR_SHIFT_OUT="%{${terminfo[rmacs]}%}"
    PR_HBAR="${altchar[q]:--}"
    PR_ULCORNER="${altchar[l]:--}"
    PR_LLCORNER="${altchar[m]:--}"
    PR_LRCORNER="${altchar[j]:--}"
    PR_URCORNER="${altchar[k]:--}"

    # Terminal prompt settings
    case "${TERM}" in
        dumb) # Simple prompt for dumb terminals
            unsetopt zle
            PROMPT='%n@%m:%~%% '
            ;;
        linux) # Simple prompt with Zenburn colors for the console
            echo -en "\e]P01e2320" # zenburn black (normal black)
            echo -en "\e]P8709080" # bright-black  (darkgrey)
            echo -en "\e]P1705050" # red           (darkred)
            echo -en "\e]P9dca3a3" # bright-red    (red)
            echo -en "\e]P260b48a" # green         (darkgreen)
            echo -en "\e]PAc3bf9f" # bright-green  (green)
            echo -en "\e]P3dfaf8f" # yellow        (brown)
            echo -en "\e]PBf0dfaf" # bright-yellow (yellow)
            echo -en "\e]P4506070" # blue          (darkblue)
            echo -en "\e]PC94bff3" # bright-blue   (blue)
            echo -en "\e]P5dc8cc3" # purple        (darkmagenta)
            echo -en "\e]PDec93d3" # bright-purple (magenta)
            echo -en "\e]P68cd0d3" # cyan          (darkcyan)
            echo -en "\e]PE93e0e3" # bright-cyan   (cyan)
            echo -en "\e]P7dcdccc" # white         (lightgrey)
            echo -en "\e]PFffffff" # bright-white  (white)
            PROMPT='$PR_GREEN%n@%m$PR_WHITE:$PR_YELLOW%l$PR_WHITE:$PR_RED%~$PR_YELLOW%%$PR_NO_COLOUR '
            ;;
        *)  # Main prompt
            PROMPT='$PR_SET_CHARSET$PR_GREEN$PR_SHIFT_IN$PR_ULCORNER$PR_GREEN$PR_HBAR\
$PR_SHIFT_OUT($PR_GREEN%(!.%SROOT%s.%n)$PR_RED@$PR_GREEN%m$PR_WHITE:$PR_YELLOW%l$PR_GREEN)\
$PR_SHIFT_IN$PR_HBAR$PR_GREEN$PR_HBAR${(e)PR_FILLBAR}$PR_GREEN$PR_HBAR$PR_SHIFT_OUT(\
$PR_RED%$PR_PWDLEN<...<%~%<<$PR_GREEN)$PR_SHIFT_IN$PR_HBAR$PR_GREEN$PR_URCORNER$PR_SHIFT_OUT\

$PR_GREEN$PR_SHIFT_IN$PR_LLCORNER$PR_GREEN$PR_HBAR$PR_SHIFT_OUT(\
%(?..$PR_RED%?$PR_WHITE:)%(!.$PR_RED.$PR_YELLOW)%#$PR_GREEN)$PR_NO_COLOUR '

            RPROMPT='$PR_VIRTUALENV${vcs_info_msg_0_}$PR_GREEN$PR_SHIFT_IN$PR_HBAR$PR_GREEN$PR_LRCORNER$PR_SHIFT_OUT$PR_NO_COLOUR'
            ;;
    esac
}

# Prompt init
setprompt
# }}}
# }}}

cd /SevOneNMS
git status

