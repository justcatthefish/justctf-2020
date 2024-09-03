let pkgs = import <nixpkgs> {};
    pinata = import ./default.nix;
    conf = "${./nginx.conf}";
in with pkgs;

dockerTools.buildImage {
  name = "pinata";
  contents = [
    shadow
    busybox # not needed, remove later
  ];
  runAsRoot = ''
    #!${runtimeShell}
    useradd nobody
    groupadd nogroup
    mkdir -p /var/log/nginx
    mkdir -p /var/cache/nginx
    chown nobody:nogroup /var/cache/nginx
    chown nobody:nogroup /var/log/nginx
  '';
  config = {
    Cmd = [ "${pinata}/bin/nginx" "-c" "${conf}"];
  };
}
