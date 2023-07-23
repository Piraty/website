title: Allow Old Software To Use Https That Was Never Meant To
date: 2022-05-09
css:../style.css

# [Piraty](../index.md) / [txt](./index.md)

---

# Allow Old Software To Use Https That Was Never Meant To

Make streamripper, although it lacks support for https, connect to shoutcast
streams over https.

## TLDR

To make software connect to a TLS encrypted hypertext protocol connection that
on its own has no means to talk TLS, I recently found out that
[socat](http://www.dest-unreach.org/socat/) is a great fit.
In other words, it can unwrap the TLS layer and relay plain http.

If

	${APP} https://${host}:${port}/some/resource.txt

doesn't work, do this:

	socat "TCP-LISTEN:${localport}" "OPENSSL:${host}:${port}" &

	${APP} http://localhost:${localport}/some/resource.txt


## Long Version

I use streamripper [^streamripper] ever since i used the audio
player that really whipped the llama's ass [^winamp].
It was one of the first packages i ever contributed to Void Linux
[^streamripper-pr], it didn't have a release in 13 years and it has no support
for TLS/https whatsoever.

I recently configured some runit user-services on my VPS to rip some of my
favorite radio streams 24/7 that i would sync to a thumb drive every now and
then to listen to it in my car or on my phone [^phone].
All stations offer shoutcast over https as well as plain http, which is fine
for streamripper.

When i listened to ripped files the other day, with one particular stream i
recognized an oddity: mp3 stream over https is sent in stereo, mp3 stream over
plain http is sent in mono.
Huh?

Simply switching the URL to https resulted in

	$ streamripper https://some.stream.com:9999/station.mp3 -d /tmp/ --debug

	Connecting...

	error -7 [SR_ERROR_RECV_FAILED]

	bye..

	shutting down

This is unacceptible and i started to poke.
I inspected the source code, found many oddities with the repo, commit history,
the code itself and the build system (all that deserves its own blog post) and
finally decided that i'm not the one adding TLS support to streamripper (not
this time at least).

After asking people more literated than me, i was hinted at socat and quickly
found that others [^heapsprayblog] wrote about this specific problem already,
albeit in a slightly different use case.

So finally, the service file roughly look like this:
It starts an instance of socat that connects the remote stream and relays
the un-TLS'ed http to localhost, which streamripper then happily connects to.

	opts=
	defOpts=
	defOpts="$defOpts -r 8000" # relay
	defOpts="$defOpts -z" # don't scan ports
	defOpts="$defOpts -o larger"

	. ./conf
	socat "TCP-LISTEN:${port}" "OPENSSL:${host}:${port}" &
	streamripper "$url" $defOpts $opts

Mission accomplished.


[^heapsprayblog]: [http://heapspray.net/post/using-socat-to-proxy-ssl-connections/](https://web.archive.org/web/20220508215724/http://heapspray.net/post/using-socat-to-proxy-ssl-connections/)
[^phone]: [Pinephone](https://www.pine64.org/pinephone/)
[^streamripper-pr]: [void-packages@ee47f40f4d](https://github.com/void-linux/void-packages/commit/ee47f40f4d)
[^winamp]: [Winamp](https://web.archive.org/web/20050401094645/http://www.winamp.com/)
[^streamripper]: [Streamripper](http://streamripper.sourceforge.net/) 
