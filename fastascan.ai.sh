############# fastascan.ai.sh v1 ########################################################################################################################################################Produce report about .fasta/.fa in a folder
# Usage:
#   ./fastascan.sh [directory] [N]
#     - [directory]: Path to the folder to scan (default: current directory)
#     - [N]: Number of lines to display at the start and end of files (default: 0)
#
# Example:
#   ./fastascan.ai.sh ./data 5
#   ./fastascan.ai.sh
############ Header ################################################################################################################################################################

echo "******************************* FASTASCAN **********************************************************************************************************************************************"
echo ""
echo "FASTASCAN produces reports for FASTA files."
echo ""

########### Check for arguments ########################################################################################################################################################
# Check number of arguments
if [[ $# -gt 2 ]]; then
    echo "Warning: More than two arguments provided. Only the first two (X and N) will be used."
    echo ""
fi

# Set parameters and defaults
X=${1:-$(pwd)}
N=${2:-0}

### Variable X
if [[ "$X" =~ ^[0-9]+$ ]]; then
    N=$1  # First argument is numeric, treat as N
    X=$(pwd)
elif [[ ! -d "$X" ]]; then
    X=$(pwd)
    echo "Input directory does not exist or is invalid. Creating report for current directory."
fi

### Variable N
if [[ ! "$N" =~ ^[0-9]+$ ]]; then
    echo "Input argument N is not numerical. It is automatically set to 0."
    N=0
fi

echo "Search parameters"
echo "Directory: $X"
echo "Number of lines: $N"
echo ""


############ Report: File counts #######################################################################################################################################################

echo "******************************* REPORT *********************************************************************************************************************************************"
echo ""

# Setting fastas variable which contains .fa or .fasta files in specified folder  
fastas=$(find "$X" -type f  -name "*.fa" -or -name "*.fasta")

# Checking if there were no files found, and if this is true print a message for the user
if [[ -z "$fastas" ]]; then
    echo "There are no .fa or .fasta files in folder $X"
else
    # In case .fa or .fasta files are found, count their number and print a message for the user
    file_count=$(echo "$fastas" | wc -l)
    echo "Number of FASTA files: $file_count"

    # Setting Unique variable which first greps all headers, then keeps only the IDs, then sorts them (prerequisite for uniq), then finds unique IDs and counts them
    Unique=$(awk '/^>/ {seen[$1]++} END {print length(seen)}' $fastas)
    
    echo " "
    echo "Number of unique FASTA IDs: $Unique" 
    echo " "
fi

############ File Information ##########################################################################################################################################################

#For each .fa or .fasta file found we are executing a number of commands. 
for file in $fastas
do
	filename=$(basename "$file")
        echo "****************************************************************************************************************************************************************************************"
        echo "File: $filename"
        echo " "
        
        # Check if file is a symbolic link or not and print a message for the user
        
	if [[ -h $file ]]
        then
                echo "Symbolic Link: Yes"
        else
                echo "Symbolic Link: No"
        fi

        # Counting the total number of sequences by grepping the headers (with ">")
        
	seq_count=$(grep -c ">" "$file")
        
	echo " "
        echo "Number of sequences: $seq_count"
        echo " "
        
        # Setting variable total_length:If there are sequences found in the file, then count their total length 
        # by grepping all the lines that don´t contain ">" removing spaces and hidden characters for each line 
        # then summing them. Print a message for the user.
        
	if [[ $seq_count -gt 0 ]]
        then
                total_length=$(grep -v ">" $file | awk '{gsub(/[ -]/, ""); total += length} END {print total}')
                echo "Total sequence length: $total_length"
        fi
        
        # If there are not sequences in the file, print a message for the user and skip this file so no more downstream operations are executed.
        
	if [[ $seq_count -eq 0 ]]
        then
                echo "The file does not contain sequences or is binary.Operations can´t be continued."
                echo ""
                continue
        fi

        echo ""


        # Check if the sequence is Nucleotide --> DNA/RNA  or Amino Acid --> Protein

        # Setting variable first_sequence by grepping all the lines that don´t contain headers in each file then keeping only the 10 first lines in order to check their characters 
        first_sequence=$(grep -v "^>" "$file" | head )

       # (DNA/RNA) sequences

       # Checking that first_sequence contains ONLY valid  characters: A,T,G,C,U,N(unknown) or literal "-" (for alignment files)
       # Adding case insesitive for files that use lowercase to mark regions or features
       
       if echo "$first_sequence" | grep -q -i "^[ATCGU\-]*$" && ! echo "$first_sequence" | grep -q -i "[^ATCGU\-]"
        then
                echo "Sequence type: Nucleotide (DNA/RNA)"

       # Protein sequences (including U=selenocysteine, X=ambiguous residues, O=Pyrolysine, "-"=alignment files)

       # Checking that first_sequence contains ONLY valid characters: all 20 basic amino acids symbols & U,X,O,"-"
       # Case insesitive for files that use lowercase to mark regions or features

        elif echo "$first_sequence" | grep -q -i "^[ACDEFGHIKLMNPQRSTVWYOUX\-]*$" && ! echo "$first_sequence" | grep -q -i "[^ACDEFGHIKLMNPQRSTVWYOUX\-]"
        then
                echo "Sequence type: Protein (Amino Acid)"
        #If it is not protein and not DNA/RNA then we print a message for the user about finding invalid characters
        else
                echo "Can't recognize sequence type.Mixed or invalid characters."
        fi

        echo ""

        # Display file content based on N
        
	if [[ $N -ne 0 ]] 
	then
		total_lines=$(wc -l < "$file")
                if [[ $total_lines -le $((2*N)) ]]
		then
			echo echo "File content:"
			cat "$file"
                else
			echo "Partial file content:"
			head -n "$N" "$file"
			echo "..."
			tail -n "$N" "$file"
                fi
        fi
        echo ""

done
        echo "****************************************************************************************************************************************************************************************"

