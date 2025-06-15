# /home/roger/regolith-nix-starter-config/hosts/regolith/home.nix
{ pkgs, ... }:

{
  # IMPORTANT: Set your Home Manager state version.
  # This MUST match what you configured in your flake.nix (e.g., "24.05")
  home.stateVersion = "24.05"; # Ensure this is correct for your system/channel

  # Add some user-specific packages
  home.packages = with pkgs; [
    hello
    # If you decide to move lsd and fzf from environment.systemPackages in users.nix,
    # you would add them here:
    # lsd
    # fzf
  ];

  # --- Zsh Configuration (MIGRATED from users.nix) ---
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    ohMyZsh = {
      enable = true;
      plugins = ["git"];
      theme = "agnoster";
    };

    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    promptInit = ''
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
}
