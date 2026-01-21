title: Remux DVD with Ffmpeg
date: 2026-01-22
css:../style.css

# [Piraty](../index.md) / [txt](./index.md)

---

# Remux DVD With FFmpeg

## Intro

Remuxing your DVD will grab the DVD's video stream and store it *as is* in a
file on your computer (notably without re-encoding it, so you don't lose
quality at the expense of larger files).
I choose a good and well-suported container format: Matroska (MKV).
It can even embed multiple audio tracks and subtitles into the file.

When I learned about remuxing dvd, I found plenty of old advice on the net,
that told to use either of

1. dubious nonfree `makemkv`
1. use FFmpeg with its `concat` demuxer

I did not look at `makemkv`.
The `ffmpeg`+`concat` works by piping the concatenated track files into ffmpeg.
That approach worked for very few DVDs, but required nontrivial manual
adjustments every time and it was unable to retain all metadata like audio
track names and subtitle track names.
And then I was unable to remux some DVDs
as ffmpeg threw cryptic timestamp issues (likely I fed the wrong track files)
but it was too opaque to understand what I did wrong.

The good news is: recent `ffmpeg` gained a `dvdvideo` demuxer that does what I
need just fine: remux the DVD video stream into matroska file, keep all audio
tracks (with metadata like name), keep all subtitles (with metadata like name)
and keep chapter markers.


## Prereqs

We just need

* `lsdvd` to find out which tracks we can grab
* `ffmpeg >= 7` to remux the DVD's tracks for us
* `backupdvd` (optional) to produce a local copy once, to speed up the multiple
  remux attempts (for example: fine tuning ffmpeg options)


## Remux

Let's use `lsdvd` to learn about all available tracks:

	lsdvd -x /dev/cdrom
	# output:
	# Title: 01, Length: 01:21:44.433 Chapters: 26, ...
	# Title: 02, Length: 00:01:52.133 Chapters: 01, ...
	# ...

Title 01 is obviously the main feature.
Note that `dvdbackup ... --info` enumerates differently and you cannot use its
reported indices for ffmpeg.

Make sure you have a copy of ffmpeg near you that sports the `dvdvideo`
demuxer:

	ffmpeg -hide_banner -demuxers | grep -E '\s+dvdvideo' || echo "oh no"


I use the `preindex` option.
`ffmpeg`'s manpage advises us to work with
local dvd backup in this case as will do a second pass that's slow on the real
optical media.
It doubles the required space though, but it can be deleted afterwards.
We will use `dvdbackup` for this.

The remux command is implemented with ffmpeg like this:

	SRC=/dev/cdrom
	TITLE_NAME=BigBugBounty
	TITLE_NUM=01

	# (optional)
	dvdbackup -i /dev/cdrom -o "$(pwd)" --mirror -n dvdbackup --progress
	SRC="$(pwd)/dvdbackup/VIDEO_TS"

	# remux DVD
	# keep all audio streams + subs + chapters
	ffmpeg \
		-nostdin \
		-y \
		-hide_banner \
		-stats \
		-f dvdvideo \
		-preindex 1 \
		-title "$TITLE_NUM" \
		-i "$SRC" \
		-map 0 -c copy -map_metadata 0 -map_chapters 0 \
		-metadata title="${TITLE_NAME}" \
		"${TITLE_NAME}.t-${TITLE_NUM}.mkv"

	# :-)
	eject

As simple as that.


## Notes On Failed Remux Due To Read Error

Some of my DVD are old and have scratches.
Some are just dirty -- clean them propery ;-) .

If issue remains, here is some advice how to work around read errors:

* At times I found `dvdbackup` doesn't seem to do a good job on scratched
  media, though it has `-r` option for read error handling, maybe you are more
  lucky with it)
* remux directly from the optical drive: run `ffmpeg` command with `-i
  /dev/cdrom` and `-preindex 0` the optical drive.
* `ddrescue`. Not ideal but unlike a dying HDD is unlikely to cause more
  damage.
  Give it a try, if you have the time. `info ddrescue` has some hints on how to
  work with optical media.
