#!/bin/bash

echo Old word:
read old_word
echo New word:
read new_word
echo Path to the folder:
read path

for file in `find $path -type f -name "*"`
do 
        while IFS= read -r line
        do      
        sed -i  "s/${old_word}/${new_word}/g" $file 
        done < "$file"
done 
