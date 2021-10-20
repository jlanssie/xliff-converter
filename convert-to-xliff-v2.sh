#!/bin/bash
# FUNCTION: Convert csv to xliffs
# ARGUMENTS: /
# AUTHOR: Jeremy Lanssiers
# VERSION: 0.1
# REQUIRES: zsh, bash and a file in the same directory called input.csv with semicolon delimiters, a first column that contains the key string and a second, third, fourth and fifth column for the language values in EN, NL, FR, DE, in that order.

INPUT="./input.csv"

DATE=$(date)

LANGUAGES=()

while IFS=";" read -a A
do
    for ((i=1; i<${#A[@]}; i++))
    do
        LANGUAGES+=($( echo ${A[$i]} | tr '[:upper:]' '[:lower:]'))
    done
done < <(echo $(head -n 1 $INPUT)) #Input

#while IFS=";" read -a A
#do#
#

#done < <(echo $(tail -n +2 "$INPUT"))

INDEX=1
for LANGUAGE in "${LANGUAGES[@]}"
do
    ID=0
    OUTPUT=""
    OUTPUT+="<xliff version=\"1.1\"><file original=\"/libs/cq/i18n/"$LANGUAGE"\" source-language=\"en\" target-language=\""$LANGUAGE"\" datatype=\"x-javaresourcebundle\" tool-id=\"com.day.cq.cq-i18n\" date=\""$DATE"\">\n<header>\n<tool tool-id=\"com.day.cq.cq-i18n\" tool-name=\"Adobe Granite I18N Module\" tool-version=\"5.5.16\" tool-company=\"Adobe Systems Incorporated\"/>\n</header>\n<body>\n"
    
    while IFS=";" read -a A
    do
        KEY=${A[0]}
        VALUE=${A[$INDEX]}

        ITEM=""
        ITEM+=$( echo -e "<trans-unit id=\""$ID"\">\n" );
        ITEM+=$( echo -e "<source xml:lang=\"en\">\n<![CDATA[ "$KEY" ]]>\n</source>\n" )
        ITEM+=$( echo -e "<target xml:lang=\""$LANGUAGE"\">\n<![CDATA[ "$VALUE" ]]>\n</target>\n" )
        ITEM+=$( echo -e "</trans-unit>\n" )
        OUTPUT+=$(echo -e $ITEM)
        OUTPUT+="\n"

        ID=$((ID+1))
    #done < <(echo $(tail -n +2 "$INPUT")) #Input
    done < $INPUT 

    OUTPUT+="</body>\n</file>\n</xliff>"
    echo -e $OUTPUT > ./"$LANGUAGE".xliff #Output

    INDEX=$((INDEX+1))
done

exit 0