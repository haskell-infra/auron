Auron
=================

Auron is the open source codebase automating
[Haskell.org](https://haskell.org), built on [NixOS](http://nixos.org)
and [NixOps](http://nixos.org/nixops). We use it to:

 - Manage all of [Haskell.org](https://haskell.org), including users
   and security updates.
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

Getting started
-----------------

Once you've launched `./bin/shell`, you can begin deployments. The
default nixops network is `vbox`, which uses the VirtualBox backend
for testing.

To get started, deploy a MariaDB and Phabricator pair:

```
$ nixops deploy --include mysql01 phabricator
```

NOTE: This generates temporary SSL keys for nginx under `/root/ssl`.

We also need to generate keys for `spiped`, so that the Phabricator
server can securely communicate with the MariaDB server. This
automatically restarts the right `systemd` units and copies the keys
in the right place, so you can run this command over and over to rekey
the servers.

```
$ ./bin/genspiped mysql mysql01 phabricator
```

Finally, upgrade the database schema, and set the
`phabricator.base-uri` configuration option (so Phabricator knows
where to load resources from). This can be done with a one-liner.

NOTE: Set `phabricator.base-uri` to the FQDN your server will be
located at, or set it to the IP address assigned in `nixops info`.
Note the protocol must be `https`.

```
$ nixops ssh phabricator -- phab-upgrade --nopass && nixops ssh phabricator -- \
    phab-config set phabricator.base-uri https://<YOUR BASE URI>/
```

Now, visit the URL you specified for `base-uri` (either the IP address
or FQDN) and register an administration account. Once you're logged
in, you'll need to configure mail and authentication providers.

Other providers
-----------------

The default deployment network is `vbox` for testing. You can change
this for all commands in the shell to `ec2` or `rackspace` by setting
the `NIXOPS_DEPLOYMENT` environment variable before `nixops deploy`:


```
$ export NIXOPS_DEPLOYMENT=rackspace
$ export NIXOPS_DEPLOYMENT=ec2
```

Then use `nixops` as usual.

NOTE: The `rackspace` provider does not work and falls back to
VirtualBox. See
[NixOps issue #168](https://github.com/NixOS/nixops/issues/168).

NOTE: Read the [NixOps manual](http://nixos.org/nixops/manual/) for
more information, including how to get EC2 keys set up for testing.

Hacking
-----------------

If you're going to hack on the source code, here are some notes.

**Filesystem layout**:

<table>
  <tr>
    <th>Directory</th>
    <th>Purpose</th>
  </tr>
  <tr>
    <td>`bin/`</td>
    <td>Scripts for launching the main shell and interacting with machines.</td>
  </tr>
  <tr>
    <td>`etc/`</td>
    <td>3rd party source code and private data.</td>
  </tr>
  <tr>
    <td>`src/`</td>
    <td>NixOps expressions.</td>
  </tr>
  <tr>
    <td>`src/deploy/`</td>
    <td>Expressions for deployment endpoints (EC2, VBox, or Rackspace).</td>
  </tr>
  <tr>
    <td>`src/hosts/`</td>
    <td>Host descriptions for every major
    [Haskell.org](https://haskell.org) server.</td>
  </tr>
  <tr>
    <td>`src/modules/`</td>
    <td>Custom NixOS modules for our servers.</td>
  </tr>
  <tr>
    <td>`src/modules/`</td>
    <td>Custom Nix packages for our servers.</td>
  </tr>
  <tr>
    <td>`src/res/`</td>
    <td>Misc. expressions, including user descriptions.</td>
  </tr>
  <tr>
    <td>`src/network.nix`</td>
    <td>Top-level NixOps network description.</td>
  </tr>
</table>

**Hostname mapping**:

The following table maps every //logical hostname// to a //physical hostname//.

Externally, every host is referred to and known solely by the logical
hostname (e.g. `mysql01`, `phabricator`, `wiki`). Logical hostnames
also correspond to subdomains of `haskell.org`.

The //physical hostnames// are the actual names of the boxes, as they
exist on the machine. So if you access `user@mysql01`, after logging
in the hostname will be `vivi`. These names are internal, and they are
based on the names of Final Fantasy characters.

NOTE: The source code file for every host under `src/hosts/` is named
after the //physical// hostname, not the logical one! So if you want
to improve `mysql01.nix`, look in `src/hosts/vivi.nix`.

<table>
  <tr>
    <th>Logical hostname</th>
    <th>Physical hostname</th>
  </tr>
  <tr>
    <td>[planet](https://planet.haskell.org)</td>
    <td>Squall</td>
  </tr>
  <tr>
    <td>`mysql01`</td>
    <td>Vivi</td>
  </tr>
  <tr>
    <td>[wiki](https://wiki.haskell.org)</td>
    <td>Yuna</td>
  </tr>
  <tr>
    <td>[phabricator](https://phabricator.haskell.org)</td>
    <td>Rikku</td>
  </tr>
  <tr>
    <td>[darcs](https://darcs.haskell.org)</td>
    <td>Rinoa</td>
  </tr>
  <tr>
    <td>[ghc](https://ghc.haskell.org/trac/ghc)</td>
    <td>Cloud</td>
  </tr>
  <tr>
    <td>[www](https://www.haskell.org)</td>
    <td>Cid</td>
  </tr>
  <tr>
    <td>[hackage](https://hackage.haskell.org)</td>
    <td>Terra</td>
  </tr>
  <tr>
    <td>[monitor](https://monitor.haskell.org)</td>
    <td>Lulu</td>
  </tr>
  <tr>
    <td>`hackage-build`</td>
    <td>Barret</td>
  </tr>
  <tr>
    <td>[community](http://community.haskell.org)</td>
    <td>Freya</td>
  </tr>
  <tr>
    <td>`mail`</td>
    <td>Fran</td>
  </tr>
</table>

Contributing
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

License
=================

Auron is released under the MIT license except as otherwise noted. See
`LICENSE.txt` for details.
