#!/bin/bash 

function determinate {
    if [ $1 = "1" ]; then
       echo Determinate: 1
    else
       echo Determinate: 0
    fi    
}

function begin {
	echo Begin_Message: $1
}

function finish {
	echo Finish_Message: $1
}

function percent {
	echo Progress: $1
}

function url {
	if [ $1 = "0" ]; then
		echo URL: 0
	else
		echo URL: $1
	fi
}