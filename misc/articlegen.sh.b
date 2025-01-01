#!/bin/bash
INPUT_DIR="$1"
if [ -z "$INPUT_DIR" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi
if [ ! -d "$INPUT_DIR" ]; then
    echo "Directory not found: $INPUT_DIR"
    exit 1
fi
for INPUT_FILE in "$INPUT_DIR"/*.ikmd; do
    if [ -f "$INPUT_FILE" ]; then
        OUTPUT_FILE="${INPUT_FILE%.ikmd}.html"
        MOD_DATE=$(date -r "$INPUT_FILE" +"%Y-%m-%dT%H:%M:%S")
        READABLE_MOD_DATE=$(date -r "$INPUT_FILE" +"%B %d %Y %I:%M %p")
        CRE_DATE=$(stat --format='%W' "$INPUT_FILE")
        ISO_CRE_DATE=$( [[ "$CRE_DATE" -ne 0 ]] && date -d @$CRE_DATE +"%Y-%m-%dT%H:%M:%S" || echo "No created date available" )
        READABLE_CRE_DATE=$( [[ "$CRE_DATE" -ne 0 ]] && date -d @$CRE_DATE +"%B %d %Y %I:%M %p" || echo "No created date available" )
        TITLE=""
        ARTICLE_ID=""
        SUBTITLE_IMG=""
        SUBTITLE_CAPTION=""
        SUBTITLE_ALT=""
        AUTHOR_IMG=""
        AUTHOR_URL=""
        AUTHOR_CAPTION=""
        AUTHOR_ALT=""
        DATETIME=""
        CRE_DATETIME=""
        READABLE_DATE=""
        CRE_READABLE_DATE=""
        CONTENT=""
        A_PATH=""
        A_ARIA=""
        while IFS= read -r line || [ -n "$line" ]; do
            case "$line" in
                Title:*) TITLE="${line#Title: }" ;;
                "Article ID:"*) ARTICLE_ID="${line#Article ID: }" ;;
                "Subtitle Image:"*) SUBTITLE_IMG="${line#Subtitle Image: }" ;;
                "Subtitle Caption:"*) SUBTITLE_CAPTION="${line#Subtitle Caption: }" ;;
                "Subtitle Alt:"*) SUBTITLE_ALT="${line#Subtitle Alt: }" ;;
                "Author Image:"*) AUTHOR_IMG="${line#Author Image: }" ;;
                "Author URL:"*) AUTHOR_URL="${line#Author URL: }" ;;
                "Author Caption:"*) AUTHOR_CAPTION="${line#Author Caption: }" ;;
                "Author Alt:"*) AUTHOR_ALT="${line#Author Alt: }" ;;
                Datetime:*)
                    DATETIME="${line#Datetime: }"
                    READABLE_DATE=$(date -d "$DATETIME" +"%B %d %Y %I:%M %p")
                    ;;
                Created:*)
                    CRE_DATETIME="${line#Created: }"
                    CRE_READABLE_DATE=$(date -d "$CRE_DATETIME" +"%B %d %Y %I:%M %p")
                    ;;
                *)
                    case "$line" in
                        ==section==*) CONTENT+="<section>"$'\n' ;;
                        ==/section==*) CONTENT+="</section>"$'\n' ;;
                        ==ul==*) CONTENT+="<ul>"$'\n' ;;
                        ==/ul==*) CONTENT+="</ul>"$'\n' ;;
                        ==li==*) CONTENT+="<li>"$'\n' ;;
                        ==/li==*) CONTENT+="</li>"$'\n' ;;
                        ==blockquote==*) CONTENT+="<blockquote>"$'\n' ;;
                        ==/blockquote==*) CONTENT+="</blockquote>"$'\n' ;;
                        ==br==*) CONTENT+="<br>"$'\n' ;;
                        ==i==*) CONTENT+="<i>"$'\n' ;;
                        ==/i==*) CONTENT+="</i>"$'\n' ;;
                        ==b==*) CONTENT+="<b>"$'\n' ;;
                        ==/b==*) CONTENT+="</b>"$'\n' ;;
                        ==em==*) CONTENT+="<em>"$'\n' ;;
                        ==/em==*) CONTENT+="</em>"$'\n' ;;
                        ==strong==*) CONTENT+="<strong>"$'\n' ;;
                        ==/strong==*) CONTENT+="</strong>"$'\n' ;;
                        ==h1==*) CONTENT+="<h1>"$'\n' ;;
                        ==/h1==*) CONTENT+="</h1>"$'\n' ;;
                        ==h2==*) CONTENT+="<h2>"$'\n' ;;
                        ==/h2==*) CONTENT+="</h2>"$'\n' ;;
                        ==h3==*) CONTENT+="<h3>"$'\n' ;;
                        ==/h3==*) CONTENT+="</h3>"$'\n' ;;
                        ==h4==*) CONTENT+="<h4>"$'\n' ;;
                        ==/h4==*) CONTENT+="</h4>"$'\n' ;;
                        ==h5==*) CONTENT+="<h5>"$'\n' ;;
                        ==/h5==*) CONTENT+="</h5>"$'\n' ;;
                        ==h6==*) CONTENT+="<h6>"$'\n' ;;
                        ==/h6==*) CONTENT+="</h6>"$'\n' ;;
                        ==p==*) CONTENT+="<p>"$'\n' ;;
                        ==/p==*) CONTENT+="</p>"$'\n' ;;
                        ==hr==*) CONTENT+="<hr>"$'\n' ;;
                        ==table==*) CONTENT+="<table>"$'\n' ;;
                        ==/table==*) CONTENT+="</table>"$'\n' ;;
                        ==tr==*) CONTENT+="<tr>"$'\n' ;;
                        ==/tr==*) CONTENT+="</tr>"$'\n' ;;
                        ==th==*) CONTENT+="<th>"$'\n' ;;
                        ==/th==*) CONTENT+="</th>"$'\n' ;;
                        ==td==*) CONTENT+="<td>"$'\n' ;;
                        ==/td==*) CONTENT+="</td>"$'\n' ;;
                        ==figure==*) CONTENT+="<figure>"$'\n' ;;
                        ==/figure==*) CONTENT+="</figure>"$'\n' ;;
                        ==figcaption==*) CONTENT+="<figcaption>"$'\n' ;;
                        ==/figcaption==*) CONTENT+="</figcaption>"$'\n' ;;
                        ==imgpath==*) CONTENT+="<!--#set var="FILE_PATH" value='${line#imgpath: }'-->"$'\n' ;;
                        ==webpimg==*) CONTENT+="<img src='data:image/webp;base64,<!--#exec cgi="../misc/base64.sh" -->' title='${line#webpimg: }' alt='${line#webpimg: }'>"$'\n' ;;
                        ==svgimg==*) CONTENT+="<img src='data:image/svg+xml;base64,<!--#exec cgi="../misc/base64.sh" -->' title='${line#svgimg: }' alt='${line#svgimg: }'>"$'\n' ;;
                        "apath:"*) A_PATH="${line#apath:}" ;;
                        "aria:"*) A_ARIA="${line#aria:}" ;;
                        ==a==*) CONTENT+="<a href='$A_PATH' title='$A_ARIA' aria-label='$A_ARIA' target='_blank'>"$'\n' ;;
                        ==/a==*) CONTENT+="</a>"$'\n' ;;
                        ==span==*) CONTENT+="<span>"$'\n' ;;
                        ==/span==*) CONTENT+="</span>"$'\n' ;;
                        ==code==*) CONTENT+="<code>"$'\n' ;;
                        ==/code==*) CONTENT+="</code>"$'\n' ;;
                        ==pre==*) CONTENT+="<pre>"$'\n' ;;
                        ==/pre==*) CONTENT+="</pre>"$'\n' ;;
                        ==hr==*) CONTENT+="<hr>"$'\n' ;;
                        ==div==*) CONTENT+="<div>"$'\n' ;;
                        ==/div==*) CONTENT+="</div>"$'\n' ;;
                        ==inta==*) CONTENT+="<a href='$A_PATH' title='$A_ARIA' aria-label='$A_ARIA'>"$'\n' ;;
                        ==/inta==*) CONTENT+="</a>"$'\n' ;;
                        *)
                            if [[ -n "$line" ]]; then
                                    CONTENT+="${line}"$'\n'
                            fi
                            ;;
                    esac
                    ;;
            esac
        done < "$INPUT_FILE"
        if [ -z "$DATETIME" ]; then
            DATETIME="$MOD_DATE"
            READABLE_DATE="$READABLE_MOD_DATE"
        fi
        if [ -z "$CRE_DATETIME" ]; then
            CRE_DATETIME="$ISO_CRE_DATE"
            CRE_READABLE_DATE="$READABLE_CRE_DATE"
        fi
        cat <<EOF > "$OUTPUT_FILE"
<article id="$ARTICLE_ID">
    <header>
        <h2>
            $TITLE
            <figure style="float: right;">
                <!--#set var="FILE_PATH" value="$SUBTITLE_IMG"-->
                <img src='data:image/webp;base64,<!--#exec cgi="../misc/base64.sh" -->' title="$SUBTITLE_CAPTION" alt="$SUBTITLE_ALT" />
                <figcaption class="hidden">$SUBTITLE_CAPTION</figcaption>
            </figure>
        </h2>
        <figure>
            <a href="$AUTHOR_URL" target="_blank">
                <!--#set var="FILE_PATH" value="$AUTHOR_IMG"-->
                <img src='data:image/svg+xml;base64,<!--#exec cgi="../misc/base64.sh" -->' title="$AUTHOR_CAPTION" alt="$AUTHOR_ALT" />
                $AUTHOR_CAPTION
            </a>
            <figcaption class="hidden">$AUTHOR_CAPTION</figcaption>
        </figure>
        <time datetime="$CRE_DATETIME">Published: $READABLE_CRE_DATE</time>
    </header>
    $CONTENT
    <time style="margin: var(--spacing) 0;" datetime="$DATETIME">Updated: $READABLE_DATE</time>
</article>
EOF
    fi
done
TIMESTAMP_FILE="last_updated.txt"
CURRENT_TIME=$(date +"%B %d %Y %I:%M %p")
echo "$CURRENT_TIME" > "$TIMESTAMP_FILE"