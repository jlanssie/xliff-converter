# xliff-converter
A CSV to Xliff converter.

## Function

This script converts an input.csv with Key - Value pairs to xliffs (for AEM). The script can handle a csv with a single key column/field and multiple value columns/fields.

## Usage

Place a file in the same directory called input.csv with semicolon delimiters.

The first row/line should start with key field and the second (and all fields after) should contain iso-languages codes, e.g.: key,EN,es,IN,Ch,...

The remaining rows/lines should contain the key string and corresponding languages values (based on the first row/line), e.g. key,EN-value,es-value,IN-value,Ch-value,...

The last row of the input.csv should end with a newline character, i.e. the last line of the input.csv should be empty, otherwise the last row may be skipped by the while loop.

## Sample files

The csv and xliff files in the repository are samples. The processing script is the .sh file.