let
  pkgs = import (builtins.fetchTarball {
    name = "nixos-unstable-2021-01-27";
    url = "https://github.com/nixos/nixpkgs/archive/15a64b2facc1b91f4361bdd101576e8886ef834b.tar.gz";
    sha256 = "0afws3s9bk5xiza6x924lb0ig4ia7pp0xrsbb6a8i9zg1gz10ahy";
  }) {};

in pkgs.nginxMainline.override {
  modules = [ { src = ./nginx-pinata-module; } ];
}
