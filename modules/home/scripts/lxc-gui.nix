{ pkgs }:

pkgs.writeShellScriptBin "lxc-gui" ''
  exec ${pkgs.python3}/bin/python ${./lxc_gui_standalone.py} "$@"
''
