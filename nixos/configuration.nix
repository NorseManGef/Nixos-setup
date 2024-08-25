# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, pkgs-unstable, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.home-manager
      inputs.sops-nix.nixosModules.sops
      ./bootloader.nix
    ];

  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    
    age.keyFile = "/home/norsemangef/.config/sops/age/keys.txt";

    #secrets = {
     # "openvpn/openvpn-pass/password" = { };
    #};
  };

  boot.kernelModules = [ "kvm-amd" ];

  #Themes!
  stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
    image = ./pbmam94nqapc1.png;
    enable = true;

    targets = {
      grub.enable = false;
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
    };

    fonts = {
      monospace = {
	package = pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];};
	name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
	package = pkgs.dejavu_fonts;
	name = "DejaVu Sans";
      };
      serif = {
	package = pkgs.dejavu_fonts;
	name = "DejaVu Serif";
      };
      sizes = {
	applications = 12;
	terminal = 15;
	popups = 10;
      };
    };

    opacity = {
      applications = 0.5;
      terminal = 0.85;
      popups = 1.0;
    };

    polarity = "dark";
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };

  # XDG Portals
  xdg = {
    autostart.enable = true;
    portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal
        pkgs.xdg-desktop-portal-gtk
      ];
    };
  };

  # Security
  security = {
    rtkit.enable = true;
    pam.services.hyprlock = {};
  };

  # Services
  services = {
    xserver = {
      enable = true;
      xkb = {
	layout = "us";
	variant = "";
      };
      excludePackages = [ pkgs.xterm ];
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
    };
    libinput.enable = true;
    dbus.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
    hardware = {
      openrgb = {
        enable = true;
        package = pkgs.openrgb-with-all-plugins;
      };
    };
    flatpak.enable = true;
    qemuGuest.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;
    devmon.enable = true;
  };

  boot.kernelParams = [ "acpi_enforce_resources=lax" ]; # for openrgb

  programs = {
    hyprland = {
      enable = true;
      package = inputs.hyprland.packages."${pkgs.system}".hyprland;
      xwayland.enable = true;
    };
    waybar = {
      enable = true;
    };
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
    adb.enable = true;
    steam = {
      enable = true;
    };
    gamescope.enable = true;
    alvr = {
      enable = true;
      openFirewall = true;
    };
    neovim = {
      enable = true;
      defaultEditor = true;
    };

    nix-ld.enable = true;
    virt-manager.enable = true;
    dconf.enable = true;
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
    };
  };

  fonts.packages = with pkgs; [
    ipafont
    migu
    vistafonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
  ];

  fonts.fontDir.enable = true;

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.norsemangef = {
    isNormalUser = true;
    description = "norsemangef";
    extraGroups = [ "networkmanager" "wheel" "adbusers" "libvirtd" ];
    packages = with pkgs; [
      discord
      sidequest
      heroic
      aseprite
      superTuxKart
      prismlauncher
    ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "norsemangef" = import ./home.nix;
    };
    sharedModules = [{
      stylix.targets.waybar.enable = false;
    }];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = (with pkgs; [
    polkit
    polkit_gnome
    gparted
    neovim
    alacritty
    dunst
    wlr-randr
    wl-clipboard
    hyprland-protocols
    hyprpicker
    xdg-desktop-portal-hyprland
    swww
    wofi
    firefox-wayland
    xdg-utils
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    qt5.qtwayland
    qt6.qmake
    qt6.qtwayland
    adwaita-qt
    adwaita-qt6
    pavucontrol
    git
    hyprlock
    fastfetch
    wine
    wine-wayland
    hyprshot
    protontricks
    lutris
    vesktop
    unzip
    qemu
    quickemu
    gimp
    i2c-tools
    sops
    bottles
    usbutils
    udiskie
    musikcube
  ])
  ++( with pkgs-unstable; [
    floorp
  ]);

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
