{ pkgs }:

pkgs.writeShellScriptBin "lxc-gui" ''
  exec ${pkgs.python313Full}/bin/python ${./lxc_gui_standalone.py} "$@"
''
