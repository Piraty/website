title: Piraty/txt/thunderbird-external-gnupg-for-private-keys
date: 2023-03-27
css:../style.css

# [Piraty](../index.md) / [txt](./index.md)

---

# Thunderbird + External GnuPG

Here are some rough notes on how and why to avoid importing private PGP keys
into Thunderbird, and make it ask external gnupg for them, thus behave similar
to now-obsolete Enigmail did.

A side-effect for me is it is a step forward to my PGP+Yubikey setup.


## TLDR

Ever since Thunderbird-v78 happened in 2020 i hated that their support for PGP
degraded significantly.

Fortunately you can	at least opt-out of the secret-key managing madness and
keep your private keys where they belong (and *only* there): gnupg keyring.

1. In Config Editor, set `mail.openpgp.allow_external_gnupgmail.openpgp.allow_external_gnupg` to *true*.
1. Delete previously imported private keys from Thunderbird's keyring, in case you imported them already
1. Add "external key"(s) with your keyID (strip the leading `0x`!) 
1. Import relevant public keys into "OpenPGP Key Manager" (receipients' and likely your own)
1. Make sure no private keys appear in Thunderbird's "OpenPGP Key Manager"

Basically follow the [GnuPG smartcard guide](https://web.archive.org/web/20230326232007/https://wiki.mozilla.org/Thunderbird:OpenPGP:Smartcards#Allow_the_use_of_external_GnuPG)


## Background

### Thunderbird v78+ Does OpenPGP On Its Own

Before v78, Thunderbird allowed the use of OpenPGP by using Enigmail addon,
which served as a proxy to your host's gnupg.
It provided normal and advanced config modes and was very mature PGP frontend
interface.

It was therefore the responsibility and burden of the user to configure an
OpenPGP compliant host software like gnupg on the platform.

With v78+, Enigmail ceased to be and shipped a migration dialog with its last
release, offering to import public *and* private keys into Thunderbird.
Instead of using external gnupg, Thunderbird now comes with a bundles library
to perform PGP operations.

This has some downsides.


### How Thunderbird Manages Private Keys

Quoting from [OpenPGP in Thunderbird - HOWTO and FAQ](https://web.archive.org/web/20230326232606/https://support.mozilla.org/en-US/kb/openpgp-thunderbird-howto-and-faq#w_how-is-my-personal-key-protected):

> At the time you import your personal key into Thunderbird, we unlock it, and
> protect it with a different password, that is automatically (randomly)
> created. The same automatic password will be used for all OpenPGP secret keys
> managed by Thunderbird. You should use the Thunderbird feature to set a
> Primary Password. Without a Primary Password, your OpenPGP keys in your
> profile directory are unprotected.


### The Downsides

"Handling" PGP keys this way feels awkward and wrong to me... it's sensitive
material afterall.

Thunderbird's OpenPGP feature assumes you have both no other use for PGP keys
other than email and also can afford to trust Thunderbird's management of
keyring and your profile's Primary Password.
Having other use-case while using Thunderbird's internal keyring means having to
deal with key management twice.
Their wiki is a bit [vague on this](https://wiki.mozilla.org/Thunderbird:OpenPGP:Migration-From-Enigmail)
on intentions of the decision.
