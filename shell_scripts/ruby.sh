CHRUBY_DIR=$HOMEBREW_PREFIX/opt/chruby/share/chruby
if [ -f $CHRUBY_DIR/chruby.sh ]; then
  source $CHRUBY_DIR/chruby.sh
  source $CHRUBY_DIR/auto.sh
fi
