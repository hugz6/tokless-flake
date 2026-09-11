{
  description = "A flake for tokless";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        version = "0.3.2";
      in
      {
        packages.tokless = let
          tokless-bin = pkgs.buildGoModule {
            pname = "tokless-bin";
            inherit version;

            src = pkgs.fetchFromGitHub {
              owner = "HoangP8";
              repo = "tokless";
              rev = "v${version}";
              sha256 = "0v7mj8a6p5lln2z5iqcd552njxkvszips96nljm9734ky58pjvfi";
            };

            vendorHash = null;
            doCheck = false;

            postPatch = ''
              substituteInPlace internal/util/paths.go \
                --replace-fail 'exe, err := os.Executable()' 'exe := os.Getenv("TOKLESS_WRAPPER_PATH"); var err error; if exe == "" { exe, err = os.Executable() }'
              substituteInPlace internal/util/mcpspawn.go \
                --replace-fail 'self, err := os.Executable()' 'self := os.Getenv("TOKLESS_WRAPPER_PATH"); var err error; if self == "" { self, err = os.Executable() }'
            '';
            
            meta = with pkgs.lib; {
              description = "tokless";
              homepage = "https://github.com/HoangP8/tokless";
              license = licenses.gpl3;
              maintainers = [ ];
            };
          };
        in if pkgs.stdenv.hostPlatform.isLinux then (
          let
            fhs = pkgs.buildFHSEnv {
              name = "tokless-fhs";
              targetPkgs = pkgs: (with pkgs; [
                tokless-bin
                nodejs
                git
                curl
                stdenv.cc.cc.lib
                zlib
              ]);
              runScript = pkgs.writeShellScript "tokless-fhs-run" ''
                export NPM_CONFIG_PREFIX=''${NPM_CONFIG_PREFIX:-$HOME/.npm-global}
                export PATH=''${NPM_CONFIG_PREFIX:-$HOME/.npm-global}/bin:$PATH
                exec ${tokless-bin}/bin/tokless "$@"
              '';
            };
          in pkgs.symlinkJoin {
            name = "tokless";
            paths = [ fhs ];
            buildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              mv $out/bin/tokless-fhs $out/bin/tokless
              wrapProgram $out/bin/tokless \
                --set TOKLESS_WRAPPER_PATH $out/bin/tokless
            '';
            meta = tokless-bin.meta;
          }
        ) else (
          pkgs.symlinkJoin {
            name = "tokless";
            paths = [ tokless-bin ];
            buildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/tokless \
                --set TOKLESS_WRAPPER_PATH $out/bin/tokless \
                --prefix PATH : ${pkgs.nodejs}/bin \
                --run 'export NPM_CONFIG_PREFIX=''${NPM_CONFIG_PREFIX:-$HOME/.npm-global}' \
                --run 'export PATH=''${NPM_CONFIG_PREFIX:-$HOME/.npm-global}/bin:$PATH'
            '';
            meta = tokless-bin.meta;
          }
        );

        packages.default = self.packages.${system}.tokless;

        apps.tokless = flake-utils.lib.mkApp {
          drv = self.packages.${system}.tokless;
        };
        apps.default = self.apps.${system}.tokless;
      }
    );
}
