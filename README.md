Auron
=================

Auron is the open source codebase for Haskell.org for automation,
built on [NixOS](http://nixos.org) and
[NixOps](http://nixos.org/nixops). We use it to:

 - Deploy things reproducibly and easily from any Linux box.
 - Send status updates to the [status site](http://status.haskell.org).
 - Send patches to [Phabricator](https://phabricator.haskell.org).
 - And more!

Setup
-----------------

IMPORTANT: You must be using Linux and
[Nix](http://nixos.org/nix/manual/#chap-installation) 1.7 or later for
things to work properly! Otherwise `./bin/shell` will not start.

- Clone this repo.
- Update the submodules - run `git submodule init && git submodule update`
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

NOTE: Read the [NixOps manual](http://nixos.org/nixops/manual/) for
more information, including how to get EC2 keys set up for testing.


CONTRIBUTING
=================

Patches, comments, and tickets should be submitted through
[Phabricator](https://phabricator.haskell.org), using Maniphest and
Arcanist. You'll need to create an account.

If you have a patch, first, drop into `./bin/shell`, then commit it
and upload with `arc diff`:

```
$ ./bin/shell
$ git commit -asm "Fix thing"
$ arc diff
```

NOTE: Using `./bin/shell` is the recommended way to use the `arc`
tool, to ensure it is the same version that Haskell.org uses.

IMPORTANT: Make sure you use `-s` to add a `Signed-off-by` line! This
specifies you agree the submitted code abides by the project license
unless explicitly noted otherwise.

For reviewers, you can specify `#auron` to add all of the developers.

Read the Arcanist
[guide](https://secure.phabricator.com/book/phabricator/article/arcanist/)
for more.

LICENSE
=================

Auron is released under the MIT license except as otherwise noted. See
`LICENSE.txt` for details.
