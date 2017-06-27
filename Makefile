.PHONY: all deploy

INPUT_IMGS = $(shell find content -type f -name '*.jpg' -not -path '*content/portfolio*')
OUTPUT_IMGS = $(patsubst content/%, public/%, $(INPUT_IMGS))
INPUT_PORTFOLIO_IMGS = $(shell find content/portfolio -type f -name '*.jpg')
OUTPUT_PORTFOLIO_IMGS = $(patsubst content/%, public/%, $(INPUT_PORTFOLIO_IMGS))
OUTPUT_PORTFOLIO_THUMBS = $(patsubst content/%.jpg, public/%-thumb.jpg, $(INPUT_PORTFOLIO_IMGS))
INPUT_PORTFOLIO_ENTRIES = $(shell find content/portfolio -type f -name 'index.md')
OUTPUT_PORTFOLIO_ENTRIES = $(patsubst content/%.md, public/%.html, $(INPUT_PORTFOLIO_ENTRIES))
INPUT_MD_FILES = $(shell find content -type f -name '*.md' -not -path '*content/portfolio*')
OUTPUT_MD_FILES = $(patsubst content/%.md, public/%.html, $(INPUT_MD_FILES))

public/%.html: content/%.md tmp/view/normal.marko.js
	mkdir -p "$(dir $@)"
	node tmp/render.js "$<" < "$<" > "$@"

public/portfolio/%.html: content/portfolio/%.md tmp/view/portfolio/entry.marko.js tmp/portfolio-list.json
	mkdir -p "$(dir $@)"
	node tmp/render.js "$<" < "$<" > "$@"

public/portfolio/index.html: tmp/view/portfolio/index.marko.js $(OUTPUT_PORTFOLIO_THUMBS) tmp/portfolio-list.json
	mkdir -p "$(dir $@)"
	echo "foo" | node tmp/render.js content/portfolio/index.html > "$@"

public/index.html: tmp/view/index.marko.js $(OUTPUT_PORTFOLIO_THUMBS) tmp/portfolio-list.json
	mkdir -p "$(dir $@)"
	echo "foo" | node tmp/render.js content/index.html > "$@"

tmp/view/%.marko.js: view/%.marko tmp/npm-install-done
	mkdir -p "$(dir $@)"
	node_modules/.bin/markoc "$<"
	mv "$<.js" "$@"

tmp/view/portfolio/index.marko.js: tmp/view/layout.marko.js

tmp/view/index.marko.js: tmp/view/layout.marko.js

tmp/view/normal.marko.js: tmp/view/layout.marko.js

tmp/view/portfolio/entry.marko.js: tmp/view/layout.marko.js

tmp/view/layout.marko.js: tmp/render.js

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

all: public/portfolio/index.html public/index.html $(OUTPUT_MD_FILES) \
     $(OUTPUT_PORTFOLIO_ENTRIES) $(OUTPUT_PORTFOLIO_IMGS) $(OUTPUT_IMGS) \
     public/css/index.css
	cp --reflink=auto -r assets/wp-* assets/img assets/js -t public

deploy: all
	# upload images before text files because they take the longest and are referenced by any new HTML pages
	rsync -r --delete --progress --include="*.jpg" --include='*/' --exclude='*' ./public/ core@slang.cx:/data/nginx/content/bellasurfaces.com/
	rsync -r --delete --progress --exclude="*.jpg" ./public/ core@slang.cx:/data/nginx/content/bellasurfaces.com
	rsync --progress ./nginx/config/bellasurfaces.conf core@slang.cx:/data/nginx/config
