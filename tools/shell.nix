{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "bbos-tools";

  buildInputs = with pkgs; [
    innoextract
    p7zip
    umu-launcher
    zip
    jq
  ];
}