
all:
	@cd ..; prove --shuffle tests/

verbose:
	@cd ..; prove --shuffle --verbose tests/


modules: .PHONY
	./modules.sh > modules.t

.PHONY:
	true

clean:

	rm *~
