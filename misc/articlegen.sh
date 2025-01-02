#!/bin/bash
START_TIME=$(date +%s%3N)
INPUT_DIR="$1"
if [ -z "$INPUT_DIR" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi
if [ ! -d "$INPUT_DIR" ]; then
    echo "Directory not found: $INPUT_DIR"
    exit 1
fi
convert_to_html_tag() {
    local line="$1"
    if [[ "$line" =~ ==([a-zA-Z0-9]+)== ]]; then
        tag="${BASH_REMATCH[1]}"
        echo "<$tag>"
    elif [[ "$line" =~ ==/([a-zA-Z0-9]+)== ]]; then
        tag="${BASH_REMATCH[1]}"
        echo "</$tag>"
    fi
}
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
                    if date -d "$CRE_DATETIME" &> /dev/null; then
                        ISO_CRE_DATE=$(date -d "$CRE_DATETIME" +"%Y-%m-%dT%H:%M:%S")
                        CRE_READABLE_DATE=$(date -d "$CRE_DATETIME" +"%B %d %Y %I:%M %p")
                    else
                        ISO_CRE_DATE="No created date available"
                        CRE_READABLE_DATE="No created date available"
                    fi
                    ;;
                *)
                    case "$line" in
                        apath:*) A_PATH="${line#apath:}" ;;
                        aria:*) A_ARIA="${line#aria:}" ;;
                        #imgpath:*) IMG_PATH="${line#imgpath:}" ;;
                        #webpimg:*) WEBP_IMG="${line#webpimg:}" ;;
                        #svgimg:*) SVG_IMG="${line#svgimg:}" ;;
                        ==a==*) CONTENT+="<a class='alink' href='$A_PATH' title='$A_ARIA' aria-label='$A_ARIA' target='_blank'>"$'\n\t' ;;
                        ==/a==*) CONTENT+="</a>"$'\n\t' ;;
                        ==imgpath==*) CONTENT+="<!--#set var="FILE_PATH" value='${line#imgpath: }'-->"$'\n\t' ;;
                        ==webpimg==*) CONTENT+="<img src='data:image/webp;base64,<!--#exec cgi="../misc/base64.sh" -->' title='${line#webpimg: }' alt='${line#webpimg: }'>"$'\n\t' ;;
                        ==svgimg==*) CONTENT+="<img src='data:image/svg+xml;base64,<!--#exec cgi="../misc/base64.sh" -->' title='${line#svgimg: }' alt='${line#svgimg: }'>"$'\n\t' ;;
                        ==inta==*) CONTENT+="<a class='alink' href='$A_PATH' title='$A_ARIA' aria-label='$A_ARIA'>"$'\n\t' ;;
                        ==/inta==*) CONTENT+="</a>"$'\n\t' ;;
                        *)
                            tag_html=$(convert_to_html_tag "$line")
                            if [ -n "$tag_html" ]; then
                                CONTENT+="$tag_html"$'\n\t'
                            elif [[ -n "$line" ]]; then
                                CONTENT+="$line"$'\n\t'
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
        CONTENT=${CONTENT%$'\n\t'}
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
        <time datetime="$ISO_CRE_DATE">Created: $CRE_READABLE_DATE</time>
    </header>
    $CONTENT
    <time style="margin: var(--spacing) 0;" datetime="$DATETIME">Modified: $READABLE_DATE</time>
</article>
EOF
    fi
done
TIMESTAMP_FILE="$INPUT_DIR/../misc/last_updated.txt"
CURRENT_TIME=$(date +"%B %d %Y %I:%M %p")
echo "$CURRENT_TIME" > "$TIMESTAMP_FILE"
END_TIME=$(date +%s%3N)
EXECUTION_TIME=$((END_TIME - START_TIME))
echo "Execution time: $EXECUTION_TIME milliseconds"