# EndTeX
BibTeX frontend for EndNote bibliographies

EndTeX is an attempt to overcome EndNote's refusal to support 
BibTeX.  It is run instead of BibTeX with the same options.
When run it scans the `.aux` file for bibliography files 
and then looks for a matching file with a `.txt` suffix (eg 
`bibfile.txt`) which it assumes is an EndNote bibliography in 
the correct format.  It then parses it into a BibTeX 
bibliography and finally runs BibTeX.

Type `endtex.sh -h` for more information. 

FILES
-----

`BibTeX Export for EndTeX.ens`
  EndNote export style.

`endtex.sh`
  EndTeX shell script

INSTALLING
----------

(1) Copy the file `BibTeX Export for EndTeX.ens` to your EndNote
    styles directory - Normally `Documents\EndNote\Styles`.  
    
(2) When you export a bibliography save the filename with a
    `.txt` extension and use `BibTeX Export for EndTeX` as the
    output style.
    
(3) Save `endtex.sh` to your `bin/` directory in Cygwin or
    some other Unix like environment (OSX will work as well
    I suppose) and `chmod +x`.
    
(4) When compiling a LaTeX file use EndTeX instead of
    BibTeX, with the same options.  See `endtex.sh -h`
    for more information.
