# Copy clipboard
ccb() {
  win32yank.exe -i
}

# Paste clipboard
pcb() {
  win32yank.exe -o --lf
}