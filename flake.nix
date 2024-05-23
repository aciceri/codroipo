{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      perSystem = {
        config,
        inputs',
        pkgs,
        lib,
        zmk-nix,
        ...
      }: {
        _module.args.zmk-nix = inputs'.zmk-nix;

        packages = {
          reset = zmk-nix.legacyPackages.buildKeyboard {
            board = "nice_nano_v2";
            shield = "reset";
            zephyrDepsHash = "sha256-n7xX/d8RLqDyPOX4AEo5hl/3tQtY6mZ6s8emYYtOYOg=";
            src = lib.sourceFilesBySuffices inputs.self [".conf" ".keymap" ".yml"];
          };

          firmware = zmk-nix.legacyPackages.buildSplitKeyboard {
            name = "codroipo-firmware";

            src = lib.sourceFilesBySuffices inputs.self [".conf" ".keymap" ".yml"];

            board = "nice_nano_v2";
            shield = "lily58_%PART%";

            zephyrDepsHash = "sha256-n7xX/d8RLqDyPOX4AEo5hl/3tQtY6mZ6s8emYYtOYOg=";

            meta = {
              description = "ZMK firmware for the codroipo keyboard";
              license = lib.licenses.gpl3;
              platforms = lib.platforms.all;
            };
          };

          default = config.packages.firmware;

          flash = zmk-nix.packages.flash.override {inherit (config.packages) firmware;};

          update = zmk-nix.packages.update;
        };

        devShells.default = zmk-nix.devShells.default;

        formatter = pkgs.alejandra;
      };
    };
}
