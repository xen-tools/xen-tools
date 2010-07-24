
all:
	@cd ..; prove --shuffle t/

verbose:
	@cd ..; prove --shuffle --verbose t/


modules: modules.sh
	./modules.sh > modules.t

clean:
	-rm *~
