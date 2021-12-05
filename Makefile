SUBDIRS := .

ALL_MD := $(foreach dir,$(SUBDIRS),$(wildcard $(dir)/*md))


LOWDOWN_ARGS = \
	-M "author:Piraty" \
	-m "title:Piraty" \
	-m "css:./style.css" \
	-m "date:$(shell date -I)"

ALL_HTML := $(ALL_MD:.md=.html)


all: $(ALL_HTML)

%.html: %.md
	lowdown \
		$(LOWDOWN_ARGS_DEFAULT) \
		$(LOWDOWN_ARGS) \
		-s \
		-o $(@) \
		$(^)

.PUBLISH_COMMIT:
	printf '%s\n' \
		"published from: $(shell git log --format='%H' master | head -n1)" \
		"" \
		"this commit was made by 'make publish'" \
		"real work happens on master" \
		> $(@)

publish: .PUBLISH_COMMIT
	-git branch live
	git checkout live
	git merge master
	make clean
	make all
	git add -f $(ALL_HTML)
	git commit --file .PUBLISH_COMMIT
	rm .PUBLISH_COMMIT
	git push origin live
	git checkout master

clean:
	rm -f $(ALL_HTML)

.PHONY: all clean install publish
