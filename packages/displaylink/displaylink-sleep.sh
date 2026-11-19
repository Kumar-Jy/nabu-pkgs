#!/usr/bin/env bash
# Copyright (c) 2015 - 2019 DisplayLink (UK) Ltd.

suspend_displaylink-driver()
{
  # If DisplayLinkManager is not running, skip
  pgrep -x DisplayLinkManager >/dev/null || return 0

  #flush any bytes in pipe
  while read -n 1 -t 1 SUSPEND_RESULT < /tmp/PmMessagesPort_out 2>/dev/null; do : ; done;

  #suspend DisplayLinkManager with a timeout so it never blocks
  timeout 1 bash -c 'echo "S" > /tmp/PmMessagesPort_in' 2>/dev/null || true

  if [[ -p /tmp/PmMessagesPort_out ]]; then
    #wait until suspend of DisplayLinkManager finish (max 2 seconds)
    read -n 1 -t 2 SUSPEND_RESULT < /tmp/PmMessagesPort_out 2>/dev/null || true
  fi
}

resume_displaylink-driver()
{
  # If DisplayLinkManager is not running, skip
  pgrep -x DisplayLinkManager >/dev/null || return 0

  #resume DisplayLinkManager with a 1-second timeout so it never blocks systemd-sleep
  timeout 1 bash -c 'echo "R" > /tmp/PmMessagesPort_in' 2>/dev/null || true
}

main_systemd()
{
  case "$1/$2" in
  pre/*)
    suspend_displaylink-driver
    ;;
  post/*)
    resume_displaylink-driver
    ;;
  esac
}
main_pm()
{
  case "$1" in
    suspend|hibernate)
      suspend_displaylink-driver
      ;;
    resume|thaw)
      resume_displaylink-driver
      ;;
  esac
  true
}

DIR=$(cd "$(dirname "$0")" && pwd)

if [[ $DIR == *systemd* ]]; then
  main_systemd "$@"
elif [[ $DIR == *pm* ]]; then
  main_pm "$@"
fi

