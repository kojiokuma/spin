SPIN=spin
TARGET=thread.pml
LTLS= 	absence_afteruntil.ltl \
	absence_afteruntil_lo.ltl \
	absence_global.ltl \
	response_global.ltl \
	response_global_sf.ltl
NEVER_CLAIMS=$(LTLS:.ltl=.nvr)

pan:

pan.c: $(TARGET) $(NEVER_CLAIMS)
	$(SPIN) -a $?

absence_afteruntil_lo.nvr:
	$(SPIN) -f '! [] (q && X(!q) && !r -> X (([]!p) || (!p U r)))' > $@ 

clean:
	$(RM) *.nvr pan pan.* $(TARGET).trail

check: pan
	@if [ -f $(TARGET).trail ]; then \
	  rm $(TARGET).trail; \
	fi
	./pan $(PANOPTS) -a
	@if [ -f $(TARGET).trail ]; then \
	  echo "!!! FAILURE !!!"; \
	else \
	  echo "!!! SUCCESS !!!"; \
	fi

trace:
	$(SPIN) -t -p -g $(TARGET)

%.nvr:%.ltl
	$(SPIN) -F $< > $@
