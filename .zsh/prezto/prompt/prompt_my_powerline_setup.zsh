#
# A ZSH theme based on a combination of the skwp prezto theme and the robl ohmyzsh theme.
#  * RVM info shown on the right
#  * Git branch info on the left
#  * Single line prompt
#  * Time since last commit on the left
#  * Time in place of user@hostname
#
# Authors:
#   David Rice <me@davidjrice.co.uk>

ZSH_THEME_REP_TIME_SINCE_COMMIT_SHORT="%{$fg[green]%}"
ZSH_THEME_REP_TIME_SINCE_COMMIT_MEDIUM="%{$fg[yellow]%}"
ZSH_THEME_REP_TIME_SINCE_COMMIT_LONG="%{$fg[red]%}"
ZSH_THEME_REP_TIME_SINCE_COMMIT_NEUTRAL="%{$fg[cyan]%}"

function prompt_powerline_pwd {
  local pwd="${PWD/#$HOME/~}"

  if [[ "$pwd" == (#m)[/~] ]]; then
    _prompt_powerline_pwd="$MATCH"
    unset MATCH
  else
    _prompt_powerline_pwd="${${${${(@j:/:M)${(@s:/:)pwd}##.#?}:h}%/}//\%/%%}/${${pwd:t}//\%/%%}"
  fi
}

function prompt_sorin_git_info {
  if (( _prompt_sorin_precmd_async_pid > 0 )); then
    # Append Git status.
    if [[ -s "$_prompt_sorin_precmd_async_data" ]]; then
      alias typeset='typeset -g'
      source "$_prompt_sorin_precmd_async_data"
      RPROMPT+='${git_info:+${(e)git_info[status]}}'
      unalias typeset
    fi

    # Reset PID.
    _prompt_sorin_precmd_async_pid=0

    # Redisplay prompt.
    zle && zle reset-prompt
  fi
}

# returns the time since last git commit
function git_time_details() {
  # only proceed if there is actually a git repository
  if `git rev-parse --git-dir > /dev/null 2>&1`; then
    # only proceed if there is actually a commit
    if [[ $(git log 2>&1 > /dev/null | grep -c "^fatal: bad default revision") == 0 ]]; then
      # get the last commit hash
      # lc_hash=`git log --pretty=format:'%h' -1 2> /dev/null`
      # get the last commit time
      lc_time=`git log --pretty=format:'%at' -1 2> /dev/null`

      now=`date +%s`
      seconds_since_last_commit=$((now-lc_time))
      lc_time_since=`time_since_commit $seconds_since_last_commit`

      echo "$lc_time_since"
    else
      echo ""
    fi
  else
    echo ""
  fi
}

# returns the time by given seconds
function time_since_commit() {
  seconds_since_last_commit=$(($1 + 0))

  # totals
  MINUTES=$((seconds_since_last_commit / 60))
  HOURS=$((seconds_since_last_commit/3600))

  # sub-hours and sub-minutes
  DAYS=$((seconds_since_last_commit / 86400))
  SUB_HOURS=$((HOURS % 24))
  SUB_MINUTES=$((MINUTES % 60))

  if [ "$HOURS" -gt 24 ]; then
    echo "${DAYS}d${SUB_HOURS}h${SUB_MINUTES}m"
  elif [ "$MINUTES" -gt 60 ]; then
    echo "${HOURS}h${SUB_MINUTES}m"
  else
    echo "${MINUTES}m"
  fi
}

function rvm_info_for_prompt {
  if [[ -d ~/.rvm/ ]]; then
    local ruby_version=$(~/.rvm/bin/rvm-prompt)
    if [ -n "$ruby_version" ]; then
      echo "$ruby_version"
    fi
  else
    echo ""
  fi
}

function prompt_powerline_precmd {
  # Format PWD.
  prompt_powerline_pwd

  # Define prompts.
  RPROMPT='${editor_info[overwrite]}%(?:: %F{1}⏎%f)${VIM:+" %B%F{6}V%f%b"}'

  # Check for untracked files or updated submodules since vcs_info doesn't.
  if [[ ! -z $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    fmt_branch="%b%u%c${__PROMPT_SKWP_COLORS[4]}●%f"
  else
    fmt_branch="%b%u%c"
  fi
  zstyle ':vcs_info:*:prompt:*' formats "${fmt_branch}"

  vcs_info 'prompt'
  RVM_PRECMD_INFO=$(rvm_info_for_prompt)

  # Kill the old process of slow commands if it is still running.
  if (( _prompt_sorin_precmd_async_pid > 0 )); then
    kill -KILL "$_prompt_sorin_precmd_async_pid" &>/dev/null
  fi

  # Check for activated virtualenv
  if (( $+functions[python-info] )); then
      python-info
  fi

  # zstyle ':prezto:module:ruby' rvm '%r'

  # Compute slow commands in the background.
  trap prompt_sorin_git_info WINCH
  prompt_sorin_precmd_async &!
  _prompt_sorin_precmd_async_pid=$!
}

function prompt_sorin_precmd_async {
  # Get Git repository information.
  if (( $+functions[git-info] )); then
    git-info
    typeset -p git_info >! "$_prompt_sorin_precmd_async_data"
  fi

  # Signal completion to parent process.
  kill -WINCH $$
}

function prompt_powerline_setup {
  setopt LOCAL_OPTIONS
  unsetopt XTRACE KSH_ARRAYS
  prompt_opts=(cr percent subst)
  _prompt_sorin_precmd_async_pid=0
  _prompt_sorin_precmd_async_data="${TMPPREFIX}-prompt_sorin_data"

  autoload -Uz add-zsh-hook
  autoload -Uz vcs_info

  add-zsh-hook precmd prompt_powerline_precmd

  # Use extended color pallete if available.
  if [[ $TERM = *256color* || $TERM = *rxvt* ]]; then
    __PROMPT_SKWP_COLORS=(
      "%F{81}"  # turquoise
      "%F{166}" # orange
      "%F{135}" # purple
      "%F{161}" # hotpink
      "%F{118}" # limegreen
    )
  else
    __PROMPT_SKWP_COLORS=(
      "%F{cyan}"
      "%F{yellow}"
      "%F{magenta}"
      "%F{red}"
      "%F{green}"
    )
  fi

  # Enable VCS systems you use.
  zstyle ':vcs_info:*' enable bzr git hg svn

  # check-for-changes can be really slow.
  # You should disable it if you work with large repositories.
  zstyle ':vcs_info:*:prompt:*' check-for-changes true

  # Formats:
  # %b - branchname
  # %u - unstagedstr (see below)
  # %c - stagedstr (see below)
  # %a - action (e.g. rebase-i)
  # %R - repository path
  # %S - path in the repository
  # %n - user
  # %m - machine hostname

  # local fmt_branch="(${__PROMPT_SKWP_COLORS[1]}%b%f%u%c)"
  local fmt_branch="${__PROMPT_SKWP_COLORS[2]}%b%f%u%c"
  local fmt_action="${__PROMPT_SKWP_COLORS[5]}%a%f"
  local fmt_unstaged="${__PROMPT_SKWP_COLORS[2]}●%f"
  local fmt_staged="${__PROMPT_SKWP_COLORS[5]}●%f"

  # Set editor-info parameters
  zstyle ':prezto:module:editor:info:completing' format '%B%F{7}...%f%b'
  zstyle ':prezto:module:editor:info:keymap:primary' format ' %B%F{31}❯%F{70}❯%F{29}❯%f%b'
  zstyle ':prezto:module:editor:info:keymap:primary:overwrite' format ' %F{3}♺%f'
  zstyle ':prezto:module:editor:info:keymap:alternate' format ' %B%F{2}❮%F{3}❮%F{1}❮%f%b'

  # Set git-info parameters.
  zstyle ':prezto:module:git:info' verbose 'yes'
  zstyle ':prezto:module:git:info:action' format '%F{7}:%f%%B%F{9}%s%f%%b'
  zstyle ':prezto:module:git:info:added' format ' %%B%F{2}✚%f%%b'
  zstyle ':prezto:module:git:info:ahead' format ' %%B%F{13}⬆%f%%b'
  zstyle ':prezto:module:git:info:behind' format ' %%B%F{13}⬇%f%%b'
  zstyle ':prezto:module:git:info:branch' format ' %%B%F{2}%b%f%%b'
  zstyle ':prezto:module:git:info:commit' format ' %%B%F{3}%.7c%f%%b'
  zstyle ':prezto:module:git:info:deleted' format ' %%B%F{1}✖%f%%b'
  zstyle ':prezto:module:git:info:modified' format ' %%B%F{4}✱%f%%b'
  zstyle ':prezto:module:git:info:position' format ' %%B%F{13}%p%f%%b'
  zstyle ':prezto:module:git:info:renamed' format ' %%B%F{5}➜%f%%b'
  zstyle ':prezto:module:git:info:stashed' format ' %%B%F{6}✭%f%%b'
  zstyle ':prezto:module:git:info:unmerged' format ' %%B%F{3}═%f%%b'
  zstyle ':prezto:module:git:info:untracked' format ' %%B%F{7}◼%f%%b'
  zstyle ':prezto:module:git:info:keys' format \
  	 'status' '$(coalesce "%b" "%p" "%c")%s%A%B%S%a%d%m%r%U%u'

  zstyle ':vcs_info:*:prompt:*' unstagedstr   "${fmt_unstaged}"
  zstyle ':vcs_info:*:prompt:*' stagedstr     "${fmt_staged}"
  zstyle ':vcs_info:*:prompt:*' actionformats "${fmt_branch}${fmt_action}"
  zstyle ':vcs_info:*:prompt:*' formats       "${fmt_branch}"
  zstyle ':vcs_info:*:prompt:*' nvcsformats   ""

  # %v - virtualenv name.
  zstyle ':prezto:module:python:info:virtualenv' format '(%v)'

  # SPLIT RVM PROMPT INFO
  # TODO: should assign this to local variable? somehow doesn't work correctly.
  rvm_split=("${(s/@/)$(rvm_info_for_prompt)}")

  # if [ "$POWERLINE_RIGHT_B" = "" ]; then
    # POWERLINE_RIGHT_B=%D{%H:%M:%S}
    local powerline_right_b=$rvm_split[1]
  # fi

  # if [ "$POWERLINE_RIGHT_A" = "" ]; then
    local powerline_right_a=$rvm_split[2]
  # fi

  # Setup powerline style colouring
  POWERLINE_COLOR_BG_GRAY=%K{240}
  POWERLINE_COLOR_BG_LIGHT_GRAY=%K{240}
  POWERLINE_COLOR_BG_WHITE=%K{255}

  POWERLINE_COLOR_FG_GRAY=%F{240}
  POWERLINE_COLOR_FG_LIGHT_GRAY=%F{240}
  POWERLINE_COLOR_FG_WHITE=%F{255}

  POWERLINE_SEPARATOR=$'\u2b80'
  POWERLINE_R_SEPARATOR=$'\u2b82'

  if [ -z "${SSH_CONNECTION}" ]; then
      POWERLINE_LEFT_A="
%K{31}%F{white} %n %k%f%F{31}%K{59}"$POWERLINE_SEPARATOR
      POWERLINE_LEFT_B="%f%f%F{111}%K{59} $ %k%f%F{59}%K{148}"$POWERLINE_SEPARATOR
      POWERLINE_LEFT_C="%k%f%F{234}%K{148} "'${_prompt_powerline_pwd}'" %k%f%F{148}%K{29}"$POWERLINE_SEPARATOR
      POWERLINE_LEFT_D=" %k%f%F{white}%K{29}"'${python_info[virtualenv]}'" %k%f%F{29}%K{8}"$POWERLINE_SEPARATOR"%f "
      POWERLINE_LEFT_E=" %k%f%F{white}%K{8}"'${vcs_info_msg_0_}'" %k%f%F{8}"$POWERLINE_SEPARATOR"%f "
  else
      POWERLINE_LEFT_A="
%K{198}%F{white} %n %k%f%F{198}%K{59}"$POWERLINE_SEPARATOR
      POWERLINE_LEFT_B="%f%f%F{111}%K{59} $ %k%f%F{59}%K{148}"$POWERLINE_SEPARATOR
      POWERLINE_LEFT_C="%k%f%F{234}%K{148} "'${_prompt_powerline_pwd}'" %k%f%F{148}%K{29}"$POWERLINE_SEPARATOR
      POWERLINE_LEFT_D=" %k%f%F{white}%K{29}"'${python_info[virtualenv]}'" %k%f%F{29}%K{8}"$POWERLINE_SEPARATOR"%f "
      POWERLINE_LEFT_E=" %k%f%F{white}%K{8}"'${vcs_info_msg_0_}'" %k%f%F{8}"$POWERLINE_SEPARATOR"%f "
  fi

  PROMPT=$POWERLINE_LEFT_A$POWERLINE_LEFT_B$POWERLINE_LEFT_C$POWERLINE_LEFT_D$POWERLINE_LEFT_E'
${editor_info[keymap]} '
  # RPROMPT=$POWERLINE_COLOR_FG_WHITE$POWERLINE_R_SEPARATOR"%f$POWERLINE_COLOR_BG_WHITE $POWERLINE_COLOR_FG_GRAY$powerline_right_b "$POWERLINE_R_SEPARATOR"%f%k$POWERLINE_COLOR_BG_GRAY$POWERLINE_COLOR_FG_WHITE $powerline_right_a %f%k"
  # RPROMPT=$POWERLINE_COLOR_FG_WHITE$POWERLINE_R_SEPARATOR"%f$POWERLINE_COLOR_BG_WHITE $POWERLINE_COLOR_FG_GRAY"'$powerline_right_b'" "$POWERLINE_R_SEPARATOR"%f%k$POWERLINE_COLOR_BG_GRAY$POWERLINE_COLOR_FG_WHITE "'$powerline_right_a'" %f%k"
  # RPROMPT=$POWERLINE_COLOR_FG_WHITE$POWERLINE_R_SEPARATOR"%f$POWERLINE_COLOR_BG_WHITE $POWERLINE_COLOR_FG_GRAY"'$(rvm_info_for_prompt)'" "
  SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '
}

prompt_powerline_setup "$@"