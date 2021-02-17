# CUBIC for Fast Long-Distance Networks

This is the working area for the individual Internet-Draft, "CUBIC for Fast Long-Distance Networks".

* [Editor's Copy](https://NTAP.github.io/rfc8312bis/#go.draft-eggert-tcpm-rfc8312bis.html)
* [Individual Draft](https://tools.ietf.org/html/draft-eggert-tcpm-rfc8312bis)
* [Compare Editor's Copy to Individual Draft](https://NTAP.github.io/rfc8312bis/#go.draft-eggert-tcpm-rfc8312bis.diff)

## Building the Draft

The easiest way to build formatted text and HTML versions of this draft is to use the
[Docker i-d-toolchain](https://github.com/larseggert/i-d-toolchain).

```sh
docker run \
       --pull always \
       -v $(pwd):/id:delegated \
       --cap-add=SYS_ADMIN \
       docker.pkg.github.com/larseggert/i-d-toolchain/i-d-toolchain:latest \
       kdrfc -h -3 /id/draft-eggert-tcpm-rfc8312bis.md
```
Alternatively, formatted text and HTML versions of the draft can be built using `make`.

```sh
$ make
```

This requires that you have the necessary software installed.  In addition to the requirements
[described here](https://github.com/martinthomson/i-d-template/blob/master/doc/SETUP.md),
you also need to have [svgcheck](https://pypi.org/project/svgcheck/), 
[tex2svg](https://github.com/mathjax/mathjax-node-cli) and 
[asciitex](https://github.com/larseggert/asciiTeX) installed.


## Contributing

See the
[guidelines for contributions](https://github.com/NTAP/rfc8312bis/blob/main/CONTRIBUTING.md).
