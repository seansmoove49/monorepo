#!/bin/bash
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

printf "%s | \$%.2f\n" "$model" "$cost"

five_hour=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_hour_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

line2=""
if [ -n "$five_hour" ]; then
  five_hour_used=$(awk -v u="$five_hour" 'BEGIN{printf "%.0f", u}')
  line2="5h used: ${five_hour_used}% (resets $(date -r "$five_hour_reset" '+%a %-I:%M%p'))"
fi

if [ -n "$week" ]; then
  week_used=$(awk -v u="$week" 'BEGIN{printf "%.0f", u}')
  week_line="wk used: ${week_used}% (resets $(date -r "$week_reset" '+%a %-I:%M%p'))"
  if [ -n "$line2" ]; then
    line2="$line2 | $week_line"
  else
    line2="$week_line"
  fi
fi

printf "%s\n" "$line2"
