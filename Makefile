.PHONY: all deploy

INPUT_IMGS = $(shell find content -type f -name '*.jpg' -not -path "*content/portfolio*")
OUTPUT_IMGS = $(patsubst content/%, public/%, $(INPUT_IMGS))
INPUT_PORTFOLIO_IMGS = $(shell find content/portfolio -type f -name '*.jpg')
OUTPUT_PORTFOLIO_IMGS = $(patsubst content/%, public/%, $(INPUT_PORTFOLIO_IMGS))
OUTPUT_PORTFOLIO_THUMBS = $(patsubst content/%.jpg, public/%-thumb.jpg, $(INPUT_PORTFOLIO_IMGS))
INPUT_HTML_FILES = $(shell find content/ -type f -name '*.html')
OUTPUT_HTML_FILES = $(patsubst content/%, public/%, $(INPUT_HTML_FILES))
INPUT_MD_FILES = $(shell find content/ -type f -name '*.md')
OUTPUT_MD_FILES = $(patsubst content/%.md, public/%.html, $(INPUT_MD_FILES))

public/%.html: content/%.html tmp/view/normal.marko.js
	mkdir -p "$(dir $@)"
	node tmp/render.js "$<" < "$<" > "$@"

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

tmp/%.marko.js: %.marko
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
	MAGICK_OCL_DEVICE=OFF convert -define jpeg:size=400x400 "$<" -thumbnail 300x300^ -gravity center -extent 300x300 "$@"

tmp/%.js: %.coffee
	mkdir -p "$(dir $@)"
	echo "'use_strict'" \
	| cat - "$<" \
	| ./node_modules/.bin/coffee -b -c -s > "$@"

tmp/portfolio-list.json: tmp/portfolio-list.js $(OUTPUT_PORTFOLIO_IMGS)
	node tmp/portfolio-list.js > "$@"

public/css/%.css: assets/css/%.styl
	mkdir -p "$(dir $@)"
	node_modules/.bin/stylus -I assets/css < "$<" > "$@"

public/css/index.css: assets/css/index.styl assets/css/slidebox.styl

public/%.jpg: content/%.jpg
	mkdir -p "$(dir $@)"
	cp --reflink "$<" "$@"

all: public/portfolio/index.html public/index.html $(OUTPUT_HTML_FILES) $(OUTPUT_MD_FILES) $(OUTPUT_PORTFOLIO_IMGS) $(OUTPUT_IMGS) public/css/index.css
	cp --reflink -r assets/wp-* assets/img assets/js -t public

deploy: all
	rsync -r --delete --progress ./public/ core@slang.cx:/data/nginx/content/bellasurfaces.com
	rsync --progress ./nginx/config/bellasurfaces.conf core@slang.cx:/data/nginx/config
