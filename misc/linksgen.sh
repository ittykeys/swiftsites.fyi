#!/bin/bash
INPUT="../html/pages/Links_data.txt"
OUTPUT="../html/pages/links_data.html"
> "$OUTPUT"
html_escape() {
    sed \
        -e 's/&/\&amp;/g' \
        -e 's/"/\&quot;/g' \
        -e "s/'/\&#39;/g" \
        -e 's/</\&lt;/g' \
        -e 's/>/\&gt;/g'
}
get_title() {
url="$1"
curl -Ls -A "Mozilla/5.0" --max-time 10 "$url" 2>/dev/null |
    grep -i -m1 '<title' |
    sed -E 's/.*<title[^>]*>(.*)<\/title>.*/\1/I' |
    tr -d '\n' | sed 's/^[ \t]*//;s/[ \t]*$//'
}
trim() {
    local var="$1"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    echo "$var"
}
mapfile -t lines < <(tr -d '\r' < "$INPUT")
total=${#lines[@]}
for ((i=0; i<total; i++)); do
    line="${lines[$i]}"
    IFS='|' read -r desc link_text url <<< "$line"
    desc="$(trim "$desc")"
    link_text="$(trim "$link_text")"
    url="$(trim "$url")"
    [ -z "$desc" ] && continue
    if [ -z "$link_text" ]; then
        link_text="$(get_title "$url")"
    fi
    [ -z "$link_text" ] && link_text="$url"
    desc_esc=$(echo "$desc" | html_escape)
    link_text_esc=$(echo "$link_text" | html_escape)
    echo "${desc_esc}:" >> "$OUTPUT"
    printf '<a class="alink" href="%s" title="%s" aria-label="%s" target="_blank">%s</a>\n' \
        "$url" "$link_text_esc" "$link_text_esc" "$link_text_esc" >> "$OUTPUT"
    if [ $i -lt $((total-1)) ]; then
        echo "<br>" >> "$OUTPUT"
    fi
done