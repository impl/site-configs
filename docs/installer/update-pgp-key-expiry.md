<!--
SPDX-FileCopyrightText: 2024 Noah Fontes

SPDX-License-Identifier: CC-BY-NC-SA-4.0
-->

# Updating a PGP Key's Expiry

You can update the expiry of a PGP key's subkeys, send the modified public key to desired key servers, and export any desired components as a PDF from the [get-image.md](installer image).

**Note:** Do not connect the computer you're working on to a network until you have erased the secret key from the keyring.

## Become the Superuser

```
[nixos@nixos:~]$ sudo -i
```

## Load the Key

The key can be imported into the keyring from a file on a securely stored USB drive:

```
[root@nixos:~]# mount /dev/sda /mnt

[root@nixos:~]# gpg --import /mnt/key.asc
[...]

[root@nixos:~]# umount /mnt
```

## Change the Expiration of the Subkeys

```
[root@nixos:~]# gpg --edit-key noah@noahfontes.com
[...]
gpg> key 1
[...]
gpg> key 2
[...]
gpg> key 3
[...]
gpg> expire
Are you sure you want to change the expiration time for multiple subkeys? (y/N) y
[...]
Key is valid for? (0) 20250101T000000Z
Key expires at Wed 01 Jan 2025 12:00:00 AM UTC
Is this correct? (y/N) y
[...]
gpg> save

[root@nixos:~]# gpg --armor --export noah@noahfontes.com >impl.asc
```

## Export the Key for Printing

If you'd like to [print](printing.md) part of your key, you can do so using [gpg-hardcopy](https://github.com/impl/gpg-hardcopy), which is included in the installer image. The `--export` option determines which components of the key will be printed. For anything other than the public key, you should use a local printer.

```
[root@nixos:~]# gpg-hardcopy --key impl.asc impl.pdf
[...]

[root@nixos:~]# lp impl.pdf
[...]
```

## Remove the Secret Key from the Keyring

```
[root@nixos:~]# gpg --delete-secret-keys noah@noahfontes.com
[...]
Delete this key from the keyring? (y/N) y
This is a secret key! - really delete? (y/N) ?
Do you really want to permanently delete the OpenPGP secret key:
[...]
?y
```

At this point, it is safe to [connect to a network](connect-network.md).

## Publish the Public Key

```
[root@nixos:~]# gpg --keyserver keyserver.ubuntu.com --send-keys 3665FFF79D387BAA
gpg: sending key 0x3665FFF79D387BAA to hkp://keyserver.ubuntu.com
```

## Update the Public Key in this Repository

On another machine with this repository cloned:

```
[you@somewhere:~/site-configs]$ gpg-connect-agent --dirmngr
gpg-connect-agent: no running dirmngr - starting '/nix/store/wd3xl6h29kjr9ng2kl0yf3mh7ciw3pri-gnupg-2.4.1/bin/dirmngr'
gpg-connect-agent: waiting for the dirmngr to come up ... (5s)
gpg-connect-agent: connection to the dirmngr established
> ^D

[you@somewhere:~/site-configs]$ gpg --keyserver keyserver.ubuntu.com --refresh-keys
[...]

[you@somewhere:~/site-configs]$ gpg --armor --export noah@noahfontes.com >keys/impl.asc
[...]
```
