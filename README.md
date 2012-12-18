# Erlang Starter Kit

The Starter Kit should provide a basic set of Erlang/OTP tools for
development and for testing.

The latest version is at http://github.com/norton/erlang-starter-kit/

## Learning

This won't teach you Erlang/OTP, but it'll make it easier to get
started as a developer.

## Installation

1. Install Erlang/OTP. Use your package manager if you have one.
   Otherwise download from [Open-source
   Erlang](http://www.erlang.org/download.html) a source tarball for
   building and installing.
2. Make sure erl and erlc are in your shell's path.
3. Move the directory containing this file to "~/.erlang.d". (If you
   already have a directory at ~/.erlang.d move it out of the way and
   put this there instead.)
4. Download (i.e. make -C ~/.erlang.d deps) the Starter Kit's
   Dependencies.
5. Build (i.e. make -C ~/.erlang.d) the Starter Kit.
6. Make (i.e. ln -s ~/.erlang.d/init.erl ~/.erlang) a symbolic link to
   the file "~/.erlang.d/init.erl". (If you already have a file at
   ~/.erlang move it out the way and symlink this there instead.)

## Structure

The init.erl file is where everything begins.

## Contributing

See the file TODO.

Files are licensed under the same license as Erlang/OTP unless
otherwise specified. See the file COPYING for details.

The latest version is [here](http://github.com/norton/erlang-starter-kit/).

## Credits

Thanks to the [Emacs Starter
Kit](http://github.com/technomancy/emacs-starter-kit/) for the
original idea and for helping write this README!
