#!/bin/bash

NOTES_ROOT_FOLDER=/home/nrubin19/notes

# open note
function on() {
  file=$(find $NOTES_ROOT_FOLDER | grep md | fzf)
  nvim "$file"
}

# new note
function nn() {
  dir=$( find $NOTES_ROOT_FOLDER -type d -print | fzf)
  date=$(date +%m-%d-%Y)

  printf 'Enter Note Title: '
  read -r note_title

  note_filename=${note_title// /_} # Replace spaces with dashes
  note_filename=$(echo $note_filename | tr '[:upper:]' '[:lower:]') # Convert to lower case.
  note_filepath="$dir/$note_filename.md"

  touch $note_filepath # Create empty note file.

  echo $note_title >> $note_filepath # Add the name of the note as the first line of the note.
  echo "=" >> $note_filepath # Add an "=" beneath the first line to make it a Markdown title.

  echo "Created note: $note_filepath"

  nvim $note_filepath # Open the note in Vim.
}
