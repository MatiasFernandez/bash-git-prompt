#!/bin/bash
# -*- coding: UTF-8 -*-
# gitstatus.sh -- produce the current git repo status on STDOUT
#
# Alan K. Stebbens <aks@stebbens.org> [http://github.com/aks]

# helper functions
count_lines() { echo "$1" | egrep -c "^$2" ; }
all_lines() { echo "$1" | grep -v "^$" | wc -l ; }

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
num_stashed=`git stash list | wc -l`

if (( num_changed == 0 && num_staged == 0 && num_untracked == 0 )) ; then
  clean=true
else
  clean=false
fi

is_tracking_remote_branch=false

if [[ -z "$branch" ]]; then
  tag=`git describe --exact-match`
  if [[ -n "$tag" ]]; then
    branch="$tag"
    ref_type="tag"
  else
    branch="`git rev-parse --short HEAD`"
    ref_type="hash"
  fi
else
  ref_type="branch"
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

  if [ `count_lines "$cmd_output" "fatal: no upstream"` == 0 ] ; then
    is_tracking_remote_branch=true
  fi

  # get the revision list, and count the leading "<" and ">"
  revgit=`git rev-list --left-right ${remote_ref}...HEAD`
  num_revs=`all_lines "$revgit"`
  num_ahead=`count_lines "$revgit" "^>"`
  num_behind=$(( num_revs - num_ahead ))
fi

for w in "$ref_type" "$branch" $is_tracking_remote_branch $num_staged $num_conflicts $num_changed $num_untracked $num_stashed $clean $num_behind $num_ahead; do
  echo "$w"
done

exit
