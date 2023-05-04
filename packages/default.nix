{ lib, tmuxPlugins }:

tmuxPlugins.mkTmuxPlugin {
  pluginName = "project";
  version = "unstable-2023-05-04";
  src = ../.;
  meta = with lib; {
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
