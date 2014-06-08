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

  malcolm = {
    description     = "Malcolm Wallace";
    home            = "/home/malcolm";
    createHome      = true;
    uid             = with import ./ids.nix; uids.malcolm;
    group           = "users";
    useDefaultShell = true;
    openssh.authorizedKeys.keys =
      [ "ssh-dss AAAAB3NzaC1kc3MAAACBAPouUK5ohedP8c7d4TV3Ex10fcERx7HyRP4mAdP+3qzcHAzWji8JNfj5NXPC1MEpnmvtjc0mUIwCVEB8YjWeXIEzMfCNwa4LLYsrAfW83edGopiiYRvk/7I8mbkei9lTckY9EMiCOomWnQleigbcl8tJP2x9UyXdmWtSBYNSfqE7AAAAFQCDS1pK7+fbGg4zcJY7JUHfcqa0hQAAAIEAuV9Gb9GprGDpnltJAvscAiXuGYkiY74UAe5r6ORTzC7o4sc3BCrg6T/Xu4cWw0BUEdtUw/GB/UH+efIlvBDhM4dZcSeoKI7gFVD3+a5SN8Q1JB6bVoyeqnJlRkuVVKtRAeTPnXKbG669GQBmOo6IyfR1cxmywun5IqqEpWSN+owAAACBAN0IO50I49GkQxCnvWtb2QR5r0/WO6bpjsKSi4oFKecmoZGUvvgsU/4wEGc+Rl+roR7zltCS2uaIBx/MZrmOO9QVHdcjgfThJyg5hDgExxVOpfQqV5JQ+lezlehRnWa1Q5fETbHaymrCZZ/Vz611tC0GKX/YuZ4aDF8ROUDU1tLv malcolm@pc173"
        "ssh-dss AAAAB3NzaC1kc3MAAACBAK58l8odptpJj6vN+WqJG61v/faB0lu6sCxWbVQ/df2AKEukxHCCnWf50/KsMwaBq6SYEdTgWsv9GmKPB7gUf6xiZc4ooxAYc+ghe1i2ElAbs+ABJaMRl2jJXSz6VrAmLf5ZLj54VDFaEwxfbYNZx8jTcHAQrO0dnviRk8aG7U4rAAAAFQDR3IfZgs9oHDI+WLd7INDigApogQAAAIEAhGpei18tiwyF45GH7S+eTx9a1PLVUgED+tPxbt6MP0gzF2zAuUg3/YncVgqjQ5Ue3c8n/e0E7KOJpxCsJeIcN7erzpjK3ih5zbwZUx96JeqZ3JPQW4kC4dazHkVurtoAmOUjgAKcvhDMkVPAsyTIrwqBAGVYmX58+Sb8jFPmlzQAAACAFYTvfJUBtL738mjkI+TXiBFjGRddLjDoldAtPhojP8Vfr1KU4LuRbTNaJUdgSCW1Dby1lcum8dCStWpXLH8Xb7M7O3lGn4PZmIdq69uKoTMgoe1AmdWIoYUe32SPJdZzuPAM74KEYDUdw2IyIjxFFjNeXsWE2XtewBDwbZa0t/w= malcolm@pc173"
        "ssh-dss AAAAB3NzaC1kc3MAAACBAJD/BhXYoLCY4e+/9QRqIyhf4JUhesF6lokvrBcRLWSlmRCj1N+uvQ6MvY63rCW3ZCeqROIJnE0dA1ItBATorU+EFe/uv78gvMjdiF2PwYdlyFbvXIGzqgyYV3FvOE93/hjk3BfrROnz3YmpADaXDTMhhwhKi59x6F1Vnx98mRA/AAAAFQDBHeBVLgl9E77HfIKlltSkuvNEAwAAAH8E0srUPfA44XyKzsRcNp0iH/5sXD9N4g4Nl697qmeIAkYXKl/viStrbRCBqULGcJPZTZVR0o7xVO7hwu0PRMYs5K48iAzM6PPX2qAoRIHG3BrCOJbtlBdGslH6D8alre8TZcuD0zc6nUT2ecI+yxGn/1oXiUFG4xnCACtGh9+wAAAAgQCO2Eqy5/g3MVmfapciBgv4jtqAjUj10Fp0kXEF44lhfHF1Kc+nttxJ0k2Li1u9Dv0AnLvMpJTmmXxR3k8G/39g2it+trtK6HBxSV2DJQ1XN3hTPVoKqntqg8TnYNEZdd5AJW8aA1zIZf+RjxcTBeNmGvkoa9zImV1e9oBXC0mh2w== malcolm@abbess"
        "ssh-dss AAAAB3NzaC1kc3MAAACBAJD/BhXYoLCY4e+/9QRqIyhf4JUhesF6lokvrBcRLWSlmRCj1N+uvQ6MvY63rCW3ZCeqROIJnE0dA1ItBATorU+EFe/uv78gvMjdiF2PwYdlyFbvXIGzqgyYV3FvOE93/hjk3BfrROnz3YmpADaXDTMhhwhKi59x6F1Vnx98mRA/AAAAFQDBHeBVLgl9E77HfIKlltSkuvNEAwAAAH8E0srUPfA44XyKzsRcNp0iH/5sXD9N4g4Nl697qmeIAkYXKl/viStrbRCBqULGcJPZTZVR0o7xVO7hwu0PRMYs5K48iAzM6PPX2qAoRIHG3BrCOJbtlBdGslH6D8alre8TZcuD0zc6nUT2ecI+yxGn/1oXiUFG4xnCACtGh9+wAAAAgQCO2Eqy5/g3MVmfapciBgv4jtqAjUj10Fp0kXEF44lhfHF1Kc+nttxJ0k2Li1u9Dv0AnLvMpJTmmXxR3k8G/39g2it+trtK6HBxSV2DJQ1XN3hTPVoKqntqg8TnYNEZdd5AJW8aA1zIZf+RjxcTBeNmGvkoa9zImV1e9oBXC0mh2w== malcolm@www.abbess.org.uk"
        "ssh-dss AAAAB3NzaC1kc3MAAACBALghmS3afHleMz61hJZF2X9H/GpyzZCRJG22rQa14/W0o1o+mD5Zziyet3AULFV3pynESBH4iX87vIOwj14J/nHMq9hpm3uiAWZGR6wIADIBHyE2IqSbwaMuBXrvTSjkxEMblrsoI6cQztSJsFAOzFkG+DmWUjc4YZ5MLelvvs8BAAAAFQD563SCwmpxqK7Q1meG4ih5iITiCQAAAIA6I2tFB5WKMfUWvHKXe3Q49O5+JR4Wra9ScMSp+QshKWO9hNBr2HUcYmhu8YxgXeZzJNMYt76v7mT97wojoR+ouA7WSKnWmpPEYSnpbB+tB/7j8xRW0FsbdWVZGs3C+kdih9R3uCeIxS+lVGEeCNV7bLyCEqFrObItK/Hn+yRLCQAAAIA9s0Th3DQVXdhdIlnPAzgK0emokF3qXBAzg0H9SeVdl/r+ZK6TEWASFPs6KYzFy7Hr43Nf6D2ZFUqAC+NYXh/ZRHVlhwgkbiuNdTIE8qHfOyJ3A4lCkWyC2xpayb3hadqSHDj6H+ZbjXdxYrTEAjPMffPGKxlzualsi3iY+BlRBA== malcolm@chartres.abbess.org.uk"
        "ssh-dss AAAAB3NzaC1kc3MAAACBAMkJt71NT4dLYLaQrQ1e1WDZWlUObmEzGaWRBxNUIb5UhoE7POuC7edZxB4JWO8hIrQ6756mqxRjDZxetQVJ0IthpDtP1XGMUNe2McoEKpKoHEhejMnIubQcuGQB5x8fPYfj5GHvGfkZvhT3qWhSUH0l+fdzvmIBBR3s5wyRQUd5AAAAFQCH+2XKtuHh9H0VrGwImEtCFXtFRwAAAIALIWzseENStpO0dd3l9u1LcLo1HA2WIUJzqk4AwS9xHwKdYziJltvn7ZOjks8SPqNLyPUpUvbmLa7wsl3Uwb2HLplOHnBoaLLcl5tpVzoCSuJcSAXrtQ5Zki4/IBFlnqn/aZ4Vg0NhCAeOJdWtW9DqBSmFmdgDGRdCXJWWVr+ptwAAAIEAsoOmshCod4id+WGWC4UKlsMdYOVObmmy+Cw+1j6u55OM4JonAH6ejNPW1Fv/m0Kd14acOaNzFyuLuWws7gXTS+TX4T5usDhM+l5wuJ6oAh9ZHcGSWrIDzGKA2uf0DhNj5q5Ep9LiMlbVQJFpwuGLlONTQOMUE9KJFPxBcc61fFE= malcolm@Pilgrim.abbess.org.uk"
        "ssh-dss AAAAB3NzaC1kc3MAAACBALbJR+9HTI2eZJJaI2Wfn9f8SkLpS0P22E4QqNWApyLoBUgehJMK+gt2bdonpprZnTxxoZyef1u7dG/8nS+iyh3KyneuEtJo+jejzrL1NGa5Af7QZnnJBMgo+dXxNy50B0y4jeiSZA918WeNWrX3kdDn9D0ohBa72oNJXHCl17jFAAAAFQCV61w0weHnl6Rc78Vl+oWT+YnKQQAAAIBcBuSuwTEgIcsJjIsIfsXGZ8VG+9LcVlhCVEoVdGuNFAs12oZn5zlJ94/xhzvLRm3Xv63lD1OtLE9AZsCGrvR2EQ0IXBgEl8rQlzGO4ys9UUzDMOr6NZwv2dzOTeTrnmh34u36Abx57Sfi1cIglLxEOmX3U7v5j+z/HmDh54F/ygAAAIAUP9v2RssqqXMpYZ2Tl57PZU5+z45XzoczmQPb0EhvHG6NAyjgeunPC8Yrt7k8FuNddQ+qCz8V/wrE4C/YMHfMtW8q//g5nL2xXBmUdD2v0Q7bxJSNMe0foPvf98a8iQAG5LrxxiBKn6bxY/7686W88lb9zLdmGwHRMOvonv3jwg== malcolm@Malcolms-Computer.local"
        "ssh-dss AAAAB3NzaC1kc3MAAACBAIILV8xUVaMo7BetQixdXIxNpeyy6lOeJYoQq73gHKqA2Pe6CC39RQZCJaf/8wcTxGJ0t+34h5x10Pq4SKxevIShQGwrRXMPK5iDtozQ8Z03bZ46fs31zSRGujgGBS/gWd2NW/UzxRTvR1bhaLGvh7lh93DFy7kLrqZUxh2dcEotAAAAFQD/Dd8RDLL2zzcRKcKTgZiRAc0ZxQAAAIEAgaVqILT0eVrlx5sYtdU7rbLxBcLOyUfuYy12yKMbAOhL7VXGyvwGNBRPL1t3Hp+7UB3JboPtsn0Tj/HYG5yHuX9F8EmOzuT0fHywD8XgJw9aFWdg5f+izzGEiVkxTIuIXXSdIOnf5NDIaW/dNq1fGSUgVdL48qmhv6w+v4wLAQMAAACAYnqqVE4PaBq/xlyRIraqQ6uX/LGxy1zOoB1PVMYZ68P8E5rqXdwZQcZ5KjODXylDo3sNzEErs6bH5ZlrEGYkVBZVSyIjfwDzCtbOq9d2NmZM0ZNBxTQGvxiva+yPSQU644WT4s4PE9+QwXXGy8BMw2xnuA0M2v/sPIzFxC7UMJQ= malcolm@ua025.cs.york.ac.uk"
        "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6D877rfpUHb2h9sCjdx+2ZbFbpXQniYWkZsg9bZ/bQsiVj3U+UdxWuOh6cu8rc5fx8ClcLPud6fGRovGY0IYGQGjZTiigQdRLm5bwpniTtdqm/X58o7pyJY2RoIBvaNgFulgxgO+ubrTVlH4Wk+k8/n5Q0Jem5WpaO/kDqP4xWU4ZbVtfMmRosUTtA5g+k9lrGVXg30KDPvOt2/kG5VRbZvGy3is0Fqq8AQq5YMFB2B5X8IR2mvzUBAPO0Oomub2A331D6C5+N7rHKEj2WzSc2agv8jrEEGXBw0agGeIzairUmlZpDeIDLhZnRR3t7yXvUNZQFhsBmjUDqrXXMEmsQ== malcolm@archivist.local"
        "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAsRQscePXY/Wo72FBjTIYjRnI4lOwQFwMVEMEEpm9cAUpjrDMw4XR+11lr8zAwlAIis8E7coHgrXVQeIiuzH6B1kR2Ll/emn6U5Jw6kGyr2UnpzmifD7raKhXfcOlZFtUI8F/Zz92yuPSGBB5O9gb5hu/vR/zKbQWHqFcXYdgxCsNEQPnUkb6F/Ay1GdaA1ZDr4Iy+IeTNovil+z030EMfe2tMoh2Z7CZiDqHucpRhjqLe/3nrBXJn+AxYTzG5YsAyRsRoB298qcobcvantKBcEYm+fQDqcIgXgnKkWgk3tcgIMkut0r3VJy9CGQbIVUJM3gF18eCc4/Vgkc2cf6oUw== malcolm@bishop.local"
      ];
  };

  ajk = {
    description     = "Antti-Juhani Kaijanaho";
    home            = "/home/ajk";
    createHome      = true;
    uid             = with import ./ids.nix; uids.ajk;
    group           = "users";
    useDefaultShell = true;
    openssh.authorizedKeys.keys =
      [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCXNOY4lk1YnIJZJ8F1FjCXxCPS7b8c9qZSgmKcHt8dREN+BbgxwiVGfa/2EGC2ASy5QMt10ioVsZBJOEAUrDaHnclwxlBA81FakBemfCqJ3lQEQI7Ay6rRDMYoWw5BVY4pUjoz38g+t8PghA4Z4QuDU79PPvZxHbOjaMvPwxITFk+BeltrcYtLBei6nPRiVVBqWsLnqsIDkBTQUzp8M99nLtege7E3vUnzBedkJ9jjHm+1Im6HgYKS6OHUEUBu/nw8JXHTFo3B4Abk9UtLAGZqQw3dMuJ39Zf+GcdRZ3q2uG/61mjAwZenxEftKimhLSggWG16jVtGJLsAgicl8xxN ajk@kukkavihko"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDNcaX+Jetuc6g9UOs9ug8c9+495NvKmxYwv24eu2AD4n18iQGZAjEZwBoGF8Ij3AYOvwkIBaEc2h3xsRiWL6HJ6pCbQ8qlulveg7IkE/vFh8QgZFo7dmIkN3ZTJrdvnxAE8jV6rieVGfbmBoF3KdmKLuL+Muqqw2gpM8ADSYcHSDVeo9V8VlI/BrBsVjS5WXdgLGUgKDN6FrZsIXhHqXmEVgVXLB6CjJnuD3hvJZ1xXvTr6hr1D7ikwfLcoXXIVYqE9f4ZtdYZv/aWuKJJg2L3DLUPKGyOpfgM5jZyFbcCRJznZVsWXU9UfYQZB0c1OWre9BpYvP747onLbxG+PXH ajk@teralehti"
      ];
  };
}
