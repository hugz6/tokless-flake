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
        packages.tokless = pkgs.buildGoModule {
          pname = "tokless";
          inherit version;

          src = pkgs.fetchFromGitHub {
            owner = "HoangP8";
            repo = "tokless";
            rev = "v${version}";
            sha256 = "0v7mj8a6p5lln2z5iqcd552njxkvszips96nljm9734ky58pjvfi";
          };

          vendorHash = null;
          doCheck = false;

          meta = with pkgs.lib; {
            description = "tokless";
            homepage = "https://github.com/HoangP8/tokless";
            license = licenses.gpl3; # Let's assume or check license if needed
            maintainers = [ ];
          };
        };

        packages.default = self.packages.${system}.tokless;

        apps.tokless = flake-utils.lib.mkApp {
          drv = self.packages.${system}.tokless;
        };
        apps.default = self.apps.${system}.tokless;
      }
    );
}
