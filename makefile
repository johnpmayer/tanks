all: 
	elm-make src/Game.elm

clean:
	rm -rf elm-stuff

run:
	(cd framework; node server)

.PHONY: clean
