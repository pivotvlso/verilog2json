#This script created Verilog to JSON for schematic drawing
#perl verilog2json.pl <Verilog_module>
no locale;
use strict;
use warnings;
use utf8;
use FindBin;
use lib "$FindBin::Bin/verilog2json_perl";   # tells Perl where to find .pm files

use AlwaysBlock;
use CheckExpr;
use CheckType;
use AlwaysBlockElseIf;
use AlwaysBlockElseOnly;
use AlwaysBlockIf;
use InitialBlock;
use CombCkt;
use InitialBlockElseIf;
use InitialBlockIf;
use InitialBlockElseOnly;
use JsonOutput;
use ModulePort;
use VerilogParser;

use File::Path qw(make_path);



#संस्कृते मुद्रणाय
binmode(STDOUT, ":utf8"); 
use JSON;

# Always - $
# If - #
#initial - !


# To clean all_functions.txt

#फाइलं उद्घाटयतु
if ($ARGV[0] eq "") {
    die "Cannot open empty file"
}

use Diagnostics;

VerilogParser::parse_verilog($ARGV[0]);

Diagnostics::print_diagnostics();

JsonOutput::write_json();
