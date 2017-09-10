#!/bin/bash
file="main.S"
outfile="outputFile.S"
installPath="../../vmipssoc/src/"
if [ -e "./$file" ]
then
	cp -f $file $installPath$file
elif [ -e "./$outputFile" ]
then
	cp -f $outfile $installPath$file
else
	echo "ASM-MIPS32 file not found, please: $ ./tinypython <input file.py>"
fi