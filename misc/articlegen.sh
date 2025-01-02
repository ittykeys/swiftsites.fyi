#!/bin/bash
START_TIME=$(date +%s%3N)
INPUT_DIR="$1"
if [[ -z "$INPUT_DIR" ]]; then
    echo "Usage: $0 <directory>"
    exit 1
fi
if [[ ! -d "$INPUT_DIR" ]]; then
    echo "Directory not found: $INPUT_DIR"
    exit 1
fi
convert_to_html_tag() {
    local line="$1"
    if [[ "$line" =~ ==([a-zA-Z0-9]+)== ]]; then
        echo "<${BASH_REMATCH[1]}>"
    elif [[ "$line" =~ ==/([a-zA-Z0-9]+)== ]]; then
        echo "</${BASH_REMATCH[1]}>"
    fi
}
process_file() {
    local input_file="$1"
    local output_file="${input_file%.ikmd}.html"
    local creation_date=$(stat --format='%W' "$input_file")
    local iso_creation_date readable_creation_date
    iso_creation_date=$(date -d @$creation_date +"%Y-%m-%dT%H:%M:%S")
    readable_creation_date=$(date -d @$creation_date +"%B %d %Y %I:%M %p")
    local title="" article_id="" subtitle_img="" subtitle_caption="" subtitle_alt=""
    local author_img="" author_url="" author_caption="" author_alt=""
    local cre_datetime="" cre_readable_date="" content=""
    while IFS= read -r line || [[ -n "$line" ]]; do
        case "$line" in
            Title:*) title="${line#Title: }" ;;
            "Article ID:"*) article_id="${line#Article ID: }" ;;
            "Subtitle Image:"*) subtitle_img="${line#Subtitle Image: }" ;;
            "Subtitle Caption:"*) subtitle_caption="${line#Subtitle Caption: }" ;;
            "Subtitle Alt:"*) subtitle_alt="${line#Subtitle Alt: }" ;;
            "Author Image:"*) author_img="${line#Author Image: }" ;;
            "Author URL:"*) author_url="${line#Author URL: }" ;;
            "Author Caption:"*) author_caption="${line#Author Caption: }" ;;
            "Author Alt:"*) author_alt="${line#Author Alt: }" ;;
            Published:*)
                cre_datetime="${line#Published: }"
                iso_creation_date=$(date -d "$cre_datetime" +"%Y-%m-%dT%H:%M:%S")
                cre_readable_date=$(date -d "$cre_datetime" +"%B %d %Y %I:%M %p")
                ;;
            *)
                case "$line" in
                    apath:*) a_path="${line#apath:}" ;;
                    aria:*) a_aria="${line#aria:}" ;;
                    #imgpath:*) IMG_PATH="${line#imgpath:}" ;;
                    #webpimg:*) WEBP_IMG="${line#webpimg:}" ;;
                    #svgimg:*) SVG_IMG="${line#svgimg:}" ;;
                    ==a==*) content+="<a class='alink' href='$a_path' title='$a_aria' aria-label='$a_aria' target='_blank'>"$'\n\t' ;;
                    ==/a==*) content+="</a>"$'\n\t' ;;
                    ==imgpath==*) content+="<!--#set var="FILE_PATH" value='${line#imgpath: }'-->"$'\n\t' ;;
                    ==webpimg==*) content+="<img src='data:image/webp;base64,<!--#exec cgi="../misc/base64.sh" -->' title='${line#webpimg: }' alt='${line#webpimg: }'>"$'\n\t' ;;
                    ==svgimg==*) content+="<img src='data:image/svg+xml;base64,<!--#exec cgi="../misc/base64.sh" -->' title='${line#svgimg: }' alt='${line#svgimg: }'>"$'\n\t' ;;
                    ==inta==*) content+="<a class='alink' href='$a_path' title='$a_aria' aria-label='$a_aria'>"$'\n\t' ;;
                    ==/inta==*) content+="</a>"$'\n\t' ;;
                    *)
                        tag_html=$(convert_to_html_tag "$line")
                        if [ -n "$tag_html" ]; then
                            content+="$tag_html"$'\n\t'
                        elif [[ -n "$line" ]]; then
                            content+="$line"$'\n\t'
                        fi
                        ;;
                esac
                ;;
        esac
    done < "$input_file"
    cat <<EOF > "$output_file"
<article id="$article_id">
    <header>
        <h2>
            $title
            <figure style="float: right;">
                <!--#set var="FILE_PATH" value="$subtitle_img"-->
                <img src='data:image/webp;base64,<!--#exec cgi="../misc/base64.sh" -->' title="$subtitle_caption" alt="$subtitle_alt" />
                <figcaption class="hidden">$subtitle_caption</figcaption>
            </figure>
        </h2>
        <figure>
            <a href="$author_url" target="_blank">
                <!--#set var="FILE_PATH" value="$author_img"-->
                <img src='data:image/svg+xml;base64,<!--#exec cgi="../misc/base64.sh" -->' title="$author_caption" alt="$author_alt" />
                $author_caption
            </a>
            <figcaption class="hidden">$author_caption</figcaption>
        </figure>
        <time datetime="$iso_creation_date">$cre_readable_date</time>
    </header>
    $content
</article>
EOF
}
for input_file in "$INPUT_DIR"/*.ikmd; do
    [[ -f "$input_file" ]] && process_file "$input_file"
done
echo "$(date +"%B %d %Y %I:%M %p")" > "$INPUT_DIR/../misc/last_updated.txt"
END_TIME=$(date +%s%3N)
EXECUTION_TIME=$((END_TIME - START_TIME))
echo "Execution time: $EXECUTION_TIME milliseconds"