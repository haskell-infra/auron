= Auron =

Auron is the open source codebase for Haskell.org for automation and
tooling. We use it to:

 - Deploy things reproducibly and easily from any Linux box.
 - Send status updates to the [status site](http://status.haskell.org).
 - Send patches to [Phabricator](https://phabricator.haskell.org).
 - And more!

== Setup ==

IMPORTANT: You must be using
[nix](http://hydra.nixos.org/build/11757938/download/1/manual/manual.html#chap-installation)
1.7 or later for things to work properly!

- Clone this repo
- Run `./bin/shell`

To deploy a Phabricator+MySQL server pair, for example, run:
```shell
nixops deploy -d vbox --option extra-binary-caches http://hydra.nixos.org \
--include haskell-keypair mysql01 phabricator`
```

You can change `vbox` to other things, such as `ec2` (provided you have a
valid `~/.ec2-keys` set up), or `rackspace` (which doesn't work yet).

= CONTRIBUTING =

Patches, comments, etc should be submitted through
[Phabricator](https://phabricator.haskell.org).

See the `CONTRIBUTING.md` file for details.

= LICENSE =

Auron is released under the MIT license except as otherwise noted.
