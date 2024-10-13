Use [patat](https://github.com/jaspervdj/patat) to render the presentation:

    $ wget https://github.com/jaspervdj/patat/releases/download/v0.12.0.1/patat-v0.12.0.1-linux-x86_64.tar.gz
    $ tar xzf patat-v0.12.0.1-linux-x86_64.tar.gz patat-v0.12.0.1-linux-x86_64/patat
    $ patat-v0.12.0.1-linux-x86_64/patat hacktivity-2024-openssh-workshop.patat.md

Use *md2pdf.sh* to generate PDF/HTML versions from Markdown (this script requires *pandoc* and *chromium*):

    $ sudo apt install pandoc chromium
    $ ./md2pdf.sh
