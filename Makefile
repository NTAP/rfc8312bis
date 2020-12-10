.PHONY: apt-update tex2svg asciitex svgcheck

latest:: tex2svg asciitex svgcheck

ASCIITEX := $(shell which asciitex)
SVGCHECK := $(shell which svgcheck)
TEX2SVG := $(shell which tex2svg)

$(info ${ASCIITEX})
$(info ${SVGCHECK})
$(info ${TEX2SVG})

apt-update:
	DEBIAN_FRONTEND=noninteractive apt-get update

ifeq ($(SVGCHECK),)
svgcheck:
	pip3 install svgcheck
else
svgcheck:
endif

ifeq ($(TEX2SVG),)
tex2svg: apt-update
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends npm
	npm install -g mathjax-node-cli
else
tex2svg:
endif

ifeq ($(ASCIITEX),)
asciitex: apt-update
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends cmake build-essential
	git clone --recursive --depth=1 https://github.com/larseggert/asciiTeX.git
	cmake -S asciiTeX -B build -DDISABLE_TESTING=ON
	cmake --build build
	cmake --install build
else
asciitex:
endif

LIBDIR := lib
include $(LIBDIR)/main.mk

$(LIBDIR)/main.mk:
ifneq (,$(shell grep "path *= *$(LIBDIR)" .gitmodules 2>/dev/null))
	git submodule sync
	git submodule update $(CLONE_ARGS) --init
else
	git clone -q --depth 10 $(CLONE_ARGS) \
	    -b main https://github.com/martinthomson/i-d-template $(LIBDIR)
endif

.SECONDARY: draft-eggert-tcpm-rfc8312bis.xml

CFLAGS=-Wall -Wextra -Weverything
tablecode: tablecode.c

clean::
	-rm tablecode 2> /dev/null

