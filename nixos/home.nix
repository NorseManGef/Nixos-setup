{ config, pkgs, inputs, ... }:

{
 home.username = "norsemangef";
 home.homeDirectory = "/home/norsemangef";
 home.enableNixpkgsReleaseCheck = false;

  home.packages = [
    pkgs.hello
    pkgs.nerdfonts
    pkgs.zoxide
	pkgs.fzf
    pkgs.atuin
    pkgs.ncspot
    pkgs.dunst
    pkgs.btop
    pkgs.onlyoffice-bin
  ];

  nixpkgs = {
    overlays = [
      (final: prev: {
        vimPlugins = prev.vimPlugins // {
          nvim-transparent = prev.vimUtils.buildVimPlugin {
            name = "Transparent Neovim";
            src = inputs.plugin-nvim-transparent;
          };
        };
      })
    ];
  };

  services = {
    dunst = {
      enable = true;
      waylandDisplay = "1";
      settings = {
        global = {
          width = 300;
          height = 300;
          offset = "30x50";
          origin = "top-right";
          #font = "HeavyData Nerd Font";
          corner_radius = 300;
          corners = "all";
        };
      };
    };
  };
   
  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      shellAliases = {
        nswitch = "sudo nixos-rebuild switch --flake ~/nixos/#nixos";
        nswitch-upgrade = "cd ~/nixos && sudo nix flake update && sudo nixos-rebuild switch --upgrade --flake ~/nixos/#nixos";
		ntest = "sudo nixos-rebuild test --flake ~/nixos/#nixos";
		nboot = "sudo nixos-rebuild boot --flake ~/nixos/#nixos";
		nshutdown = "sudo nixos-rebuild boot --flake ~/nixos/#nixos && shutdown now";
		fetch = "fastfetch";
		edhome = "cd ~/nixos/ && sudo -E -s nvim home.nix";
		edconf = "cd ~/nixos/ && sudo -E -s nvim configuration.nix";
        edflake = "cd ~/nixos/ && sudo -E -s nvim flake.nix";
        svim = "sudo -E -s nvim";
        rust-shell = "cd ~/Coding/rust && nix-shell rust.nix";
      };
    };
    starship = {
      enable = true;
      enableBashIntegration = true;
    };
    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };
    atuin = {
      enable = true;
      enableBashIntegration = true;
      #settings = {
       #   enter_accept = false;
      #};
    };
    hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          grace = 0;
          hide_cursor = true;
          no_fade_in = false;
        };

        background = [
          {
            monitor = "";
            path = "~/Pictures/walls/Animated-retro-city.png";
            blur_passes = 0;
            blur_size = 0;
          }
        ];
      };
    };
    alacritty.enable = true;

    ncspot = {
      enable = true;
    };

    waybar = {
      enable = true;
      settings = [
        {
          layer = "top";
          position = "top";
          height = 41;
          output = [
            "DP-3"
            "HDMI-A-1"
          ];
          modules-left = [ "tray" "hyprland/window" ];
          modules-center = [ "custom/hello-from-waybar" "hyprland/workspaces" ];
          modules-right = [ "memory" "cpu" "temperature" "clock" ];

          "custom/hello-from-waybar" = {
            format = "<span font_family='HeavyData Nerd Font'>{}</span>";
            max-length = 40;
            interval = "once";
            exec = pkgs.writeShellScript "hello-from-waybar" ''
            echo "   NixS "
            '';
          };

          "hyprland/workspaces" = {
            format = "{icon}";
            format-icons = {
              default = "";
              active = "";
              urgent = "";
            };
            on-scroll-up = "hyprctl dispatch workspace e+1";
            on-scroll-down = "hyprctl dispatch workspace e-1";
            on-click = "activate";
          };

          "memory" = {
            interval = 5;
            format = "   {}󰏰 ";
          };

          "cpu" = {
            format = "󰍛 {}󰏰 ";
          };

          "temperature" = {
            format = "{}C  ";
          };

          "clock" = {
            format = "󰺗 {:%H:%M  󰃭 %a %d󰿟%m󰿟%Y} ";
          };

          "tray" ={
            icon-size = 20;
            spacing = 9;
          };

          "hyprland/window" = {
            format = "  {}  ";
            max-length = 70;
          };
        }
      ];

      style = ''
        * {
          font-size: 18px;
          font-family: HeavyData Nerd Font;
        }

        window#waybar {
          background-color: rgba(36, 40, 59, 0);
          border-bottom: 2px solid rgba(42, 195, 222, 0);
          border-radius: 2px;
          color:#f7768e;
        }

        #tray {
          background-color: rgba(36, 40, 59, 1);
          border-bottom: 5px solid rgba(247, 118, 142, 1);
        }
        #window {
          background-color: rgba(36, 40, 59, 1);
          border-bottom: 5px solid rgba(247, 118, 142, 1);
          border-right: 9px solid rgba(42, 195, 222, 1);
          border-bottom-right-radius: 9999px;
          color:#bb9af7;
        }

        #custom-hello-from-waybar, #workspaces {
          background-color: rgba(36, 40, 59, 1);
          border-bottom: 5px solid rgba(255, 158, 100, 1);
          color: #b4f9f8;
        }
        #custom-hello-from-waybar {
          border-left: 9px solid rgba(42, 195, 222, 1);
          border-bottom-left-radius: 9999px;
        }
        #workspaces {
          border-right: 9px solid rgba(187, 154, 247, 1);
          border-bottom-right-radius: 9999px;
        }

        #memory, #cpu, #temperature, #clock {
          background-color: rgba(36, 40, 59, 1);
          border-bottom: 5px solid rgba(158, 206, 106, 1);
        }
        #memory {
          border-left: 9px solid rgba(187, 154, 247, 1);
          border-bottom-left-radius: 9999px;
          color: #7dcfff;
        }
        #cpu {
          color: #ff9e64;
        }
        #temperature {
          color: #2ac3de;
        }
      '';
    };

    neovim = 
	let
	  toLua = str: "lua << EOF\n${str}\nEOF\n";
	  toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";
	in
	{
      enable = true;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

	  extraPackages = with pkgs; [
        lua-language-server
        nil
          
		xclip
		wl-clipboard
	  ];

      extraLuaConfig = ''
		vim.g.mapleader = ' '
		vim.g.maplocalleader = ' '

		vim.o.clipboard = 'unnamedplus'

		vim.o.number = true
	
		vim.o.signcolumn = 'yes'

		vim.o.tabstop = 4
		vim.o.shiftwidth = 4

		vim.o.updatetime = 300

		vim.o.termguicolors = true

        vim.o.mouse = 'a'

        --vim.g.transparent_enabled = true
      '';

	  plugins = with pkgs.vimPlugins; [

	  	{
		  plugin = tokyonight-nvim;
		  config = "colorscheme tokyonight-night";
		}

		{
		  plugin = comment-nvim;
		  config = toLua "require(\"Comment\").setup()";
		}

		{
		  plugin = nvim-tree-lua;
		  config = toLua "require(\"nvim-tree\").setup()";
		}

		{
		  plugin = lualine-nvim;
		  config = toLua "require(\"lualine\").setup({ icons_enabled = true, theme = 'auto', })";
		}

		{
		  plugin = nvim-lspconfig;
		  config = toLuaFile ./nvim/plugin/lsp.lua;
		}

		neodev-nvim

		{
		  plugin = nvim-cmp;
		  config = toLuaFile ./nvim/plugin/cmp.lua;
        }

        {
          plugin = nvim-transparent;
          config = toLua 
          "require(\"transparent\").setup({ -- Optional, you don't have to run setup.
            groups = { -- table: default groups
              'Normal', 'NormalNC', 'Comment', 'Constant', 'Special', 'Identifier',
              'Statement', 'PreProc', 'Type', 'Underlined', 'Todo', 'String', 'Function',
              'Conditional', 'Repeat', 'Operator', 'Structure', 'LineNr', 'NonText',
              'SignColumn', 'CursorLine', 'CursorLineNr', 'EndOfBuffer',
            },
            extra_groups = {}, -- table: additional groups that should be cleared
            exclude_groups = { 'StatusLine', 'StatusLineNC' },
          })
          ";
        }

		{
		  plugin = telescope-nvim;
		  config = toLua 
			"require('telescope').setup({
				extensions = {
    			  fzf = {
      				fuzzy = true,                    -- false will only do exact matching
      			    override_generic_sorter = true,  -- override the generic sorter
      			    override_file_sorter = true,     -- override the file sorter
      			    case_mode = \"smart_case\",        -- or \"ignore_case\" or \"respect_case\"
    			  }
  				}
			})
			require('telescope').load_extension('fzf')";
		}

		telescope-fzf-native-nvim

		cmp_luasnip
		cmp-nvim-lsp

		luasnip
		friendly-snippets

		nvim-web-devicons

		{
		  plugin = (nvim-treesitter.withPlugins (p: [
			p.tree-sitter-nix
			p.tree-sitter-vim
			p.tree-sitter-bash
			p.tree-sitter-lua
			p.tree-sitter-python
			p.tree-sitter-json
			p.tree-sitter-rust
			p.tree-sitter-java
		  ]));
		  config = toLua "require(\"nvim-treesitter.configs\").setup({ 
		  	ensure_installed = {}, 
			auto_install = false,
			highlight = { enable = true },
			indent = { enable = true },
		  })";
		}

		vim-nix
	  ];
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;

    #plugins = [
      #inputs.hyprland-plugins.packages."${pkgs.system}".borders-plus-plus
    #];
    
    settings = {
	
    #"plugin:borders-plus-plus" = {
    #add_borders = "0"; # 0 - 9

	#"col.border_1" = "rgb(ffffff)";

	# -1 = follow main config
	#border_size_1 = "-1";

	#natural_rounding = "yes";
      #};

      monitor = [ 
        "DP-3, 2560x1440@165, 0x0, 1" 
		"HDMI-A-1, 1920x1080@60, 2560x500, 1"
      ];
      
      exec-once = "swww init && dunst";

      env = "XCURSOR_SIZE,24";
      input = {
        follow_mouse = "1";

	    sensitivity = "-0.5";
      };
      
      general = {
		gaps_in = "5";
		gaps_out = "20";
		border_size = "2";
		#"col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
		#"col.inactive_border" = "rgba(595959aa)";

		layout = "dwindle";
      };

      decoration = {
		rounding = "10";
	
  	    blur = {
		  enabled = "true";
	 	  size = "3";
		  passes = "1";
        };

		drop_shadow = "yes";
		shadow_range = "4";
		shadow_render_power = "3";
		#"col.shadow" = "rgba(1a1b2699)";
      };

      animations = {
		enabled = "yes";

		bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

		animation = [
		  "windows, 1, 7, myBezier"
		  "windowsOut, 1, 7, myBezier"
		  "border, 1, 10, default"
		  "borderangle, 1, 8, default"
		  "fade, 1, 7, default"
		  "workspaces, 1, 6, default"
		];
      };

      dwindle = {
		pseudotile = "yes";
		preserve_split = "yes";
      };

      master = {
		new_status = "master";
      };

      "$mainMod" = "SUPER";

      bind = [
        # App binds
		"$mainMod, Q, exec, alacritty"
		"$mainMod, F, exec, floorp"
        "$mainMod, D, exec, vesktop"
        "$mainMod, E, exec, thunar"
        "$mainMod, S, exec, steam"
        "$mainMod SHIFT, S, exec, alvr"
        "$mainMod SHIFT, X, exec, hyprlock"
	
		# Hypr binds
    	"$mainMod, R, exec, wofi --show drun"
        "$mainMod, C, killactive,"
    	"$mainMod, M, exit,"
    	"$mainMod, SPACE, togglefloating,"
    	"$mainMod, P, pseudo,"
        "$mainMod, J, togglesplit,"
        "$mainMod, F12, exec, hyprshot -m output --clipboard-only"
        "$mainMod SHIFT, F12, exec, hyprshot -m window --clipboard-only"
        "$mainMod, F11, fullscreen,"

		# Focus binds
		"$mainMod, left, movefocus, l"
		"$mainMod, right, movefocus, r"
		"$mainMod, up, movefocus, u"
		"$mainMod, down, movefocus, d"

		# Workspace binds
		"$mainMod, 1, workspace, 1"
		"$mainMod, 2, workspace, 2"
		"$mainMod, 3, workspace, 3"
		"$mainMod, 4, workspace, 4"
		"$mainMod, 5, workspace, 5"
		"$mainMod, 6, workspace, 6"
		"$mainMod, 7, workspace, 7"
		"$mainMod, 8, workspace, 8"
		"$mainMod, 9, workspace, 9"
		"$mainMod, 0, workspace, 10"

		# Move to workspace
		"$mainMod SHIFT, 1, movetoworkspace, 1"
		"$mainMod SHIFT, 2, movetoworkspace, 2"
		"$mainMod SHIFT, 3, movetoworkspace, 3"
		"$mainMod SHIFT, 4, movetoworkspace, 4"
		"$mainMod SHIFT, 5, movetoworkspace, 5"
		"$mainMod SHIFT, 6, movetoworkspace, 6"
		"$mainMod SHIFT, 7, movetoworkspace, 7"
		"$mainMod SHIFT, 8, movetoworkspace, 8"
		"$mainMod SHIFT, 9, movetoworkspace, 9"
		"$mainMod SHIFT, 0, movetoworkspace, 10"

		# Special workspace
		"$mainMod, W, togglespecialworkspace, magic"
		"$mainMod SHIFT, W, movetoworkspace, special:magic"

		# Scroll through workspaces
		"$mainMod, mouse_down, workspace, e+1"
		"$mainMod, mouse_up, workspace, e-1"
      ];

      binde = [
		"$mainMod, F3, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+"
		"$mainMod, F2, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-"
      ];

      bindm = [
		"$mainMod, mouse:272, movewindow"
		"$mainMod, mouse:273, resizewindow"
      ];

      workspace = [
        "1,monitor:DP-3"
        "2,monitor:HDMI-A-1"
        "3,monitor:DP-3"
        "4,monitor:HDMI-A-1"
        "5,monitor:DP-3"
        "6,monitor:HDMI-A-1"
        "7,monitor:DP-3"
        "8,monitor:HDMI-A-1"
        "9,monitor:DP-3"
        "10,monitor:HDMI-A-1"
      ];
    };
  };

  gtk = {
    enable = true;
  };

  # external dots
  home.file = {
    
  };

  home.sessionVariables = {
    EDITOR = "neovim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.stateVersion = "23.11"; # Do not change!!!
}
