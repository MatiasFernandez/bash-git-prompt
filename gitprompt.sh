#!/bin/sh

function async_run()
{
  {
    $1 &> /dev/null
  }&
}

# Set home dir for bash-git-prompt
function git_prompt_dir()
{
  # code thanks to http://stackoverflow.com/questions/59895
  if [ -z "${__GIT_PROMPT_DIR}" ]; then
    local SOURCE="${BASH_SOURCE[0]}"
    while [ -h "${SOURCE}" ]; do
      local DIR="$( cd -P "$( dirname "${SOURCE}" )" && pwd )"
      SOURCE="$(readlink "${SOURCE}")"
      [[ $SOURCE != /* ]] && SOURCE="${DIR}/${SOURCE}"
    done
    __GIT_PROMPT_DIR="$( cd -P "$( dirname "${SOURCE}" )" && pwd )"
  fi
}

function git_prompt_config()
{
  # Colors
  ResetColor="\[\033[0m\]"            # Text reset

  # Bold
  local BoldGreen="\[\033[1;32m\]"    # Green
  local BoldBlue="\[\033[1;34m\]"     # Blue

  # High Intensty
  local IntenseBlack="\[\033[0;90m\]" # Grey

  # Bold High Intensty
  local Magenta="\[\033[1;95m\]"      # Purple

  # Regular Colors
  local Yellow="\[\033[0;33m\]"
  local White='\[\033[37m\]'
  local Red="\[\033[0;31m\]"
  local Blue="\[\033[0;34m\]"
  local Cyan="\[\033[0;36m\]"
  local Green="\[\033[0;32m\]"

  #Checking if root to change output
  _isroot=false
  [[ $UID -eq 0 ]] && _isroot=true

  load_git_prompt_config_file

  if [ "x${GIT_PROMPT_SHOW_LAST_COMMAND_INDICATOR}" == "x1" ]; then
  	if [ $LAST_COMMAND_STATE = 0 ]; then
  		LAST_COMMAND_INDICATOR="${GIT_PROMPT_COMMAND_OK}";
  	else
  		LAST_COMMAND_INDICATOR="${GIT_PROMPT_COMMAND_FAIL}";
  	fi
  fi

  if [ "x${GIT_PROMPT_START}" == "x" ]; then
    #First statment is for non root behavior second for root
    if $_isroot; then
      PROMPT_START="${GIT_PROMPT_START_ROOT}"
    else
      PROMPT_START="${GIT_PROMPT_START_USER}"
    fi
  else
    PROMPT_START="${GIT_PROMPT_START}"
  fi

  if [ "x${GIT_PROMPT_END}" == "x" ]; then
    #First statment is for non root behavior second for root
    if ! $_isroot; then
      PROMPT_END="${GIT_PROMPT_END_USER}"
    else
      PROMPT_END="${GIT_PROMPT_END_ROOT}"
    fi
  else
    PROMPT_END="${GIT_PROMPT_END}"
  fi

  # set GIT_PROMPT_LEADING_SPACE to 0 if you want to have no leading space in front of the GIT prompt
  if [ "x${GIT_PROMPT_LEADING_SPACE}" == "x0" ]; then
    PROMPT_LEADING_SPACE=""
  else
    PROMPT_LEADING_SPACE=" "
  fi

  if [ "x${GIT_PROMPT_ONLY_IN_REPO}" == "x1" ]; then
    EMPTY_PROMPT=$OLD_GITPROMPT
  else
    if [[ -n "${VIRTUAL_ENV}" ]]; then
      EMPTY_PROMPT="${LAST_COMMAND_INDICATOR}(${Blue}$(basename "${VIRTUAL_ENV}")${ResetColor}) ${PROMPT_START}$($prompt_callback)${PROMPT_END}"
    elif [[ -n "${CONDA_DEFAULT_ENV}" ]]; then
      EMPTY_PROMPT="${LAST_COMMAND_INDICATOR}(${Blue}$(basename "${CONDA_DEFAULT_ENV}")${ResetColor}) ${PROMPT_START}$($prompt_callback)${PROMPT_END}"
    else
      EMPTY_PROMPT="${LAST_COMMAND_INDICATOR}${PROMPT_START}$($prompt_callback)${PROMPT_END}"
    fi
  fi

  # fetch remote revisions every other $GIT_PROMPT_FETCH_TIMEOUT (default 5) minutes
  GIT_PROMPT_FETCH_TIMEOUT=${1-5}
  
  if [ "x$__GIT_STATUS_CMD" == "x" ]
  then
    git_prompt_dir
    __GIT_STATUS_CMD="${__GIT_PROMPT_DIR}/gitstatus.sh"
  fi
}

function setGitPrompt() {
  LAST_COMMAND_STATE=$?

  local EMPTY_PROMPT
  local __GIT_STATUS_CMD

  git_prompt_config

  local repo=`git rev-parse --show-toplevel 2> /dev/null`
  if [[ ! -e "${repo}" ]]; then
    PS1="${EMPTY_PROMPT}"
    return
  fi

  local FETCH_REMOTE_STATUS=1
  if [[ "x${GIT_PROMPT_FETCH_REMOTE_STATUS}" == "x0" ]]; then
    FETCH_REMOTE_STATUS=0
  fi

  if [[ -e "${repo}/.bash-git-rc" ]]; then
  	source "${repo}/.bash-git-rc"
  fi

  if [ "x${FETCH_REMOTE_STATUS}" == "x1" ]; then
  	checkUpstream
  fi

  updatePrompt
}

function load_git_prompt_config_file() {
  if [[ -z "$__GIT_PROMPT_COLORS_FILE" ]]; then
    __GIT_PROMPT_COLORS_FILE="$__GIT_PROMPT_DIR/git-prompt-colors.sh"
  fi

  if [[ -n "$__GIT_PROMPT_COLORS_FILE" && -f "$__GIT_PROMPT_COLORS_FILE" ]]; then
    source "$__GIT_PROMPT_COLORS_FILE"
  fi
}

function checkUpstream() {
  local GIT_PROMPT_FETCH_TIMEOUT
  git_prompt_config

  local FETCH_HEAD="${repo}/.git/FETCH_HEAD"
  # Fech repo if local is stale for more than $GIT_FETCH_TIMEOUT minutes
  if [[ ! -e "${FETCH_HEAD}"  ||  -e `find "${FETCH_HEAD}" -mmin +${GIT_PROMPT_FETCH_TIMEOUT}` ]]
  then
    if [[ -n $(git remote show) ]]; then
      (
        async_run "git fetch --quiet"
        disown -h
      )
    fi
  fi
}

function updatePrompt() {
  local GIT_PROMPT_PREFIX
  local GIT_PROMPT_SUFFIX
  local GIT_PROMPT_SEPARATOR
  local GIT_PROMPT_BRANCH
  local GIT_PROMPT_STAGED
  local GIT_PROMPT_CONFLICTS
  local GIT_PROMPT_CHANGED
  local GIT_PROMPT_REMOTE
  local GIT_PROMPT_UNTRACKED
  local GIT_PROMPT_STASHED
  local GIT_PROMPT_CLEAN
  local LAST_COMMAND_INDICATOR
  local PROMPT_LEADING_SPACE
  local PROMPT_START
  local PROMPT_END
  local EMPTY_PROMPT
  local GIT_PROMPT_FETCH_TIMEOUT
  local __GIT_STATUS_CMD
  local Blue="\[\033[0;34m\]"

  git_prompt_config

  local -a GitStatus
  GitStatus=($("${__GIT_STATUS_CMD}" 2>/dev/null))

  local GIT_BRANCH=${GitStatus[0]}
  local GIT_REMOTE=${GitStatus[1]}
  if [[ "." == "$GIT_REMOTE" ]]; then
    unset GIT_REMOTE
  else
    IFS=${GIT_PROMPT_SYMBOLS_AHEAD} read -a GIT_REMOTE_SPLITED <<< "${GIT_REMOTE}"
    local GIT_REMOTE_BEHIND=${GIT_REMOTE_SPLITED[0]}
    local GIT_REMOTE_AHEAD=${GIT_REMOTE_SPLITED[1]}
    if [[ -n "${GIT_REMOTE_AHEAD}" ]]; then
      GIT_REMOTE_AHEAD=${GIT_PROMPT_SYMBOLS_AHEAD}${GIT_REMOTE_AHEAD}
    fi
  fi
  local GIT_STAGED=${GitStatus[2]}
  local GIT_CONFLICTS=${GitStatus[3]}
  local GIT_CHANGED=${GitStatus[4]}
  local GIT_UNTRACKED=${GitStatus[5]}
  local GIT_STASHED=${GitStatus[6]}
  local GIT_CLEAN=${GitStatus[7]}

  if [[ -n "${GitStatus}" ]]; then
    local STATUS="${PROMPT_LEADING_SPACE}${GIT_PROMPT_PREFIX}${GIT_PROMPT_BRANCH}${GIT_BRANCH}${ResetColor}"

    if [[ -n "${GIT_REMOTE}" ]]; then
      STATUS="${STATUS}${GIT_PROMPT_REMOTE}${GIT_REMOTE_BEHIND_COLOR}${GIT_REMOTE_BEHIND}${ResetColor}${GIT_REMOTE_AHEAD_COLOR}${GIT_REMOTE_AHEAD}${ResetColor}"
    fi

    STATUS="${STATUS}${GIT_PROMPT_SEPARATOR}"
    if [ "${GIT_STAGED}" -ne "0" ]; then
	         StatusColor=${GIT_PROMPT_NOT_CLEAN_COLOR}
	         STATUS="${StatusColor}${STATUS}${ResetColor}"
    fi

    if [ "${GIT_CHANGED}" -ne "0" ]; then
	     StatusColor=${GIT_PROMPT_NOT_CLEAN_COLOR}
	     STATUS="${StatusColor}${STATUS}${ResetColor}"
    fi

    if [ "${GIT_UNTRACKED}" -ne "0" ]; then
  	  StatusColor=${GIT_PROMPT_NOT_CLEAN_COLOR}
  	  STATUS="${StatusColor}${STATUS}${ResetColor}"
    fi

    if [ "${GIT_CONFLICTS}" -ne "0" ]; then
	     StatusColor=${GIT_PROMPT_CONFLICTS_COLOR}
	     STATUS="${StatusColor}${STATUS}${ResetColor}"
    fi

    if [ "${GIT_CLEAN}" -eq "1" ]; then
  	  StatusColor=${GIT_PROMPT_CLEAN_COLOR}
  	  STATUS="${StatusColor}${STATUS}"
    fi

    if [ "${GIT_STASHED}" -ne "0" ]; then
      STATUS="${STATUS}${GIT_PROMPT_STASHED}${GIT_STASHED}${ResetColor}"
    fi

    STATUS="${STATUS}${StatusColor}${GIT_PROMPT_SUFFIX}"

    PS1="${LAST_COMMAND_INDICATOR}${PROMPT_START}$($prompt_callback)${STATUS}${PROMPT_END}"
    if [[ -n "${VIRTUAL_ENV}" ]]; then
      PS1="(${Blue}$(basename ${VIRTUAL_ENV})${ResetColor}) ${PS1}"
    fi

    if [[ -n "${CONDA_DEFAULT_ENV}" ]]; then
      PS1="(${Blue}$(basename ${CONDA_DEFAULT_ENV})${ResetColor}) ${PS1}"
    fi

  else
    PS1="${EMPTY_PROMPT}"
  fi
}

function prompt_callback_default {
    return
}

function run {
  if [ "`type -t prompt_callback`" = 'function' ]; then
      prompt_callback="prompt_callback"
  else
      prompt_callback="prompt_callback_default"
  fi

  if [ -z "$OLD_GITPROMPT" ]; then
    OLD_GITPROMPT=$PS1
  fi

  if [ -z "$PROMPT_COMMAND" ]; then
    PROMPT_COMMAND=setGitPrompt
  else
    PROMPT_COMMAND=${PROMPT_COMMAND%% }; # remove trailing spaces
    PROMPT_COMMAND=${PROMPT_COMMAND%\;}; # remove trailing semi-colon

    local new_entry="setGitPrompt"
    case ";$PROMPT_COMMAND;" in
      *";$new_entry;"*)
        # echo "PROMPT_COMMAND already contains: $new_entry"
        :;;
      *)
        PROMPT_COMMAND="$PROMPT_COMMAND;$new_entry"
        # echo "PROMPT_COMMAND does not contain: $new_entry"
        ;;
    esac
  fi

  git_prompt_dir
}

run
