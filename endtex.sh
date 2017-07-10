#!/bin/sh

echo EndTeX - BibTeX frontend for EndNote bibliographies

# If there is atleast one argument
if [ ! -z $1 ]; then
    if [ $1 = "-h" -o $1 = "--help" ]; then
	cat <<EOF

 SYNOPSIS

      endtex [BibTeX options] auxname[.aux]

 DESCRIPTION

      EndTeX is an attempt to overcome EndNote's refusal to
      support BibTeX.  It scans the file auxname.aux for
      bibliography files and then looks for a matching file
      called bibfile.txt which it assumes is an EndNote
      bibliography in the correct format.

      The format for EndNote bibliographies is the standard
      BibTeX export format but with the keys changed to

           @misc{|AuthorYear|,

      You can change the other parts of the export format if
      you want as this script does not modify them (except to
      escape special characters).

      The citation keys are then changed to the form
      'einstein1905' (ie, the surname of the first author)
      and the modified bibliography is written to the file
      "bibfile.bib".  The author name in the citation key is
      transliterated to US-ASCII.  If there are multiple 
      articles by the same author in the same year then the 
      keys are 'einstein1905', 'einstein1905b' etc.  There is 
      no 'einstein1905a' because that would (it seems to me) 
      need a second pass of the file.

      NB:
         Any existing BibTeX bibliography file will be
         automatically overwritten.  EndTeX assumes that if
         if there is a matching .txt file then the .bib file
         was created from it.

      Finally, BibTeX is called with all of the arguments to
      this script passed unmodified to it.

 OPTIONS

      -h, --help
            Print this help followed by the BibTeX help.

      No other options are used by this script, they are just 
      passed unchanged to BibTeX.

 SEE ALSO

      bibtex(1).

 TODO

      Need to parse the EndNote bibliography file to escape the 
      following special characters:
              {	\{
              }	\}

      Apparently BibTeX has a 5000 character limit on fields so we
      need to truncate long fields.  As a work around don't export
      abstracts etc into the bibliography.

 CAVEATS

      I have no real knowledge of how BibTeX works, so this may not
      function properly with some LaTeX files.

      Escaping the backslash character kills any LaTeX that might
      be in your citation, such as '\url{}', so don't use any.

      While I have tried to use only POSIX code I have had to
      use the '//TRANSLIT' option to iconv.  I don't know how
      portable that is.

 AUTHOR

      Matthew Parry, Australian National University,
      <matthew@mparry.com.au>.
						      
 BibTeX help follows...

EOF
	
    else
    
# Find the last argument, which should be the name of the aux file.
eval auxfile="\${$#}"

# With BibTeX you don't have to add the ".aux" to the filename
# so we need to add it if it is missing.
case "$auxfile" in
    *".aux") ;;
    *) auxfile="$auxfile.aux";;
esac

# Check if the aux file actually exists
if [ ! -f "$auxfile" ]; then
    echo "$auxfile" not found!
    exit
fi

# Scan the auxfile for the bibliography files used.
echo Reading "$auxfile"
filelist=$(awk 'BEGIN{FS="[{}]";}/^\\bibdata/ { print $2;}' "$auxfile")

# The files are separated by a comma so change that to a newline so that
# the read builtin can be used to get one file at a time.
endnotefiles="$(echo "$filelist"|sed 's/,/\n/g')"

# For each bibliography file listed in the aux file
echo "$endnotefiles" | while read FL; do
    printf '\t%s: ' "$FL"

    # Check if there is a "$FL.txt" file and if so assume that it is an
    # EndNote bibliography with keys in the form "@misc{|AuthorYear|,"
    if [ -f "$FL.txt" ]; then
	if [ -f "$FL.bib" ]; then
	    printf 'Replacing %s.bib ... ' "$FL"
	else
	    printf 'Creating %s.bib ... ' "$FL"
	fi

	# create citation keys of the form \cite{parry2017} and write the
	# modified version of the bibliography to "$FL.bib"
	awk -f- "$FL.txt" > "$FL.bib" <<EOF 
BEGIN{
	FS="[" FS "{,]";
}

/\@.+\{/ {
	 # Convert first author's surname from utf-8 to us-ascii
	 cmd="echo " \$2 " | iconv -c -f UTF-8 -t US-ASCII//TRANSLIT ";
	 cmd | getline FIRSTAUTH;
	 close(cmd);

	 REF = tolower(FIRSTAUTH);

	 YR=substr(\$0,length(\$0)-5,4);
	 if(YR~/^[0-9]+/){ # Check if there is a year listed
		REF=REF YR;
	 };

	 # Check if the key has already been used and change this
	 # one to 'parry2017b' etc if it has been.
	 if(keys[REF] == ""){ # If we don't already have this key
	 	keys[REF] = 1;
	 }else{ 
	 	keys[REF] = keys[REF] + 1;
		REF = REF sprintf("%c", keys[REF] + 96);
	 }

	 print \$1 "{" REF ",";
	 next;
}

{
	# Replace special characters with escaped characters.
	gsub("\\\\\\\\", "\\\\textbackslash ");
	gsub("\\\\#", "\\\\#");
	gsub("\\\\$", "\\\\$");
	gsub("\\\\%", "\\\\%");
	gsub("\\\\&", "\\\\\\\\&");
	gsub("\\\\_", "\\\\_");
	gsub("\\\\~", "\\\\~{}");
	gsub("\\\\^", "\\\\^{}");

   	print \$0;
}

EOF
	printf 'Done.\n'
    else
	printf 'No .txt file - Ignored.\n'
    fi
done

fi # If [ $1 = "-h" -o $1 = "--help" ]; ie, skip the processing if
# the help options were given.
    
# Now run BibTeX with all of the arguments that were passed to EndTeX.
/usr/bin/bibtex "${@:1}"

else # if [ ! -z $1 ]; then
    echo No arguments!
fi
