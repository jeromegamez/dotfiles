## Personal

brew "ansible" # Automate deployment, configuration, and upgrading
brew "ansible-lint" # Checks ansible playbooks for practices and behaviour
brew "cookiecutter" # Utility that creates projects from templates
brew "fastfetch" # Like neofetch, but much faster because written mostly in C
brew "restic" # Fast, efficient and secure backup program
brew "streamrip" # Scriptable music downloader for Qobuz, Tidal, SoundCloud, and Deezer
brew "yt-dlp" # Feature-rich command-line audio/video downloader

cask "rokartur/betteraudio/betteraudio", trusted: true # Audio processing tool for macOS
cask "carbon-copy-cloner" # Hard disk backup and cloning utility
cask "cardhop" # Contacts manager
cask "chatgpt" # ChatGPT desktop app with Codex
cask "discord" # Voice and text chat software
cask "droplr" # Screenshot and screen recorder
cask "duckduckgo" # Web browser focusing on privacy
cask "fantastical" # Calendar software
cask "feed-the-beast" # Minecraft mod downloader and manager
cask "google-chrome" # Web browser
cask "keepassxc" # Password manager app
cask "jetbrains-toolbox" # JetBrains tools manager
cask "prismlauncher" # Minecraft launcher
cask "signal" # Instant messaging application focusing on security
cask "steam" # Video game digital distribution service
cask "tailscale-app" # Mesh VPN based on WireGuard
cask "telegram" # Messaging app with a focus on speed and security
cask "whatsapp" # Native desktop client for WhatsApp
cask "wiso-steuer-2026" # Tax declaration for the fiscal year 2025

mas "AusweisApp", id: 948660805
mas "Bear", id: 1091189122
mas "HP", id: 1474276998
mas "Kagi Search", id: 1622835804
mas "Numbers", id: 361304891
mas "Pages", id: 361309726
mas "Pixelmator Pro", id: 1289583905
mas "Things", id: 904280696

{{- range .versions.phpVersions }}
tap "shivammathur/extensions", trusted: true
tap "shivammathur/php", trusted: true

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
