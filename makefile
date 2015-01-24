all: 
	elm-make src/Game.elm

clean:
	rm -rf elm-stuff

.PHONY: clean
