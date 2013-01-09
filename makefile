all: Game.html ShootDemo.html

Game.html: *.elm
	elm --make -r elm-runtime.js Game.elm

ShootDemo.html: *.elm
	elm --make -r elm-runtime.js ShootDemo.elm

clean:
	rm -f *.html

.PHONY: clean
