#!/bin/sh -e

newName="$1"
newId="$2"
newDomain="$3"
newCompanyName="$4"

if [ $# -ne 4 ]
then
    echo "Usage:"
    echo "$0 ByeWorld byeworld com.mycoolcompany \"My Cool Company\""
    exit 1
fi

# Determine which sed to use
if [ "$(which gsed)" = "" ]
then
    SED=sed
else
    SED=gsed
fi

# Rename files that have the application name in them

while true
do
    renameFile="$(find . -name HelloWorld\* | head -1)"

    if [ "$renameFile" = "" ]
    then
       break;
    fi

    newFilename="$(echo "$renameFile" | $SED "s%HelloWorld%$newName%")"

    mv "$renameFile" "$newFilename"
done

# Replace file names that have the application identifier in the name

while true
do
    renameFile="$(find . -name \*helloworld\* | head -1)"

    if [ "$renameFile" = "" ]
    then
       break;
    fi

    newFilename="$(echo "$renameFile" | $SED "s%helloworld%$newId%")"

    mv "$renameFile" "$newFilename"
done

# Replace application name in contents

find . -type f | while read i
do
    $SED -i -e "s%HelloWorld%$newName%g" "$i"
done

# Replace application id in contents

find . -type f | while read i
do
    $SED -i -e "s%helloworld%$newId%g" "$i"
done

# Replace domain in contents

find . -type f | while read i
do
    $SED -i -e "s%MyCompany%$newDomain%g" "$i"
done

# Replace company in contents

find . -type f | while read i
do
    $SED -i -e "s%My Company%$newCompanyName%g" "$i"
done
