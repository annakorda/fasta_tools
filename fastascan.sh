############# fastascan.sh v3 ##########################################################################################################################################################
#Produce report about .fasta/.fa in a folder

############# Arguments ################################################################################################################################################################
# 1.Folder X to search the files (dft:curr) 
# 2.N, a number of lines (dft:0)

############ Assign N,X ################################################################################################################################################################
X=$1
N=$2
echo "******************************* FASTASCAN **********************************************************************************************************************************************"
echo ""
echo "FASTASCAN produces reports for FASTA files."
echo ""
########### Check for arguments ########################################################################################################################################################

# Check number of arguments
if [[ $# -gt 2 ]]
then
    echo "Warning: More than two arguments provided. Only the first two (X and N) will be used."
    echo ""
fi


### Variable X
# Check if variable X is set, if not set it to current folder
if [[ -z "$X" ]]
then
        X=$(pwd)
        echo "Directory not specified.Creating report for current directory."
# If variable X is set and is a directory, we create report for this directory
elif [[ -n "$X"  && -d "$X" ]]
then
        echo "Creating report for directory $X"
# If X is numeric which means user didn't provide folder, but wants to provide number of lines, X is set to current directory and N becomes the first argument
elif ((X))
then
        X=$(pwd)
        N=$1
        echo  "Directory not specified.Creating report for current directory."
# If variable X is set and is a directory, we create report for this directory
elif [[ -n "$X"  && -d "$X" ]]
then
        echo "Creating report for directory $X"
# If X is numeric which means user didn't provide folder, but wants to provide number of lines, X is set to current directory and N becomes the first argument
elif ((X))
then
        X=$(pwd)
        N=$1
        echo  "Directory not specified.Creating report for current directory."
# In all other cases X is set to something but is not a directory or a number, we set default again and print this message in case the user did a mistake
else
        X=$(pwd)
        echo "Input directory does not exist.Creating report for current directory."
fi

echo ""



### Variable N
# Check if variable N is set, if not set it to 0
if [[ -z "$N" ]]
then
        N=0
        echo "Number of lines not specified.It is automatically set to 0."
# If variable N is set and is numeric, we create report for this N
elif [[ -n "$N" ]] &&  ((N))
then
        echo "Number of lines is set to $N"
# In all other cases N is set to something but not numeric, we ser N=0 and print a warning message in case user did a mistake
else
        N=0
        echo "Input argument N is not numerical.It is automatically set to 0."
fi

############ Report: File counts #######################################################################################################################################################

# Some headers and spaces for the report to look good
echo " "
echo "******************************* REPORT *********************************************************************************************************************************************"
echo ""

# Setting fastas variable which contains .fa or .fasta files in specified folder  
fastas=$(find "$X" -type f -name "*.fa" -or -name "*.fasta")

# Checking if there were no files found, and if this is true print a message for the user
if [[ -z "$fastas" ]]
then
        echo "There are no .fa or .fasta files in folder $X"
# In case .fa or .fasta files are found, count their number and print a message for the user
else
        file_count=$(echo "$fastas" | wc -l)
        echo "Number of FASTA files: $file_count"
fi

############ Report: Unique FASTA IDs ##################################################################################################################################################
#Setting Unique variable which first greps all headers, then keeps only the IDs, then sorts them (prerequisite for uniq), then finds unique IDs and counts them
Unique=$(grep -h ">" $fastas | awk -F' ' '{print $1}'| sort | uniq -c | wc -l)
echo " "
echo "Number of unique FASTA IDs: $Unique" 

############ File Information ##########################################################################################################################################################
echo " "
#For each .fa or .fasta file found we are executing a number of commands. 
for file in $fastas
do
        echo "****************************************************************************************************************************************************************************************"
        echo "File: $file"
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

       # Check for Nucleotide (DNA/RNA) sequences
       # Checking that first_sequence contains ONLY valid  characters: A,T,G,C,U, or literal "-" (for alignment files)
       # Backslash \ in \- because otherwise it will understand it as space 
        if echo "$first_sequence" | grep -q  "^[ATCGU\-]*$" && ! echo "$first_sequence" | grep -q "[^ATCGU\-]"
        then
                echo "Sequence type: Nucleotide (DNA/RNA)"

       # Check for Protein sequences (including U=selenocysteine, X=ambiguous residues, O=Pyrolysine, "-"=alignment files)
       # Checking that first_sequence contains ONLY valid characters: all 20 basic amino acids symbols & U,X,O,"-"
        elif echo "$first_sequence" | grep -q  "^[ACDEFGHIKLMNPQRSTVWYOUX\-]*$" && ! echo "$first_sequence" | grep -q "[^ACDEFGHIKLMNPQRSTVWYOUX\-]"
        then
                echo "Sequence type: Protein (Amino Acid)"
        #If it is not protein and not DNA/RNA then we print a message for the user about finding invalid characters
        else
                echo "Can't recognize sequence type.Mixed or invalid characters."
        fi

        echo ""

        # Display file content based on N
        # If N is not equal to zero do the following operations
        if [[ $N -ne 0 ]]
        then
                #If total lines are < or equal to 2N print all file content
                total_lines=$(cat $file | wc -l)
                if [[ $total_lines -le $((2*N)) ]]
                then
                        echo "File content:"
                        cat $file
                # Otherwise print N first lines, ..., N last lines
                else
                        echo "Partial file content:"
                        head -n $N $file
                        echo ...
                        tail -n $N $file
                fi
        #If N is zero skip this step
        else
                continue
        fi
        echo ""

done
        echo "****************************************************************************************************************************************************************************************"

