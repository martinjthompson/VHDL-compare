#########################
###  DEFINE VARIABLES ###
#########################
set DesignName	"ethernet"
set FamilyName	"SPARTAN3E"
set DeviceName	"XC3S250E"
set PackageName	"VQ100"
set SpeedGrade	"-4"
set TopModule	""
set EdifFile	"ethernet.edf"
if {![file exists $DesignName.ise]} {

project new $DesignName.ise

project set family $FamilyName
project set device $DeviceName
project set package $PackageName
project set speed $SpeedGrade

xfile add $EdifFile
if {[file exists synplicity.ucf]} {
    xfile add synplicity.ucf
}

project set "Netlist Translation Type" "Timestamp"
project set "Other NGDBuild Command Line Options" "-verbose"
project set "Generate Detailed MAP Report" TRUE

project close
}


file delete -force $DesignName\_xdb

project open $DesignName.ise

process run "Implement Design" -force rerun_all

project close

