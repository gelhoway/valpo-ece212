

SOURCE=$(wildcard *.adoc)
INCLUDE_DIRS=css fig

FIGURES=$(wildcard fig/*)
CSSS=$(wildcard css/*)
COMMONS=$(wildcard common/*)

RESOURCES=$(FIGURES) $(CSSS) $(COMMONS)

ASCIIDOCTOR_OPTS=
ASCIIDOCTOR_OPTS+=-a linkcss
ASCIIDOCTOR_OPTS+=-a icons=font
ASCIIDOCTOR_OPTS+=-a stylesdir=css
ASCIIDOCTOR_OPTS+=-a imagesdir=fig
ASCIIDOCTOR_OPTS+=-a scriptsdir=js
ASCIIDOCTOR_OPTS+=-a stem=latexmath
ASCIIDOCTOR_OPTS+=-a docinfo=shared
ASCIIDOCTOR_OPTS+=-a docinfodir=common
#ASCIIDOCTOR_OPTS+=-a sectnums
ASCIIDOCTOR_OPTS+=-a sectanchors
ASCIIDOCTOR_OPTS+=-a xrefstyle=full
ASCIIDOCTOR_OPTS+=-a stylesheet=asciidoctor.css


#GUIDEBOOK_INCLUDES=$(shell grep -o -e '[^:<]\+\.adoc'  guidebook.adoc)

default: html


html: $(SOURCE:.adoc=.html) $(RESOURCES)

pdf: $(SOURCE:.adoc=.pdf)

#	    $(INCLUDE_DIRS) *.html \

web: html
	rsync -avuP \
	    --include='.htaccess' \
	    --exclude='.*' \
	    --exclude='*.adoc' \
	    --exclude='Makefile' \
	    --exclude=tmp \
	    --delete-excluded \
	    --delete \
	    . \
	    dan@tesla.whiteaudio.com:/var/www/www.agnd.net/valpo/212/

#fig: $(FIGURES)
fig:
	$(MAKE) -C fig




%.xml: %.adoc
	SOURCE_DATE_EPOCH=$(shell git log -1 --pretty=%ct) asciidoctor \
	    -b docbook \
	    $(ASCIIDOCTOR_OPTS) \
	    $<

README.html: README.adoc
	SOURCE_DATE_EPOCH=$(shell git log -1 --pretty=%ct) asciidoctor \
	    --no-header-footer \
	    $<

HEADER.html: HEADER.adoc
	SOURCE_DATE_EPOCH=$(shell git log -1 --pretty=%ct) asciidoctor \
	    $<

%.html: %.adoc
	SOURCE_DATE_EPOCH=$(shell git log -1 --pretty=%ct) asciidoctor \
	    $(ASCIIDOCTOR_OPTS) \
	    $<

%-slides.html: %-slides.adoc %.adoc $(RESOURCES)
	SOURCE_DATE_EPOCH=$(shell git log -1 --pretty=%ct) \
	    bundle exec asciidoctor-revealjs \
	    $<

#%.pdf: %.adoc
#	SOURCE_DATE_EPOCH=$(shell git log -1 --pretty=%ct) asciidoctor-pdf \
#	    -r asciidoctor-mathematical \
#	    -a mathematical-format=svg \
#	    -a allow-uri-read \
#	    $(ASCIIDOCTOR_OPTS) \
#	    $<

%.pdf: %.html
	#specific fixup for htmlto and underlying phantomjs DPI issue
	sed 's/<\/head>/<style>@media print{body{zoom:0.75;}}<\/style><\/head>/' $< > $<.tmp.html
	~/node_modules/htmlto/bin/htmlto $<.tmp.html $@
	rm $<.tmp.html


