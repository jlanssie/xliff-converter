# xliff-converter
A CSV to Xliff converter for Adobe Experience Manager.

## Function

This script converts an input.csv with Key - Value pairs to xliffs (for AEM). The script can handle a csv with a single key column/field and multiple value columns/fields.

The script can also reconvert xliff files (such as the ones outputted by the initial conversion from csv to xliff) back into csv files.

## Usage

### Conversion from CSV to XLIFF

Place a file in the same directory called input.csv with semicolon delimiters.

The first row/line should start with key field and the second (and all fields after) should contain iso-languages codes, e.g.: key,EN,es,IN,Ch,...

The remaining rows/lines should contain the key string and corresponding languages values (based on the first row/line), e.g. key,EN-value,es-value,IN-value,Ch-value,...

The last row of the input.csv should end with a newline character, i.e. the last line of the input.csv should be empty, otherwise the last row may be skipped by the while loop.

### Conversion from XLIFF to CSV

Place one or more files ending in .xliff in the same directory.

For the script to correctly loop over the file, each trans-unit element should start on a new line.

## Sample files

The csv and xliff files in the repository are samples. The processing script is the .sh file.