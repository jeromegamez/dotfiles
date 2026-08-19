## Personal

brew "ansible" # Automate deployment, configuration, and upgrading
brew "ansible-lint" # Checks ansible playbooks for practices and behaviour
brew "cookiecutter" # Utility that creates projects from templates
brew "fastfetch" # Like neofetch, but much faster because written mostly in C
brew "gnupg" # GNU Pretty Good Privacy (PGP) package
brew "pinentry-mac" # Pinentry for GPG on Mac
brew "restic" # Fast, efficient and secure backup program
brew "streamrip" # Scriptable music downloader for Qobuz, Tidal, SoundCloud, and Deezer
brew "yt-dlp" # Feature-rich command-line audio/video downloader

cask "carbon-copy-cloner" # Hard disk backup and cloning utility
cask "cardhop" # Contacts manager
cask "cleanshot" # Screen capturing tool
cask "discord" # Voice and text chat software
cask "droplr" # Screenshot and screen recorder
cask "fantastical" # Calendar software
cask "feed-the-beast" # Minecraft mod downloader and manager
cask "gpg-suite-no-mail" # GPG Suite (without GPG Mail)
cask "keepassxc" # Password manager app
cask "jetbrains-toolbox" # JetBrains tools manager
cask "prismlauncher" # Minecraft launcher
cask "signal" # Instant messaging application focusing on security
cask "steam" # Video game digital distribution service
cask "tailscale-app" # Mesh VPN based on WireGuard
cask "telegram" # Messaging app with a focus on speed and security
cask "whatsapp" # Native desktop client for WhatsApp
cask "wiso-steuer-2026" # Tax declaration for the fiscal year 2025
cask "zen" # Gecko based web browser

mas "AusweisApp", id: 948660805
mas "Bear", id: 1091189122
mas "HP", id: 1474276998
mas "Kagi Search", id: 1622835804
mas "Numbers", id: 361304891
mas "Pages", id: 361309726
mas "Pixelmator Pro", id: 1289583905
mas "Things", id: 904280696

{{- range .versions.php.installed }}
{{- if eq . $.versions.php.default }}
brew "shivammathur/php/php", trusted: true # General-purpose scripting language
{{- else }}
brew "shivammathur/php/php@{{ . }}", trusted: true # General-purpose scripting language
{{- end }}
brew "shivammathur/extensions/amqp@{{ . }}", trusted: true # AMQP PHP extension
brew "shivammathur/extensions/apcu@{{ . }}", trusted: true # APCU PHP extension
brew "shivammathur/extensions/grpc@{{ . }}", trusted: true # gRPC PHP extension
brew "shivammathur/extensions/igbinary@{{ . }}", trusted: true # IGBinary PHP extension
brew "shivammathur/extensions/mongodb@{{ . }}", trusted: true # MongoDB PHP extension
brew "shivammathur/extensions/msgpack@{{ . }}", trusted: true # MSGPack PHP extension
brew "shivammathur/extensions/protobuf@{{ . }}", trusted: true # Protobuf PHP extension
brew "shivammathur/extensions/phpredis@{{ . }}", trusted: true # Redis PHP extension
brew "shivammathur/extensions/xdebug@{{ . }}", trusted: true # XDebug PHP extension

{{- end }}
