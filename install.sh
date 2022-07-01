################################################
# This script is copied from https://github.com/nvm-sh/nvm/blob/master/install.sh,
# and skinned and edited to taste!! :p :p
################################################

{
    script_source="https://raw.githubusercontent.com/Digambaran/BLOX_Shell_Autocomplete/main/blox_completion.bash"
    expected_profile="${HOME}/.bashrc"
    
    # Utility to check command existence
    _has() {
        type "$1" > /dev/null 2>&1
    }

    # Utility to check if passed parameter path exists
    _try_profile() {
        if [ -z "${1-}" ] || [ ! -f "${1}" ]; then
            return 1
        fi
        echo "${1}"
    }


    # Make sure in bash shell, and .bashrc is present in home
    # DOC: ${SHELL#*bash} removes the longest matching string with "bash",
    # so if $SHELL is /bin/bash (which it should be in bash envs), the string is completely
    # deleted and is an empty string now. So won't match $SHELL
    # **** This is how it was done in nvm install script, not sure why.**** 
    if [ "${SHELL#*bash}" != "$SHELL" ]; then
        if [ ! -z "$(_try_profile "${HOME}/.bashrc")" ]; then
            echo "$expected_profile"
        else 
            echo "${expected_profile} not found.."
            exit 1
        fi
    elif [ "${SHELL#*zsh}" != "$SHELL" ]; then
        echo "zsh is not supported.\nPlease use in bash environment."
        exit 1
    fi


    # Download with curl or wget
    _download() {
        if _has "curl"; then
            curl --fail --compressed -q "$@"
        elif _has "wget"; then
            # Emulate curl with wget
            ARGS=$(nvm_echo "$@" | command sed -e 's/--progress-bar /--progress=bar /' \
                                    -e 's/--compressed //' \
                                    -e 's/--fail //' \
                                    -e 's/-L //' \
                                    -e 's/-I /--server-response /' \
                                    -e 's/-s /-q /' \
                                    -e 's/-sS /-nv /' \
                                    -e 's/-o /-O /' \
                                    -e 's/-C - /-c /')
            eval wget $ARGS
        fi
    }


    
    # Test bash version, if less than 5 exit
    bash_version=$( echo $BASH_VERSION | (read -d "." c;echo "$c") )
    if [[ "$bash_version" -lt "5" ]];then
        echo 'Requires bash 5 or greater'
    else 
        echo "Bash version:${BASH_VERSION}"
    fi

    # Set install directory
    if [ -z "${XDG_CONFIG_HOME-}" ];then
        echo "Script will be added to ${HOME}/.appblox"
        install_dir="${HOME}/.appblox"
    else
        echo "Script will be added to ${XDG_CONFIG_HOME}/appblox"
        install_dir="${HOME}/appblox"
    fi

    # Create install directory
    mkdir -p "${install_dir}"

    # Check if either curl or wget is present
    if _has curl || _has wget ;then
       _download -s "$script_source" -o "$install_dir/appblox-completion.bash" || {
        echo "Failed to download '$install_dir'"
        return 1
       }
    else
        echo 'You need curl, or wget installed!'
        exit 1
    fi

    # Add to .bashrc
    COMPLETION_STR='[ -s "$HOME/.appblox/appblox-completion.bash" ] && \. "$HOME/.appblox/appblox-completion.bash"'
    echo "$COMPLETION_STR" >> "${HOME}/.bashrc"

    unset -f _has _download _try_profile
}