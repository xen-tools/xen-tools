
all:
	@cd ..; prove --shuffle t/

verbose:
	@cd ..; prove --shuffle --verbose t/


modules: .PHONY
	./modules.sh > modules.t

.PHONY:
	true

clean:
	-rm *~
