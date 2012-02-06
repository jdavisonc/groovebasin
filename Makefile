coffee=coffee
appjs=public/app.js
rdiojs=public/rdio_frame.js
appcss=public/app.css
views=views/*.handlebars
src=src/app.coffee src/rdio_client.coffee src/mpd.coffee
rdiosrc=src/rdio_frame.coffee
scss=src/app.scss

testjs=public/test.js
testsrc=test/test.coffee src/mpd.coffee
testview=test/view.handlebars

or_die = || (rm -f $@; exit 1)

.PHONY: build clean

build: $(appjs) $(rdiojs) $(appcss) $(testjs) $(testhtml)

$(appjs): $(views) $(src)
	(coffee -p -c $(src) >$@) $(or_die)
	(handlebars $(views) -k if -k each -k hash >>$@) $(or_die)

$(rdiojs): $(rdiosrc)
	($(coffee) -p -c $(rdiosrc) > $@) $(or_die)

$(appcss): $(scss)
	sass --no-cache --scss $(scss) $(appcss)

$(testjs): $(testview) $(testsrc)
	coffee -p -c $(testsrc) >$(testjs)
	handlebars $(testview) >>$(testjs)

clean:
	rm -f $(appjs) $(appcss) $(testjs)

