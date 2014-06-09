Auron
=================

Auron is the open source codebase for Haskell.org for automation and
tooling. We use it to:

 - Deploy things reproducibly and easily from any Linux box.
 - Send status updates to the [status site](http://status.haskell.org).
 - Send patches to [Phabricator](https://phabricator.haskell.org).
 - And more!

Setup
-----------------

IMPORTANT: You must be using Linux and
[Nix](http://nixos.org/nix/manual/#chap-installation) 1.7 or later for
things to work properly!

- Clone this repo
- Run `./bin/shell`

This will drop you into an instance of `nix-shell`, with
pre-configured NixOps networks for EC2, Rackspace, and VirtualBox. You
can run `nixops list` to see all networks and VMs.

For instance, to deploy a Phabricator+MySQL server pair, run:

```
$ nixops deploy -d vbox --option extra-binary-caches http://hydra.nixos.org \
    --include mysql01 phabricator
```

The default deployment network is `vbox` for testing. You can change
this for all commands in the shell to `ec2` or `rackspace` by running:

```
$ export NIXOPS_DEPLOYMENT=ec2
$ export NIXOPS_DEPLOYMENT=rackspace
```

NOTE: The `rackspace` provider does not work and falls back to
VirtualBox. See
[NixOps issue #168](https://github.com/NixOS/nixops/issues/168).

NOTE: Read the [NixOps manual](http://nixos.org/nixops/manual/) to get
EC2 keys set up for testing.


CONTRIBUTING
=================

Patches, comments, etc should be submitted through
[Phabricator](https://phabricator.haskell.org).

See the `CONTRIBUTING.md` file for details.

LICENSE
=================

Auron is released under the MIT license except as otherwise noted.
