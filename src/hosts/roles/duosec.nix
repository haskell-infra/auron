{ config, pkgs, resources, lib, ... }:

with builtins;

let
  hostname = config.networking.hostName;
  filepath = v: toPath (getEnv "AURON_ETCDIR"+"/priv/"+hostname+"/"+v);
in
{
  security.duosec.ssh.enable = false; # true;
  security.duosec.autopush   = true;
  security.duosec.group      = "duosec";
  security.duosec.ikey = readFile (filepath "duosec-ikey.secret");
  security.duosec.skey = readFile (filepath "duosec-skey.secret");
  security.duosec.host = readFile (filepath "duosec-host.secret");
}
