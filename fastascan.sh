############# fastascan.sh v1 ########################################################
#Produce report about .fasta/.fa in a folder

############# Arguments ##############################################################
# 1.Folder X to search the files (dft:curr) 
# 2.N, a number of lines (dft:0)

############ Assign N,X ##############################################################
X=$1
N=$2
echo "******************************* FASTASCAN **************************************"
echo "FASTASCAN produces reports for FASTA files."
echo " "
########### Check for arguments ######################################################
if [[ -z "$X" ]]
then
	X=$(pwd)
	echo "Directory not specified.Creating report for current directory."
elif [[ -n "$X"  && -d "$X" ]]
then
	echo "Creating report for directory $X"
else
	X=$(pwd)
	echo "Input directory does not exist.Creating report for current directory."
fi

echo ""

if [[ -z "$N" ]]
then 
	N=0
	echo "Number of lines not specified.It is automatically set to 0."

elif [[ -n "$N" ]] &&  ((N)) 
then
	echo "Number of lines is set to $N"
else
	N=0
	echo "Input argument N is not numerical.It is automatically set to 0."
fi

############ Report: File counts ######################################################
fastas=$(find "$X" -type f -name "*.fa" -or -name "*.fasta")

echo " "
echo "******************************* Creating report *********************************"
echo " "

if [[ -z "$fastas" ]]
then
	echo "There are no .fa or .fasta files in folder $X"
else
	file_count=$(echo "$fastas" | wc -l) 
	echo "Number of FASTA files= $file_count"
fi

############ Report: Unique FASTA IDs ################################################





