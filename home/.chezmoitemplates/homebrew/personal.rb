tap "shivammathur/extensions", trusted: true
tap "shivammathur/php", trusted: true

cask "ausweisapp" # Official eID-Client of the Federal Government of Germany
cask "cardhop" # Contacts manager
cask "discord" # Voice and text chat software
cask "droplr" # Screenshot and screen recorder
cask "duckduckgo" # Web browser focusing on privacy
cask "fantastical" # Calendar software
cask "jetbrains-toolbox" # JetBrains tools manager
cask "signal" # Instant messaging application focusing on security
cask "tailscale-app" # Mesh VPN based on WireGuard
cask "telegram" # Messaging app with a focus on speed and security
cask "whatsapp" # Native desktop client for WhatsApp

mas "Bear", id: 1091189122
mas "Kagi Search", id: 1622835804
mas "Numbers", id: 361304891
mas "Pages", id: 361309726
mas "Pixelmator Pro", id: 1289583905
mas "Things", id: 904280696

{{- range .versions.phpVersions }}
brew "shivammathur/php/php@{{ . }}" # General-purpose scripting language
brew "shivammathur/extensions/amqp@{{ . }}" # AMQP PHP extension
brew "shivammathur/extensions/apcu@{{ . }}" # APCU PHP extension
brew "shivammathur/extensions/grpc@{{ . }}" # gRPC PHP extension
brew "shivammathur/extensions/igbinary@{{ . }}" # IGBinary PHP extension
brew "shivammathur/extensions/mongodb@{{ . }}" # MongoDB PHP extension
brew "shivammathur/extensions/msgpack@{{ . }}" # MSGPack PHP extension
brew "shivammathur/extensions/protobuf@{{ . }}" # Protobuf PHP extension
brew "shivammathur/extensions/redis@{{ . }}" # Redis PHP extension
brew "shivammathur/extensions/xdebug@{{ . }}" # XDebug PHP extension

{{- end }}
