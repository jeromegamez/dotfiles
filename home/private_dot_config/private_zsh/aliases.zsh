if command -v assume > /dev/null; then
  export GRANTED_ENABLE_AUTO_REASSUME=true
  export GRANTED_ALIAS_CONFIGURED=true
  alias assume=". assume"
fi

alias wget='wget --hsts-file="$XDG_DATA_HOME/wget-hsts"'
