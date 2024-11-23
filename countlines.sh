# Countlines.sh version 1

# Loop through each file provided as an argument
for file in "$@"; do
    
    lines=$(cat "$file" | wc -l)

    # Print file name and number of lines, handling different cases
    if [[ "$lines" -eq 0 ]]; then
        echo "'$file' has zero lines."
    elif [[ "$lines" -eq 1 ]]; then
        echo "'$file' has one line."
    else
        echo "'$file' has $lines lines."
    fi
done
