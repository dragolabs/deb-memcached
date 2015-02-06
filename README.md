# deb-memcached
[![Build Status](https://travis-ci.org/dragolabs/deb-memcached.svg?branch=master)](https://travis-ci.org/dragolabs/deb-memcached)

## Depends
You need ruby and fpm installed to create .deb package.


## Options build.sh
* `-m` - optional. Set the maintainer's name, mail, etc. Default: user@hostname
* `-v` - optional. version of memcached. Default: 1.4.22
* `-o` - optional. Used to set org in the iteration of the package (example: wheezy1, myorg2, etc). Default: debian


## Usage
Use build.sh with Jenkins or in your terminal.  
You'll find your .deb in the _pkg directory.

```bash
$ ./build.sh -m 'John Smith' -o 'my_org' -v 1.5.1.2

[... many symbols ...]

Created package {:path=>"_dpkg/memcached-1.4.22-my_org1502052003-amd64.deb"}

```

## Links
* [memcached](http://memcached.org/)
* [FPM](https://github.com/jordansissel/fpm)