{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, flake-utils, nixpkgs }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.default = pkgs.callPackage ./packages/default.nix { };

      devShells.default =
        let
          tmux_conf = pkgs.writeText "tmux.conf" ''
            run-shell ${self.packages.${system}.default.rtp}/project.tmux
          '';
        in
        pkgs.mkShell {
          buildInputs = with pkgs; [ tmux fzf ];
          shellHook = ''
            TMUX= TMUX_TMPDIR= exec tmux -f ${tmux_conf}
          '';
        };
    }
  );
}
