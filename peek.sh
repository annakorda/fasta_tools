#Peek.sh version 3

#If statement to set default lines to 3

if [ -z "$2" ];   then
	lines=3;
else 
	lines=$2;
fi

#Count total number of lines and store to a variable

total=$(cat "$1" | wc -l)

#2X lines or less
if [ "$total" -le $(( 2 * lines )) ]; then
	cat "$1";

#Otherwise show first X, ... , last X
else 
	head -n "$lines" "$1";
	echo "...";
	tail -n "$lines" "$1";
fi
