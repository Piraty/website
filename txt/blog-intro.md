title: I chose boring tech for this blog
date: 2022-05-08
css:../style.css

# [Piraty](../index.md) / [txt](./index.md)

---

# I Chose Boring Tech For This Site

Everybody and their grandma needs a blog, so here is mine.

I chose boring tech [^borig-tech].

## TLDR

Here is the code: https://github.com/Piraty/piraty.github.io


## Intro

Finding a static generator that fits my needs in 2022 is actually hard.
It's not that there are none, quite the opposite: there are way too many.
There are even catalog sites like [staticgen](https://www.staticgen.com/) that
try to shed light into this forrest of projects.

The amount of projects was surprising to me, as they all are basically just
templating engines to generate html from markdown files, which i suspected to
be a solved problem in this era.

The majority of them seems to be implemented in all the mutations of server-side
javascript known to mankind.
Where they differ from an outsider's view is the ecosystem of "themes" (in
essence: stylesheets).

I tried hugo (the most prominent golang impl), found that writing a theme is
underdocumented and too hard, and decided to create my own workflow instead.

## The Stack

* lowdown [^lowdown] -- to generate html from markdown
* make -- to build it all

## The Theme

* simple css that doesn't try to fight against the user's browser preferences
* no javascript
* no cookies

## Deployment

For now it's hosted on github-pages, but given it's just serving static html i
could host from my own infra in no time if i chose to.

Github-pages serves from the `live` branch [^live-branch], to which i push the
generated html.

## Conclusion

This is easy-enough to maintain and could be served from an old toaster, so it
scales in all directions.
It should also be accessible across all device form factors and render somewhat
accurate on a pre2000 Netscape.

As there are no usage statistics in any way, i will never know if anyone else
besides the spiders came here.

Mission accomplished.


[^borig-tech]: https://mcfunley.com/choose-boring-technology
[^live-branch]: https://github.com/Piraty/piraty.github.io/tree/live
[^lowdown]: https://kristaps.bsd.lv/lowdown/
