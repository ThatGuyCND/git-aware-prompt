# Users can set the dirtysymb env var in their .bash_profile, etc,
# or they can leave it unset and it will default to the '*'.
export dirtysymb=${dirtysymb:="(;_;)"};

##
# Calculate git status information
# Consolidates branch and dirty status detection with repo check optimization
##
calc_git_staff() {
  # First check if we're in a git repository to avoid unnecessary git commands
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then

    # Get git branch
    local branch
    if branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null); then
      if [[ "$branch" == "HEAD" ]]; then
        branch='detached*'
      fi
      git_branch="($branch)"
    else
      git_branch=""
    fi

    # Get git status
    local status=$(git status --porcelain 2> /dev/null)
    if [[ "$status" != "" ]]; then
      local modified_count=$(echo "$status" | grep -c '^.M' || true)
      local added_count=$(echo "$status" | grep -c '^[MA]' || true)
      local deleted_count=$(echo "$status" | grep -c '^D\|^.D' || true)
      local renamed_count=$(echo "$status" | grep -c '^R' || true)
      local untracked_count=$(echo "$status" | grep -c '^??' || true)

      # Build status summary with only non-zero counts
      local status_parts=()
      [[ $modified_count -gt 0 ]] && status_parts+=("M:$modified_count")
      [[ $added_count -gt 0 ]] && status_parts+=("A:$added_count")
      [[ $deleted_count -gt 0 ]] && status_parts+=("D:$deleted_count")
      [[ $renamed_count -gt 0 ]] && status_parts+=("R:$renamed_count")
      [[ $untracked_count -gt 0 ]] && status_parts+=("U:$untracked_count")

      local status_summary="[$(IFS=' '; echo "${status_parts[*]}")]"

      # Only show dirtysymb if there are actual changes (not just untracked files)
      if [[ $((modified_count + added_count + deleted_count + renamed_count)) -gt 0 ]]; then
        git_dirty="$dirtysymb $status_summary"
      else
        git_dirty="$status_summary"
      fi
    else
      git_dirty=''
    fi
  else
    # Not in a git repository - clear git variables
    git_branch=""
    git_dirty=""
  fi
}

PROMPT_COMMAND="calc_git_staff; $PROMPT_COMMAND"

# Default Git enabled prompt with dirty state
# export PS1="\u@\h \w \[$txtcyn\]\$git_branch\[$txtred\]\$git_dirty\[$txtrst\]\$ "

# Another variant:
# export PS1="\[$bldgrn\]\u@\h\[$txtrst\] \w \[$bldylw\]\$git_branch\[$txtcyn\]\$git_dirty\[$txtrst\]\$ "

# Default Git enabled root prompt (for use with "sudo -s")
# export SUDO_PS1="\[$bakred\]\u@\h\[$txtrst\] \w\$ "
