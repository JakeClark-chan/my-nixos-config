{ pkgs }:

let
  pythonWithPackages = pkgs.python3.withPackages (ps: with ps; [
    tkinter
  ]);
in
pkgs.writeShellScriptBin "lxc-gui" ''
  exec ${pythonWithPackages}/bin/python ${./lxc_gui_standalone.py} "$@"
''