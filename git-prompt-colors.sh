local Time12a="\$(date +%H:%M)"
local PathShort="\w"

GIT_PROMPT_ONLY_IN_REPO=1
GIT_PROMPT_COMPACT_MODE=1             # a compact mode that uses colors to show the local status of the repo

# These are the color definitions used by gitprompt.sh
GIT_PROMPT_PREFIX="("                 # start of the git info string
GIT_PROMPT_SUFFIX=")"                 # the end of the git info string
GIT_PROMPT_SEPARATOR=" "              # separates each item

GIT_PROMPT_BRANCH=""        # the git branch that is active in the current directory

GIT_PROMPT_STAGED="${Red}●"           # the number of staged files/directories
GIT_PROMPT_CONFLICTS="${Red}✖"        # the number of files in conflict
GIT_PROMPT_CHANGED="${Blue}✚"         # the number of changed files

GIT_PROMPT_REMOTE=" "                 # the remote branch name (if any) and the symbols for ahead and behind

GIT_PROMPT_UNTRACKED="${Cyan}…"       # the number of untracked files/dirs

GIT_PROMPT_STASHED="${BoldBlue}⚑"     # the number of stashed files/dir

GIT_PROMPT_CLEAN="${BoldGreen}✔"      # a colored flag indicating a "clean" repo

GIT_PROMPT_COMMAND_OK="${Green}✔ "    # indicator if the last command returned with an exit code of 0
GIT_PROMPT_COMMAND_FAIL="${Red}✘ "   # indicator if the last command returned with an exit code of other than 0

GIT_PROMPT_CLEAN_COLOR="${Green}"     # the color to use in compact mode for clean repo 
GIT_PROMPT_NOT_CLEAN_COLOR="${Blue}"     # the color to use in compact mode for not clean repo 
GIT_PROMPT_CONFLICTS_COLOR="${Red}"   # the color to use in compact mode for conflicts

GIT_PROMPT_START_USER="${PathShort}${ResetColor}"
GIT_PROMPT_START_ROOT="${PathShort}${ResetColor}"
GIT_PROMPT_END_USER=" ${ResetColor}$ "
GIT_PROMPT_END_ROOT=" ${ResetColor}# "

# Please do not add colors to these symbols
GIT_PROMPT_SYMBOLS_AHEAD="↑·"         # The symbol for "n versions ahead of origin"
GIT_PROMPT_SYMBOLS_BEHIND="↓·"        # The symbol for "n versions behind of origin"
GIT_PROMPT_SYMBOLS_PREHASH=":"        # Written before hash of commit, if no name could be found
