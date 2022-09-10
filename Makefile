default: help

help:
	@echo "Please use \`make <target>' where <target> is one of:"
		@echo "  help    - to show this message"
		@echo "  preview - to build the collection archive"
		@echo "  clean   - clean workspace"

preview:
	bundle exec jekyll serve --watch --future --drafts

clean:
	rm -Rf .build

FORCE:

configure:
	bundle install

.PHONY: help preview clean stop FORCE
