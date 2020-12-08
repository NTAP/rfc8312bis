.PHONY: apt-update tex2svg-install asciitex-install svgcheck-install patch-toolchain

latest:: apt-update tex2svg-install asciitex-install svgcheck-install patch-toolchain

apt-update:
	-DEBIAN_FRONTEND=noninteractive apt-get update
	-DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends sudo locales cmake build-essential npm

svgcheck-install:
	@hash svgcheck 2>/dev/null || pip3 install svgcheck

tex2svg-install:
	@hash tex2svg 2>/dev/null || npm install -g mathjax-node-cli

asciitex-install:
	sudo locale-gen en_US.UTF-8
	sudo update-locale LANG=en_US.UTF-8
	-git clone --recursive --depth=1 https://github.com/larseggert/asciiTeX.git
	cmake -S asciiTeX -B build -DDISABLE_TESTING=ON
	cmake --build build
	cmake --install build

patch-toolchain:
	-sed -e 's/--font STIX/--font STIX --speech=false/' -i'' /var/lib/gems/2.7.0/gems/kramdown-rfc2629-1.3.17/lib/kramdown-rfc2629.rb
# 	-kramdown-rfc2629 -V
# 	-xml2rfc -V
# 	-npm -v
# 	-tex2svg --version
# 	-svgcheck -V
# 	-asciitex -v

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

