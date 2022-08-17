NOTES_ROOT_FOLDER=/Users/nate/Notes

# open note
alias on='vim $(find $NOTES_ROOT_FOLDER | grep md | fzf)'

# new note
function nn() {
  dir=$(ls -d $NOTES_ROOT_FOLDER/**/*/ | fzf)
  date=$(date +%m-%d-%Y)

  printf 'Enter Note Title: '
  read -r note_title

  note_filename=${note_title// /_} # Replace spaces with dashes
  note_filename=$(echo $note_filename | tr '[:upper:]' '[:lower:]') # Convert to lower case
  note_filepath="$dir$note_filename.md"

  touch $note_filepath

  echo $note_title >> $note_filepath
  echo "=" >> $note_filepath

  echo "Created note: $note_filepath"

  vim $note_filepath
}
