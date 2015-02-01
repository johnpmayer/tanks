all: elm.js node_modules

node_modules: package.json
	npm install

elm.js: src/*.elm
	elm-make src/Game.elm src/Lobby.elm

clean:
	rm -rf elm-stuff
	rm -rf node_modules

run:
	(cd framework; node server)

.PHONY: clean
