# git prompt for bash

A ``bash`` prompt that displays information about the current git repository.
In particular the branch name, status and difference with remote branch.

This is my own version of [Bash git prompt](https://github.com/magicmonty/bash-git-prompt) customized to my taste. The objective is make it simpler, both the aspect and the code.

I have to say thanks to [magicmonty](https://github.com/magicmonty/) for his great work doing bash-git-prompt. I only decided to make my own fork because I wanted a more personalized prompt that works better for me, and I thought making a fork is the easiest way to achieve that :)

## Install

- Clone this repository to your homedir
   e.g. ``git clone https://github.com/MatiasFernandez/bash-git-prompt .bash-git-prompt``
- Source the file ``gitprompt.sh`` from your ``~/.bashrc`` config file:

```sh
   # ... some other config in .bashrc ...

   # gitprompt configuration

   # Set config variables first
   GIT_PROMPT_ONLY_IN_REPO=1

   # as last entry source the gitprompt script
   source ~/.bash-git-prompt/gitprompt.sh
```

- Go in a git repository and test it!

## Configuration

- The default colors and some variables for tweaking the prompt are defined 
   within ``gitprompt.sh``, but may be overridden by copying ``git-prompt-colors.sh`` 
   to your home directory at ``~/.git-prompt-colors.sh``.  This file may also be found in the same
   directory as ``gitprompt.sh``, but without the leading ``.``.

- You can use ``GIT_PROMPT_START_USER``, ``GIT_PROMPT_START_ROOT``, ``GIT_PROMPT_END_USER`` and ``GIT_PROMPT_END_ROOT`` in your ``.git-prompt-colors.sh`` to tweak your prompt. You can also override the start and end of the prompt by setting ``GIT_PROMPT_START`` and ``GIT_PROMPT_END`` before you source the ``gitprompt.sh``

- The current git repo information is obtained by the script `gitstatus.sh`.

- You can define ``prompt_callback`` function to tweak your prompt dynamically.
```sh
function prompt_callback {
    if [ `jobs | wc -l` -ne 0 ]; then
        echo -n " jobs:\j"
    fi
}
```

- If you want to show the git prompt only, if you are in a git repository you can set ``GIT_PROMPT_ONLY_IN_REPO=1`` before sourcing the gitprompt script

- You can show an additional indicator at the start of the prompt, which shows the result of the last executed command by setting ``GIT_PROMPT_SHOW_LAST_COMMAND_INDICATOR=1`` before sourcing the gitprompt script

- It is now possible to disable the fetching of the remote repository either globally by setting ``GIT_PROMPT_FETCH_REMOTE_STATUS=0`` in your .bashrc or
  on a per repository basis by creating a file named ``.bash-git-rc`` with the content ``FETCH_REMOTE_STATUS=0`` in the root of your git repository.

-  You can get help on the git prompt with the function ``git_prompt_help``.
    Examples are available with ``git_prompt_examples``.

**Enjoy it! I hope it make your life easier!**