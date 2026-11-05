#!/usr/bin/env bash
# Toggle push-to-talk dictation: run once to start recording, again to stop,
# transcribe with whisper.cpp, and copy the text to the clipboard.
set -euo pipefail

MODEL="${WHISPER_MODEL:-$HOME/.local/share/whisper/ggml-large-v3-turbo-q5_0.bin}"
STATE_DIR="${TMPDIR:-/tmp}/dictate"
WAV="$STATE_DIR/take.wav"
PIDFILE="$STATE_DIR/ffmpeg.pid"
mkdir -p "$STATE_DIR"

notify() { osascript -e "display notification \"$1\" with title \"Dictate\"" >/dev/null 2>&1 || true; }

# --- already recording? then stop and transcribe ---
if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  pid=$(cat "$PIDFILE")
  # ffmpeg flushes a valid wav header on SIGINT; SIGKILL would corrupt the file.
  kill -INT "$pid" 2>/dev/null || true
  for _ in $(seq 1 40); do kill -0 "$pid" 2>/dev/null || break; sleep 0.1; done
  rm -f "$PIDFILE"

  [[ -s "$WAV" ]] || { notify "No audio captured"; exit 1; }
  notify "Transcribing…"

  text=$(whisper-cli -m "$MODEL" -f "$WAV" --no-timestamps --no-prints -otxt -of - 2>/dev/null \
         | tr '\n' ' ' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/  */ /g')

  if [[ -z "$text" ]]; then notify "Nothing transcribed"; exit 1; fi
  printf '%s' "$text" | pbcopy
  notify "Copied: ${text:0:60}"
  exit 0
fi

# --- not recording: start ---
# :0 is the default avfoundation audio input. Override with DICTATE_INPUT.
ffmpeg -nostdin -loglevel error -y \
  -f avfoundation -i "${DICTATE_INPUT:-:0}" \
  -ac 1 -ar 16000 -c:a pcm_s16le "$WAV" &
echo $! > "$PIDFILE"
notify "Recording… run again to stop"
