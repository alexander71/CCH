#This script generates the CSpace update SQL for correcting coordinates
#Input file is a tab delimited table with the columns listed below
#Georeferencer and georef_remarks are hardcoded into the printout

#Accumulate results and send to Reseach IT / CSpace periodically

# usage
# perl georef2sql.pl HREC_georef.txt HREC_georef.sql
# input:  HREC_georef.txt
# output: HREC_georef.sql
# Success. 1236 statements output


my $infile  = shift;
my $outfile = shift;

print "input:  $infile\n";
print "output: $outfile\n";

open(IN,"<$infile") || die "could not read from $infile";
open(OUT,">$outfile") || die "could not write to $outfile" ;

Record: while(<IN>){
  $count++;
  chomp;
  @columns=split(/\t/,$_,100);
  unless( $#columns==11-1){
    print ERR "$#columns bad field number $_\n";
  }
  ($csid,
   $aid,
   #$locality,
   $latitude,
   $longitude,
   $georef_source,
   $datum,
   $error_radius,
   $ER_units,
   $Georefer_name,
   $Georef_date,
   $Note
  )=@columns;


#####When not NULLing, all text fields must be enclosed by single quotes
#####Numeric fields, including decimallatitude and decimallongitude, must have the quotes left off

##### Keep these line(s) for future use (removed from the print OUT):
# fieldlocverbatim = '$locality',

  print OUT <<EOP;
\\echo '$aid'
update localitygroup
set vlatitude = '$latitude', 
 vlongitude = '$longitude', 
 decimallatitude = $latitude,
 decimallongitude = $longitude, 
 georefsource = '$georef_source', 
 geodeticdatum = '$datum', 
 coorduncertainty = '$error_radius', 
 coorduncertaintyunit = '$ER_units',
 georefremarks = '$Note',
 georefencedby = '$Georefer_name'
where id in
 (select lg.id FROM
  localitygroup lg, hierarchy h, collectionobjects_common cc
  where lg.id=h.id and h.parentid=cc.id
  and h.pos=0 and h.name='collectionobjects_naturalhistory:localityGroupList'
  and cc.objectnumber in (
'$aid'
 )
);

EOP
}
print "Success. $count statements output\n";
