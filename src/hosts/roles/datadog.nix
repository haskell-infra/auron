{ config, pkgs, resources, lib, ... }:

with builtins;

{
  services.dd-agent.enable  = false; # true;
  services.dd-agent.api_key = readFile ../../../etc/priv/datadog.secret;
}
