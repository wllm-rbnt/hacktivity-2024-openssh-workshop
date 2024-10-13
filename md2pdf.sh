#!/bin/bash

document="hacktivity-2024-openssh-workshop"

which pandoc 2>&1 >/dev/null
[ $? -ne 0 ] && echo "pandoc not found" && exit 1

which chromium 2>&1 >/dev/null
[ $? -ne 0 ] && echo "chromium not found" && exit 1

echo "Converting Markdown to HTML using Pandoc"
pandoc -f markdown \
    -t html5 \
    -s "${document}.patat.md" \
    -o "${document}.html" \
    --metadata-file md2pdf_resources/metadata.yml \
    --from markdown+emoji \
    --syntax-definition=schematics.xml \
    --highlight-style=style.theme

[ $? -ne 0 ] && echo "Error during Markdown to HTML conversion" && exit 1
echo -e "\t${document}.html ... done"

echo "Converting HTML to PDF using Chromium"
chromium --headless \
    --disable-gpu \
    --print-to-pdf="${document}.pdf" \
    "${document}.html" \
    --print-to-pdf-no-header
[ $? -ne 0 ] && echo "Error during HTML to PDF conversion" && exit 1
echo -e "\t${document}.pdf ... done"
