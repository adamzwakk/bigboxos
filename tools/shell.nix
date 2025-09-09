{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "bbos-tools";

  buildInputs = with pkgs; [
    innoextract
    p7zip
    zip
    unzip
    jq
    qemu-utils
    exfatprogs
  ];
}