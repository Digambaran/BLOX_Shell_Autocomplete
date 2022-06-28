#/usr/bin/env bash

# INFO
# Requires bash 5

# TODO
# Check if .appblox.live.json exists or try reading from appblox.config.json

# TODO
# find used options and show only unused options, eg. if used has already 
#  entered -m or --message, show the other options don't show -m again

# TODO
# For exec, remove already entered blox name from suggestions

# TODO
# Check for live bloxes and remove them from start argument list

# INFO
# COMPREPLY=($(compgen -W "${_opts_list_for_type[*]}" -- "${COMP_WORDS[COMP_CWORD]}"))
# The -- in the middle of above line is to avoid compgen mistaking our option as its option
# Reference https://stackoverflow.com/questions/67851740/how-to-use-bash-compgen-with-my-own-script-options

# sub_cmds=(
# "init" "push" "pull" "publish" "mark" "login" "logout"
# "connect" "ls" "log" "flush" "sync" "create" "start" "exec" "stop"
#  )

sub_cmds=()

sub_cmds+=( "add-categories" )
_add-categories () {  echo "dummy" ; }

sub_cmds+=( "add-tags" )
_add-tags () {  echo "dummy" ; }

sub_cmds+=( "connect" )
_connect () {  echo "dummy" ; }

sub_cmds+=( "create" )
_create () {
    _opts_list=( "--help" "--type" )
    _opts_list_for_type=( "ui-container" "ui-elements" "function" "data" "shared-fn" )

    if [ "$COMP_CWORD" = 2 ];then
         COMPREPLY='enter_bloxname_here'
    elif [ "${COMP_WORDS[-2]}" = "--type" ]; then
        COMPREPLY=($(compgen -W "${_opts_list_for_type[*]}" -- "${COMP_WORDS[COMP_CWORD]}"))
    else
        COMPREPLY=($(compgen -W "${_opts_list[*]}" -- "${COMP_WORDS[COMP_CWORD]}"))
    fi
}

sub_cmds+=( "exec" )
_exec () {
     _opts_list=( "--help" "--inside" )
    if [ "$COMP_CWORD" = 2 ];then
        COMPREPLY='"enter_command_here_inside_quotes"'
    elif [ "${COMP_WORDS[3]}" = "--inside" ]; then
        _read_and_set_bloxes
    else
        COMPREPLY=($(compgen -W "${_opts_list[*]}" -- "${COMP_WORDS[COMP_CWORD]}"))
    fi
}

sub_cmds+=( "flush" )
_flush () {  echo "dummy" ; }

sub_cmds+=( "init" )
_init () {  echo "dummy" ; }

sub_cmds+=( "log" )
_log () {  echo "dummy" ; }

sub_cmds+=( "login" )
_login () {  echo "dummy" ; }

sub_cmds+=( "logout" )
_logout () {  echo "dummy" ; }

sub_cmds+=( "ls" )
_ls () {  echo "dummy" ; }

sub_cmds+=( "mark" )
_mark () {  echo "dummy" ; }

sub_cmds+=( "publish" )
_publish () {  echo "dummy" ; }

sub_cmds+=( "pull" )
_pull () {  echo "dummy" ; }

sub_cmds+=( "pull_appblox" )
_pull_appblox () {  echo "dummy" ; }

sub_cmds+=( "push" )
_push () {
    # echo "${COMP_WORDS[*]}"
    # echo $COMP_CWORD
    # echo $PWD/.appblox.live.json
    _opts_list=( "--force" "--help" "--message" )
    # _opts_list_s=( "-f" "-h" "-m" )

    if [ "$COMP_CWORD" = 2 ];then
        _read_and_set_bloxes
    elif [ "${COMP_WORDS[-2]}" = "--message" ]; then
        COMPREPLY='"enter_message_here_inside_quotes"'
    else
        COMPREPLY=($(compgen -W "${_opts_list[*]}" -- "${COMP_WORDS[COMP_CWORD]}"))
    fi
}

sub_cmds+=( "push-config" )
_push-config () {  echo "dummy" ; }

sub_cmds+=( "start" )
_start () {
     _opts_list=( "--use-pnpm" "--help" )
    if [ "$COMP_CWORD" = 2 ];then
        _read_and_set_bloxes
    else
        COMPREPLY=($(compgen -W "${_opts_list[*]}" -- "${COMP_WORDS[COMP_CWORD]}"))
    fi
}

sub_cmds+=( "stop" )
_stop () {  echo "dummy" ; }

sub_cmds+=( "sync" )
_sync () {  echo "dummy" ; }






_handle_sub_cmd() {

    case "${COMP_WORDS[1]}" in
        "add-categories")_add-categories;;
        "add-tags")_add-tags;;
        "connect")_connect;;
        "create")_create;;
        "exec")_exec;;
        "flush")_flush;;
        "init")_init;;
        "log")_log;;
        "login")_login;;
        "logout")_logout;;
        "ls")_ls;;
        "mark")_mark;;
        "publish")_publish;;
        "pull")_pull;;
        "pull_appblox")_pull_appblox;;
        "push")_push;;
        "push-config")_push-config;;
        "start")_start;;
        "stop")_stop;;
        "sync")_sync;;
    esac

}

_blox_completions()
{
    word_count="${#COMP_WORDS[@]}"
    if [ "$word_count" = 2 ];then
        COMPREPLY=($(compgen -W "${sub_cmds[*]}" "${COMP_WORDS[COMP_CWORD]}"))
    elif [ $word_count -ge 3 ];then
        _handle_sub_cmd
    else echo "done"
    fi
}

_read_and_set_bloxes(){
level=0
open="{"
close="}"
tempKey=""
tempVal=""
bloxesArray=()
quotes='"'
inKey=false
inVal=false
check="[a-z0-9A-Z\-_]"
while read -n1 c; do
# echo $c
    if [ "$c" = $open ]; then
        ((level=level+1))
        # echo "$c-OPENING-LEVEL-$level";
    elif [ "$c" = $close ]; then
        ((level=level-1))
        # echo "$c-CLOSING-LEVEL-$level"
    elif [ "$c" = $quotes ] && [ "$inVal" = false ];then
    # echo "quotes-$inKey-$c"
        # inKey is true implies we have and unclosed quote
        if [ "$inKey" = true ];then
            inKey=false
            # echo "key read - $tempKey"
            [[ $level = 1 ]] && bloxesArray+=("$tempKey") 
            tempKey=""
        else
            inKey=true
            # echo "wordStart-$c"
        fi
    elif [ "$c" = ':' ] && [ "$inVal" = false ];then
        inVal=true
    elif [ "$c" = ',' ] && [ "$inVal" = true ];then
        inVal=false
        # echo "value read-$tempVal"
        tempVal=""
    # assing char to inKey or inVal based on set keys
    # elif  [[ $c =~ $check ]];then
    elif  [ ! -z "$c" ];then
        if [ "$inKey" = true ];then
            tempKey+="$c"
        else
            tempVal+="$c"
        fi

    fi
done < "$PWD/.appblox.live.json"

 COMPREPLY=($(compgen -W "${bloxesArray[*]}" "${COMP_WORDS[COMP_CWORD]}"))
}

complete -F _blox_completions blox
