#!/bin/bash
# FUNCTION: Convert csv to (AEM-specific) xliffs
# ARGUMENTS: /
# AUTHOR: Jeremy Lanssiers
# VERSION: 1.0
# REQUIRES: zsh/bash

INPUT="./input.csv"

LANGUAGES=()

INDEX=1 #Index 0 = Key. Index 1+ = Values

while IFS=";" read -a LINE
do
    for ((i=$INDEX; i<${#LINE[@]}; i++))
    do
        LANGUAGES+=($( echo ${LINE[$i]} | tr '[:upper:]' '[:lower:]' | tr -d '\r' ))
    done
done < <( cat "$INPUT" | head -n 1 ) #Input: first row/line only

for LANGUAGE in "${LANGUAGES[@]}"
do
    echo -e "processing $LANGUAGE\n..." #Show progress

    ID=0
    OUTPUT=""
    OUTPUT+="<xliff version=\"1.1\"><file original=\"/libs/cq/i18n/"$LANGUAGE"\" source-language=\"en\" target-language=\""$LANGUAGE"\" datatype=\"x-javaresourcebundle\" tool-id=\"com.day.cq.cq-i18n\" date=\""$(date)"\">\n<header>\n<tool tool-id=\"com.day.cq.cq-i18n\" tool-name=\"Adobe Granite I18N Module\" tool-version=\"5.5.16\" tool-company=\"Adobe Systems Incorporated\"/>\n</header>\n<body>\n" #Head
    
    while IFS=";" read -a LINE
    do
        KEY=${LINE[0]}
        VALUE=$( echo ${LINE[$INDEX]} | tr -d '\r')

        TRANSUNIT="" #Key-Value
        TRANSUNIT+=$( echo -e "<trans-unit id=\""$ID"\">" );
        TRANSUNIT+=$( echo -e "<source xml:lang=\"en\">\n<![CDATA[ "$KEY" ]]>\n</source>" )
        TRANSUNIT+=$( echo -e "<target xml:lang=\""$LANGUAGE"\">\n<![CDATA[ "$VALUE" ]]>\n</target>" )
        TRANSUNIT+=$( echo -e "</trans-unit>" )
        OUTPUT+=$( echo "$TRANSUNIT\n" )

        ID=$((ID+1))
    done < <( cat "$INPUT" | tail -n +2 ) #Input: all rows/lines except for the first

    OUTPUT+="</body>\n</file>\n</xliff>" #Tail

    echo -e $OUTPUT > ./"$LANGUAGE".xliff #Output

    INDEX=$((INDEX+1))

    echo -e "completed $LANGUAGE\n" #Show progress
done



XLIFFS=()

while IFS= read -d $'\0' -r XLIFF
do
    XLIFFS+=($(echo "$XLIFF"))
done < <(find . -name "*xliff" -print0)

OUTPUT=()

for XLIFF in "${XLIFFS[@]}"
do
    OUTPUT=""
    INDEX=1
    LANGUAGE=$( echo $( cat $XLIFF | grep -oP '(?<=(target-language="))..(?=("))' ))

    while IFS=";" read -a LINE
    do
        PATTERN="^<trans\-unit(.*)"
        if [[ $( echo "$LINE" ) =~ $PATTERN ]]
        then
            if [ $XLIFF == ${XLIFFS[0]} ]
            then 
                KEY=$( echo "$LINE" | grep -oP '(?<=(\<source\ xml\:lang\=\"..\"\>\ \<\!\[CDATA\[\ )).*(?=(\ \]\]\>\ \<\/source\>))' )
                OUTPUT[$INDEX]+=$( echo "$KEY;" )
            fi
            
            VALUE=$( echo "$LINE" | grep -oP '(?<=(\<target\ xml\:lang\=\"..\"\>\ \<\!\[CDATA\[\ )).*(?=(\ \]\]\>\ \<\/target\>))' )
            OUTPUT[$INDEX]+=$( echo "$VALUE;" )

            if [[ $XLIFF == ${XLIFFS[-1]} ]]
            then 
                OUTPUT[$INDEX]+=$( echo "\n" )
            fi


            INDEX=$((INDEX+1))
        fi

    done < $XLIFF
    echo -e ${OUTPUT[@]}
done

echo -e ${OUTPUT[@]} > ./output.csv

exit 0