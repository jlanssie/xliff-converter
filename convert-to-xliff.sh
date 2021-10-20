#!/bin/bash
# FUNCTION: Convert csv to (AEM-specific) xliffs
# ARGUMENTS: /
# AUTHOR: Jeremy Lanssiers
# VERSION: 1.0
# REQUIRES: zsh/bash and a file in the same directory called input.csv with semicolon delimiters, a first column that contains the key string and one or mulitple columns with values. The first row should contain the languages, e.g.: key;EN;ES;CH;IN

INPUT="./input.csv"
cat $INPUT | tail -n +2

LANGUAGES=()

INDEX=1 #Index 0 = Key. Index 1+ = Values

while IFS=";" read -a A
do
    for ((i=$INDEX; i<${#A[@]}; i++))
    do
        LANGUAGES+=($( echo ${A[$i]} | tr '[:upper:]' '[:lower:]' | tr -d '\r' ))
    done
done < <(echo $( cat $INPUT | head -n 1 ) ) #Input

for LANGUAGE in "${LANGUAGES[@]}"
do
    echo -e "processing $LANGUAGE\n..."

    ID=0
    OUTPUT=""
    OUTPUT+="<xliff version=\"1.1\"><file original=\"/libs/cq/i18n/"$LANGUAGE"\" source-language=\"en\" target-language=\""$LANGUAGE"\" datatype=\"x-javaresourcebundle\" tool-id=\"com.day.cq.cq-i18n\" date=\""$(date)"\">\n<header>\n<tool tool-id=\"com.day.cq.cq-i18n\" tool-name=\"Adobe Granite I18N Module\" tool-version=\"5.5.16\" tool-company=\"Adobe Systems Incorporated\"/>\n</header>\n<body>\n"
    
    while IFS=";" read -a A
    do
        KEY=${A[0]}
        VALUE=$( echo ${A[$INDEX]} | tr -d '\r')

        if [ $ID -ne 0 ] #Skip the first row
        then
            ITEM=""
            ITEM+=$( echo -e "<trans-unit id=\""$ID"\">" );
            ITEM+=$( echo -e "<source xml:lang=\"en\">\n<![CDATA[ "$KEY" ]]>\n</source>" )
            ITEM+=$( echo -e "<target xml:lang=\""$LANGUAGE"\">\n<![CDATA[ "$VALUE" ]]>\n</target>" )
            ITEM+=$( echo -e "</trans-unit>" )
            OUTPUT+=$( echo "$ITEM\n" )
        fi

        ID=$((ID+1))
    #done < <(echo -e $( cat $INPUT | tail -n +2 ) ) #Input
    done < $INPUT 

    OUTPUT+="</body>\n</file>\n</xliff>"

    echo -e $OUTPUT > ./"$LANGUAGE".xliff #Output

    INDEX=$((INDEX+1))

    echo -e "completed $LANGUAGE\n"
done

exit 0