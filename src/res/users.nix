{ lib, ... }:

with import ./ids.nix;
with lib;
with builtins;

rec {
  # -- User sets
  admins    = { inherit a gersh ricky johnw hvr merijn simons noteed; };
  adminkeys = concatLists (map (v: v.openssh.authorizedKeys.keys) (attrValues admins));

  # -- Administrators
  a = {
    description     = "Austin Seipp";
    home            = "/home/a";
    createHome      = true;
    uid             = with import ./ids.nix; uids.austin;
    extraGroups     = [ "wheel" "duosec" "grsecurity" ];
    group           = "users";
    useDefaultShell = true;
    openssh.authorizedKeys.keys =
      [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKN53e1R17ha560eN3TJ/uV63vgppBVOGB2bZ5H7AnvVdrV6ZnrRU0LY9VBx0bF5q2+Hst8X9xOuTKLg38XFLkSWjI0Bxt4qYbwRr8RyafI8n0UUV/sLFPEkVw2Y2jUlMxGhPUtCXZbB8V2n8Zcn/QESnUKOzZHGh2VuQ1ydra58gCK6jDot51lNh4oT0WL3F+KY7cKGv5uyDLtaGxxiPYBRZvhBLjdPAYfkTa1NOAYoN3wPfFtH4xuCP2nTSbodAgQ/UsY/aNdNkK97//GZzT5h7cA4G+//b5tNaGCN0j7RJ6wSGFCut3QvKiYlsU0sAuwyYhizuo/+IoWV2LT2W6pHRe5Ivodyzm97bkWzI+UzGKLP5VKH55Pol4iIhnavhUP5j4IIr5Xplbvp+BdVVgfaSWpRH0t4ALyn1oDZZNUkzjwFbw/EPkdndJjChziEPO31koPBFcm/IB7DvXYjPrTY9S5nlF7QbA2A3118oem4V9A4FNi9gijFJspkHPFJ2CzFoYbCg9fCwPkeS/poS6ZgBL0p4sMoqxj+2OUdS6Vg8IO143YIUmA7FcFYafhhpTWSD44lja7a8RkDcukOA2YdcuMf5f10xbW3auZ3Gjatj1Jp0hTqIT78FaEBoZJnSmJSwi/hyMWV/vix+SCw3BPwjIJ/xQUccpNwh++E/Zdw== a@link"
      ];
  };

  ricky = {
    description     = "Ricky Elrod";
    home            = "/home/ricky";
    createHome      = true;
    uid             = with import ./ids.nix; uids.ricky;
    extraGroups     = [ "wheel" "duosec" "grsecurity" ];
    group           = "users";
    useDefaultShell = true;
    openssh.authorizedKeys.keys =
      [ "ssh-rsa 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 ricky@t520.home.elrod.me"
      ];
  };

  gersh = {
    description     = "Gershom Bazerman";
    home            = "/home/gersh";
    createHome      = true;
    uid             = with import ./ids.nix; uids.gersh;
    extraGroups     = [ "wheel" "duosec" "grsecurity" ];
    group           = "users";
    useDefaultShell = true;
    openssh.authorizedKeys.keys =
      [ "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAtHucPE4Xp+qFBb2JpuNQkOtXm2dh0aE8h/QnirZLPstlcnV/iWyX83+uAoXMJYb244Vlx5EhL8BDj4x4RijLBhljmO5Mbl/fKCidQ8YIQEK6VikO0WcGd8iDxQsZKTk03MSW/m34KpsiXQhMvND/j52hJfBt1uCXvPHkyrxVVJgsNZrJTu9PlBT7hfDIE/GRHzQEVG0fnc6yjqjlK85u1s+90cwOSCpx/3JIhk2lybvP7XHJQTUj4Ka9HgRs721Fj5fCd9tqTkfUPxbLUUH4TxOOhbRwisXivolf15AoCwBHIc8qTcJPpEVP14iKltsElNNNSwvIdMhX3uwaY42KUw== gersh@Gershom-Bazermans-MacBook-Pro.local"
      ];
  };

  johnw = {
    description     = "John Wiegley";
    home            = "/home/johnw";
    createHome      = true;
    uid             = with import ./ids.nix; uids.johnw;
    extraGroups     = [ "wheel" "duosec" "grsecurity" ];
    group           = "users";
    useDefaultShell = true;
    openssh.authorizedKeys.keys =
      [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCs/wmex4NQd8xGoa6qFUwjrDnPbxB/KC24TEu1Xu66uU5Tay7dhtoyGFxqxguXM15t6viM6o5eKhIcEBjsbtiHKODEj4KxX5NGHbnSda7N2R96AY9nuIpdcTeD6q0ynjbXlI/VXzXS66cRyaUhWLz69E9qR+0oUoMCJsbeHrOeKYsNRff9AlcJ/YoVnFGapLBxBWv7ABa0D0nx1asZkOFubxMm0+N+sHd3RCJ0SSeO8UK7nqoNQHB33J77bloPPHhC6h+UcOdVX0I2rKnTzoexgxAGCHRrYc/trB+ZnekhPZWOakaZd0v/KhaoNfPKL0l0i8SYotAUtgNCVZYNrklP johnw@Hermes.local"
      ];
  };

  hvr = {
    description     = "Herbert Valerio Riedel";
    home            = "/home/hvr";
    createHome      = true;
    uid             = with import ./ids.nix; uids.hvr;
    extraGroups     = [ "wheel" "duosec" "grsecurity" ];
    group           = "users";
    useDefaultShell = true;
    openssh.authorizedKeys.keys =
      [ "ssh-dss AAAAB3NzaC1kc3MAAACBAMiNJCB266X9jqXFHqOxjeUngK49vmcgUEFbppvWRy03PsKDF4t3eH3FG7QrgRafvkJhkUmtrTSES1UyiODjtXvMSoA2uLRsIuwx+R9YpmYI6h6m6ySm4DIzxV5s0tRvi7f6HYXMK4yVj2tS9zuUA1HzDv0gLEo1ocU3Eg0utFjTAAAAFQDF4hJiIq2o8691svj9dA/ZuVmteQAAAIBkm6UINMEitAZnYRCxBimrPATFo+Tgnaq3YVVucdTSifdPhQMhB1tFUPMMV4peNoWdMj17xGr3JbhQd1He/9yy6evrvuf3udCVj8T6jpGDFwgChz+BdfojckHphuL+0gs/dAKrm+f9P4c3cMzT16m1dPn8dL0JvaI/OrTp0zxYPAAAAIEAlXft2g+ArWOZqNoU2hqJTfoD+HNJgLCp+O/QPFQ5mgZPTtl7bvHgiymyM+JrayzA3hX4QDXT/rTzu/a595mCKhY9B59lFCmsTsqv2CRfKqSI3XHkcFzLHZbmw9T2OMFCKdUnp3LQaIehDlCl8KHvX904USrxeit0B2kWMb/3zPo= Herbert Valerio Riedel <hvr@gnu.org>"
      ];
  };

  merijn = {
    description     = "Merijn Verstraaten";
    home            = "/home/merijn";
    createHome      = true;
    uid             = with import ./ids.nix; uids.merijn;
    extraGroups     = [ "wheel" "duosec" "grsecurity" ];
    group           = "users";
    useDefaultShell = true;
    openssh.authorizedKeys.keys =
      [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9YkeBhp6Kb0jc3SambH4gRbkSx4crUHjco49hE35FsreDnFNTUP+vRy6HFcpMPw9WNoJevScV3PSq1oH5zwQ/2TqnRSN6Z+1/NZAvbW4rqGcRCUaLJAZc/f0aZY2cNbXOu3Q7L4qm+1Etoo7wCPd9vSoUXGy/a7CdphhCl1rIXTk2tKrrfL1tcsK//Zo9W+Meuc/ni8l8yFKp4p4Gi5l9KYrcqrLTbeTOlABf7UkVSVmS+WIFRB+BWyx3rgM5ok5vvsPwFojlgwm+CMtsNKWYxoxb6knyJztDPuwTOMOBC9uY62ZjziqiL00MCHIlWOmptKg35Qid8CxrWqu6fMsiivK5icE8BA3YbUz2zFGOUo7B2YSUPbZM5J/Z6tOam0+ijCayFEP/2bGEZD1NLMK48s0aFrHCKfhIiq0CMYRlBNWCDOI79sMdcIzu6i237b3qosjW95Yv2mjcungnrya0t2pyH7o5bZ1sZH+sOs+uBRZbHyaIxZZOvZV3mwk+z7dMRCMqU7TbnOFhTNAdtruyqWmzPv4XTtAVLdlT8PopfcxVukSwWu+RTVKCTncXJMokRlp3Wf1aCJwFtL55gvn3ALwsveWdnlrssjwglUywddH6gf4wvWppa0KWuUHEsNN1xwpr/yiEgWyqCgk7tqQKwmyBfNQ23RlD0I89k75ABQ== merijn@inconsistent.nl"
      ];
  };

  simons = {
    description     = "Peter Simons";
    home            = "/home/ricky";
    createHome      = true;
    uid             = with import ./ids.nix; uids.simons;
    extraGroups     = [ "wheel" "duosec" "grsecurity" ];
    group           = "users";
    useDefaultShell = true;
    openssh.authorizedKeys.keys =
      [ ""
      ];
  };

  noteed = {
    description     = "Vo Minh Thu";
    home            = "/home/noteed";
    createHome      = true;
    uid             = with import ./ids.nix; uids.noteed;
    extraGroups     = [ "wheel" "duosec" "grsecurity" ];
    group           = "users";
    useDefaultShell = true;
    openssh.authorizedKeys.keys =
      [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7VIWFSJmJIKsO+kfr42XaplDtZ0rD8nyY1q9qKq6GMgtC2wFDAkI6IpkudbxAPo6YMndCbxOCuo9rYGkHf3A2dbQ8iWpLGDujABROY0ny29pMmpgbproTA3i6a+XE1j4lD2J0N5lzhY4aGCcB4kiHVR/9CsVnmN/GFECsBS+kDtOXHb/A3O8NaZY4wmG1zJ1t/8axSGrUM5y/DAQdD4SNzP7LEF7E4Vnls0N2j0dJayJkXeTy6/i9rJC08+EWxib57NE3T+6rmWq3iYZzz3W8cJ5HCLSswgDQqIIm1lFjeZvNMfDdTkyvU8wqOx9tJWHA8F5XerrSc6btiR/v76aX noteed@gmail.com for haskell infrastructure"
      ];
  };

  # -- Regular users

  # Testrix is a low-level user with no special permissions for testing purposes
  testrix = {
    description     = "Testing User";
    home            = "/home/testrix";
    createHome      = true;
    uid             = with import ./ids.nix; uids.testrix;
    group           = "users";
    useDefaultShell = true;
    openssh.authorizedKeys.keys = adminkeys;
  };
}
