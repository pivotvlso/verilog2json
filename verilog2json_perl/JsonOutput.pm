package JsonOutput;
use strict;
use warnings;
use utf8;
binmode(STDOUT, ":utf8"); 
use JSON;
use File::Path qw(make_path);
sub write_json;
our %module_json;





sub write_json {
    make_path("sam_आन्तरिककुञ्जीमूल्यरूपम्") unless -d "sam_आन्तरिककुञ्जीमूल्यरूपम्";
    open (JSON_OUTPUT ,">:encoding(UTF-8)","sam_आन्तरिककुञ्जीमूल्यरूपम्/$VerilogParser::module_name.json") or Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Cannot open output file for $VerilogParser::module_name JSON file", -1);
    my $json = to_json(\%module_json, { pretty => 1 });
    $json =~ s/^{//;
    $json =~ s/}$//;
    print JSON_OUTPUT $json, "\n";
    
    close (JSON_OUTPUT);
}
1;