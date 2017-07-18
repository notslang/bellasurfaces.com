.PHONY: all deploy

INPUT_IMGS := $(shell find content -type f -name '*.jpg' -not -path '*content/portfolio*')
OUTPUT_IMGS := $(patsubst content/%, public/%, $(INPUT_IMGS))
INPUT_PORTFOLIO_IMGS := $(shell find content/portfolio -type f -name '*.jpg')
OUTPUT_PORTFOLIO_IMGS := $(patsubst content/%, public/%, $(INPUT_PORTFOLIO_IMGS))
OUTPUT_PORTFOLIO_THUMBS := $(patsubst content/%.jpg, public/%-thumb.jpg, $(INPUT_PORTFOLIO_IMGS))
INPUT_PORTFOLIO_ENTRIES := $(shell find content/portfolio -type f -name 'index.md')
OUTPUT_PORTFOLIO_ENTRIES := $(patsubst content/%.md, public/%.html, $(INPUT_PORTFOLIO_ENTRIES))
INPUT_MD_FILES := $(shell find content -type f -name '*.md' -not -path '*content/portfolio*')
OUTPUT_MD_FILES := $(patsubst content/%.md, public/%.html, $(INPUT_MD_FILES))

BASE_DEPS = tmp/render.js tmp/view/layout.marko.js tmp/page-list.json

# without these specified, `portfolio/entry` pages will get compiled with
# `normal` sometimes
.SECONDARY: tmp/view/portfolio/entry.marko.js tmp/view/normal.marko.js \
            tmp/view/portfolio/index.marko.js tmp/view/index.marko.js \
            tmp/view/layout.marko.js

public/%/index.html: content/%/index.md tmp/view/normal.marko.js $(BASE_DEPS)
	mkdir -p "$(dir $@)"
	node tmp/render.js "$<" normal < "$<" > "$@"

public/portfolio/%/index.html: content/portfolio/%/index.md tmp/view/portfolio/entry.marko.js $(BASE_DEPS) tmp/portfolio-list.json
	mkdir -p "$(dir $@)"
	node tmp/render.js "$<" portfolio/entry < "$<" > "$@"

public/portfolio/index.html: tmp/view/portfolio/index.marko.js $(BASE_DEPS) $(OUTPUT_PORTFOLIO_THUMBS) tmp/portfolio-list.json
	mkdir -p "$(dir $@)"
	echo "foo" | node tmp/render.js content/portfolio portfolio/index > "$@"

public/index.html: tmp/view/index.marko.js $(BASE_DEPS) $(OUTPUT_PORTFOLIO_THUMBS) tmp/portfolio-list.json
	mkdir -p "$(dir $@)"
	echo "foo" | node tmp/render.js content/ index > "$@"

tmp/view/%.marko.js: view/%.marko tmp/npm-install-done
	mkdir -p "$(dir $@)"
	node_modules/.bin/markoc "$<"
	mv "$<.js" "$@"

public/%-thumb.jpg: content/%.jpg
	mkdir -p "$(dir $@)"
	MAGICK_OCL_DEVICE=OFF convert -define jpeg:size=400x400 "$<" -thumbnail 300x300^ -gravity center -extent 300x300 - | jpegtran -optimize -progressive > "$@"

tmp/%.js: %.coffee tmp/npm-install-done
	mkdir -p "$(dir $@)"
	echo "'use_strict'" \
	| cat - "$<" \
	| ./node_modules/.bin/coffee -b -c -s > "$@"

tmp/portfolio-list.json: tmp/portfolio-list.js $(INPUT_PORTFOLIO_IMGS) $(INPUT_PORTFOLIO_ENTRIES) tmp/npm-install-done
	node tmp/portfolio-list.js > "$@"

tmp/page-list.json: tmp/page-list.js $(INPUT_MD_FILES) tmp/npm-install-done
	node tmp/page-list.js > "$@.compare"
	if cmp -s "$@.compare" "$@"; then \
		rm "$@.compare"; \
	else \
		mv "$@.compare" "$@"; \
	fi

public/css/%.css: assets/css/%.styl
	mkdir -p "$(dir $@)"
	node_modules/.bin/stylus -I assets/css < "$<" > "$@"

public/css/index.css: assets/css/index.styl assets/css/slidebox.styl

public/%.jpg: content/%.jpg
	mkdir -p "$(dir $@)"
	jpegtran -optimize -progressive < "$<" > "$@"

tmp/npm-install-done: package.json
	if [ -d node_modules ]; then rm -R node_modules; fi
	npm install --production
	mkdir -p tmp
	touch "$@"

tmp/favicon-%.png: assets/img/logo-small.svg tmp/npm-install-done
	node_modules/.bin/svgexport assets/img/logo-small.svg "$@" $*:$* pad; \
	optipng "$@"

public/favicon.ico: tmp/favicon-16.png tmp/favicon-32.png tmp/favicon-48.png
	convert $^ "$@"

public/google%.html:
	mkdir -p "$(dir $@)"
	echo "google-site-verification: google$*.html" > "$@"

all: public/portfolio/index.html public/index.html $(OUTPUT_MD_FILES) \
     $(OUTPUT_PORTFOLIO_ENTRIES) $(OUTPUT_PORTFOLIO_IMGS) $(OUTPUT_IMGS) \
     public/css/index.css public/favicon.ico \
     public/googlea996c0920075fa0d.html
	cp -r assets/wp-* assets/img assets/js public

deploy: all
	# upload images before text files because they take the longest and are referenced by any new HTML pages
	rsync -r --delete --progress --include="*.jpg" --include='*/' --exclude='*' ./public/ core@slang.cx:/data/nginx/content/bellasurfaces.com/
	rsync -r --delete --progress --exclude="*.jpg" ./public/ core@slang.cx:/data/nginx/content/bellasurfaces.com
	rsync --progress ./nginx/config/bellasurfaces.conf core@slang.cx:/data/nginx/config
