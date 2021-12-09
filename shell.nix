{ pkgs ? import <nixpkgs> { } }:

let
  plugin = ./.;
  tmuxConfig = pkgs.writeTextFile {
    name = "tmux.conf";
    destination = "/etc/tmux.conf";
    text = ''
      run-shell ${plugin}/ghq.tmux
    '';
  };
in pkgs.mkShell {
  buildInputs = with pkgs; [ tmux bash fd fzf ];
  shellHook = ''
    TMUX= exec tmux -f ${tmuxConfig}/etc/tmux.conf
  '';
}
