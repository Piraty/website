DESTDIR ?= live

SUBDIRS := txt

ALL_MD := $(shell find -type f -iname '*.md' | sort)
TRACKED_MD := $(shell git ls-files '*.md' | grep -v '^README\.md$$')
EXTRA_FILES := \
	style.css \
	0x82F2CC796BD07077.pub.asc

LOWDOWN_ARGS = \
	-M "author:Piraty" \
	-m "title:Piraty" \
	-m "css:./style.css" \
	-m "date:$(shell date -I)"

ALL_HTML := $(ALL_MD:.md=.html)
TRACKED_HTML := $(TRACKED_MD:.md=.html)

ALL := $(ALL_HTML) $(EXTRA_FILES)


all: $(ALL)

install: $(foreach f,$(ALL),$(DESTDIR)/$(f))

%.html: %.md
	lowdown \
		$(LOWDOWN_ARGS_DEFAULT) \
		$(LOWDOWN_ARGS) \
		-s \
		-o $(@).tmp \
		$(^)
# fix hyperlinks pointing to markdown files
	sed -i $(@).tmp -e 's/\.md"/\.html"/'
	mv $(@).tmp $(@)

$(DESTDIR)/%: ./%
	install \
		-t "$(DESTDIR)/$$(dirname "$(*)")" -Dm644 \
		"$(*)"
	rm -f $(ALL_HTML)



publish: $(TRACKED_HTML) $(EXTRA_FILES)
	printf '%s\n' \
		"published from: $(shell git show --no-patch --format="reference" HEAD)" \
		"" \
		"this commit was made by 'make publish'" \
		"real work happens on master" \
		> .PUBLISH_COMMIT
	-git branch live
	git checkout live
	git merge --no-edit master
	make -B -j$$(nproc) $(^)
	git add -f $(^)
	git commit --file .PUBLISH_COMMIT
	rm .PUBLISH_COMMIT
	git push origin live
	git checkout master

clean:
	rm -f $(ALL_HTML)
	rm -rf $(DESTDIR)

.PHONY: all clean install publish
