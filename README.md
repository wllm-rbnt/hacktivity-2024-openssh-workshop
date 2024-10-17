# Exploring OpenSSH: Hands-On Workshop for Beginners - Hacktivity 2024

The [presentation](https://github.com/wllm-rbnt/hacktivity-2024-openssh-workshop/blob/main/hacktivity-2024-openssh-workshop.patat.md) is written in Markdown.

Use [patat](https://github.com/jaspervdj/patat) to render the slides in your terminal or use the [PDF](https://github.com/wllm-rbnt/hacktivity-2024-openssh-workshop/blob/main/hacktivity-2024-openssh-workshop.pdf)/[HTML](https://github.com/wllm-rbnt/hacktivity-2024-openssh-workshop/blob/main/hacktivity-2024-openssh-workshop.html) versions.

    $ wget https://github.com/jaspervdj/patat/releases/download/v0.12.0.1/patat-v0.12.0.1-linux-x86_64.tar.gz
    $ tar xzf patat-v0.12.0.1-linux-x86_64.tar.gz patat-v0.12.0.1-linux-x86_64/patat
    $ patat-v0.12.0.1-linux-x86_64/patat hacktivity-2024-openssh-workshop.patat.md

Use [md2pdf.sh](https://github.com/wllm-rbnt/hacktivity-2024-openssh-workshop/blob/main/md2pdf.sh) to generate PDF/HTML versions from Markdown (this script requires [Pandoc](https://pandoc.org/) and [Chromium](https://www.chromium.org/Home/)):

    $ sudo apt install pandoc chromium
    $ ./md2pdf.sh

or

    $ sudo dnf install pandoc chromium
    $ ./md2pdf.sh
