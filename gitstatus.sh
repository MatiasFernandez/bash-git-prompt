#!/bin/bash
# -*- coding: UTF-8 -*-
# gitstatus.sh -- produce the current git repo status on STDOUT
# Functionally equivalent to 'gitstatus.py', but written in bash (not python).
#
# Alan K. Stebbens <aks@stebbens.org> [http://github.com/aks]

# helper functions
count_lines() { echo "$1" | egrep -c "^$2" ; }
all_lines() { echo "$1" | grep -v "^$" | wc -l ; }

#REMOVE: This is duplicated code and must be removed from this file
function load_git_prompt_config_file() {
  if [[ -z "$__GIT_PROMPT_COLORS_FILE" ]]; then
    __GIT_PROMPT_COLORS_FILE="$__GIT_PROMPT_DIR/git-prompt-colors.sh"
  fi

  if [[ -n "$__GIT_PROMPT_COLORS_FILE" && -f "$__GIT_PROMPT_COLORS_FILE" ]]; then
    source "$__GIT_PROMPT_COLORS_FILE"
  fi
}

#REMOVE: This is duplicated code and must be removed from this file
function set_git_prompt_home_dir() {
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

set_git_prompt_home_dir
load_git_prompt_config_file

symbols_ahead="${GIT_PROMPT_SYMBOLS_AHEAD}"
symbols_behind="${GIT_PROMPT_SYMBOLS_BEHIND}"
symbols_prehash="${GIT_PROMPT_SYMBOLS_PREHASH}"

gitsym=`git symbolic-ref HEAD`

# if "fatal: Not a git repo .., then exit
case "$gitsym" in fatal*) exit 0 ;; esac

# the current branch is the tail end of the symbolic reference
branch="${gitsym##refs/heads/}"    # get the basename after "refs/heads/"

gitstatus=`git diff --name-status 2>&1`

# if the diff is fatal, exit now
case "$gitstatus" in fatal*) exit 0 ;; esac


staged_files=`git diff --staged --name-status`

num_changed=$(( `all_lines "$gitstatus"` - `count_lines "$gitstatus" U` ))
num_conflicts=`count_lines "$staged_files" U`
num_staged=$(( `all_lines "$staged_files"` - num_conflicts ))
num_untracked=`git status -s -uall | grep -c "^??"`
if [[ -n "$GIT_PROMPT_IGNORE_STASH" ]]; then
  num_stashed=0
else	
  num_stashed=`git stash list | wc -l`
fi

clean=0
if (( num_changed == 0 && num_staged == 0 && num_U == 0 && num_untracked == 0)) ; then
  clean=1
fi

if [[ -z "$branch" ]]; then
  tag=`git describe --exact-match`
  if [[ -n "$tag" ]]; then
    branch="$tag"
  else
    branch="${symbols_prehash}`git rev-parse --short HEAD`"
  fi
else
  remote_name=`git config branch.${branch}.remote`

  if [[ -n "$remote_name" ]]; then
    merge_name=`git config branch.${branch}.merge`
  else
    remote_name='origin'
    merge_name="refs/heads/${branch}"
  fi

  if [[ "$remote_name" == '.' ]]; then
    remote_ref="$merge_name"
  else
    remote_ref="refs/remotes/$remote_name/${merge_name##refs/heads/}"
  fi

  # detect if the local branch is tracking a remote branch
  cmd_output=$(git rev-parse --abbrev-ref ${branch}@{upstream} 2>&1 >/dev/null)

  if [ `count_lines "$cmd_output" "fatal: No upstream"` == 1 ] ; then
    is_tracking_remote_branch=0
  else
    is_tracking_remote_branch=1
  fi

  # get the revision list, and count the leading "<" and ">"
  revgit=`git rev-list --left-right ${remote_ref}...HEAD`
  num_revs=`all_lines "$revgit"`
  num_ahead=`count_lines "$revgit" "^>"`
  num_behind=$(( num_revs - num_ahead ))
  if (( num_behind > 0 )) ; then
    behind="${num_behind}"
  else
    behind="."
  fi
  if (( num_ahead > 0 )) ; then
    ahead="${num_ahead}"
  else
    ahead="."
  fi
fi

for w in "$branch" "$is_tracking_remote_branch" $num_staged $num_conflicts $num_changed $num_untracked $num_stashed $clean $behind $ahead; do
  echo "$w"
done

exit
