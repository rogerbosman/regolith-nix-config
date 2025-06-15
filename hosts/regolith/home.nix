# /home/roger/regolith-nix-starter-config/hosts/regolith/home.nix
{ pkgs, ... }:

{
  # IMPORTANT: Set your Home Manager state version.
  # This MUST match what you configured in your flake.nix (e.g., "24.05")
  home.stateVersion = "24.05"; # Ensure this is correct for your system/channel

  # Add some user-specific packages
  home.packages = with pkgs; [
    hello
    vlc
    # If you decide to move lsd and fzf from environment.systemPackages in users.nix,
    # you would add them here:
    # lsd
    # fzf
  ];

  # --- Zsh Configuration (MIGRATED from users.nix) ---
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    oh-my-zsh = {
      enable = true;
      theme = "powerlevel10k/powerlevel10k";
      plugins = [
        "git" # Excellent Git integration (aliases, prompt info)
        "zsh-autosuggestions" # Auto-suggestions from history
        "zsh-syntax-highlighting" # Syntax highlighting as you type
        # Add more plugins as desired, e.g.:
        # "docker"
        # "web-search"
        # "history"
      ];
    };

    autosuggestion = { # <-- MUST be an attribute set
      enable = true;   # <-- 'enable' inside the set
    };
    syntaxHighlighting = { # <-- MUST be an attribute set
      enable = true;      # <-- 'enable' inside the set
    };

    /*
    # Optional: Set common Zsh options
    setOptions = [
      "AUTO_CD"       # Change directory by typing only the directory name
      "EXTENDED_GLOB" # Extended globbing (e.g., recursive wildcards)
    ];

    # Optional: Custom aliases for convenience
    shellAliases = {
      ll = "ls -l";
      la = "ls -la";
      # ...
    };
    */

    initContent = ''
      fastfetch -c $HOME/.config/fastfetch/config-compact.jsonc

      #pokemon colorscripts like.
      # Make sure to install krabby package
      #krabby random --no-mega --no-gmax --no-regional --no-title -s;

      # Set-up icons for files/directories in terminal using lsd
      alias ls='lsd'
      alias l='ls -l'
      alias la='ls -a'
      alias lla='ls -la'
      alias lt='ls --tree'

      source <(fzf --zsh);

      HISTFILE=~/.zsh_history;
      HISTSIZE=10000;
      SAVEHIST=10000;
      setopt appendhistory;
      
      if [[ -f "$HOME/.p10k.zsh" ]]; then
        source "$HOME/.p10k.zsh"
      fi
    '';
  };

  # You can now add other Home Manager specific configurations here,
  # such as Git user config, other program settings, dotfiles, etc.
  # For example, to manage your Git user name and email through Home Manager:
  # programs.git = {
  #   enable = true;
  #   userName = "Roger";
  #   userEmail = "roger@example.com";
  #   extraConfig = {
  #     init.defaultBranch = "main";
  #   };
  # };
  
  # 4. Ensure your custom ~/.p10k.zsh is managed
  # Home Manager needs to know about your generated .p10k.zsh file
  # so it's not overwritten by Nix.
  # You will run `p10k configure` *once* in your terminal, which creates this file.
  # Then you copy it to your Nix config directory.
  #home.file.".p10k.zsh".source = ./p10k.zsh; # Make sure this path is correct relative to your config file!

  # 5. Add fzf if you want it (highly recommended for power users)
  #programs.fzf.enable = true; # Home Manager integrates it nicely
}
