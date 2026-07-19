if command -v assume > /dev/null; then
  alias assume=". assume"
fi

alias wget="wget --hsts-file=$XDG_DATA_HOME/wget-hsts"
