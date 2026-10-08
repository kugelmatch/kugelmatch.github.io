# SPDX-FileCopyrightText: 2026 Ingo Ruhnke <grumbel@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later
#
# KugelMatch website: WASM play build + downloadable ports, for GitHub Pages.
#
#   nix build        # site in result/
#   nix run .#serve  # local preview
#
{
  description = "KugelMatch website (WASM + GitHub Pages), Nix-first";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # git+https so the game's version (…-dev.<count>+g<rev>) carries a real count.
    kugelmatch.url = "git+https://github.com/Grumbel/kugelmatch";
    kugelmatch.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, kugelmatch }:
    # x86_64-linux only: Android SDK/NDK are not packaged for other hosts.
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        game = kugelmatch.packages.${system};
        version = game.kugelmatch.version;

        site = pkgs.runCommand "kugelmatch-site" { } ''
          mkdir -p $out
          substitute ${./index.html} $out/index.html --subst-var-by version ${version}
          cp -rv ${./images} $out/images

          # Playable WASM build from the game flake (html/js/wasm).
          mkdir -p $out/play
          cp -rv ${game.kugelmatch-wasm}/. $out/play/
          chmod -R u+w $out/play

          # Ports under stable names so the page's links never change.
          mkdir -p $out/downloads/r36s
          cp -v ${game.kugelmatch-win64-zip}/*.zip $out/downloads/kugelmatch-win64.zip
          cp -v ${game.kugelmatch-win32-zip}/*.zip $out/downloads/kugelmatch-win32.zip
          cp -v ${game.kugelmatch-android}/*.apk $out/downloads/kugelmatch.apk
          cp -v ${game.kugelmatch-r36s-zip}/*.zip $out/downloads/r36s/kugelmatch.zip
          chmod -R u+w $out/downloads
        '';

        serveApp = {
          type = "app";
          program = toString (pkgs.writeShellScript "serve-kugelmatch-site" ''
            set -euo pipefail
            export PKG="${site}"
            export KUGELMATCH_PORT="''${KUGELMATCH_PORT:-8765}"
            exec ${./scripts/serve.sh}
          '');
        };
      in {
        packages = {
          default = site;
          site = site;
        };

        apps = {
          default = serveApp;
          serve = serveApp;
        };
      });
}
