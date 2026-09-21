package VerilogParser;
use strict;
use warnings;
use utf8;
use File::Path qw(make_path);

# Subroutines
sub parse_verilog;
sub check_module;

use Diagnostics;

my $line1;
my @split_line;
my $module_defined=0;
our @verilog_file = ();
our $statement_line=0;
our $statement_order=0;
our $module_name;

my @verilog_file_temp1 = ();
our $verilog_file_lines=0;
my @parts;
our $max_line=0;
my $i;

sub parse_verilog {
    my ($verilog_file_name) = @_;
    $ModulePort::port_ordering =1;
    open(VERILOG_FILE, "<", $verilog_file_name) or do {
        Diagnostics::report_diagnostic("Error", "1-1", "Cannot open file: $verilog_file_name", 0);
        return;
    };
    @verilog_file = <VERILOG_FILE>;
    close(VERILOG_FILE);
    
    $max_line = scalar @verilog_file;
    # --- SANITIZE COMMENTS FROM THE ENTIRE FILE FIRST ---
    my $in_block_comment = 0;
    my $in_attribute = 0;
    my $block_comment_start_line = 0;
    for (my $j = 0; $j < $max_line; $j++) {
        my $line1 = $VerilogParser::verilog_file[$j];
        
        while (1) {
            if ($in_block_comment) {
                # Look for the end of the block comment
                if ($line1 =~ s/^.*?\*\///) {
                    $in_block_comment = 0;
                } else {
                    $line1 = ""; # Entire line is commented out
                    last;
                }
            } elsif ($in_attribute) {
                # Look for the end of the attribute
                if ($line1 =~ s/^.*?\*\)//) {
                    $in_attribute = 0;
                } else {
                    $line1 = ""; # Entire line is part of attribute
                    last;
                }
            } else {
                # Remove inline block comments like /* ... */ on the same line
                $line1 =~ s/\/\*.*?\*\///g;
                
                # Remove inline attributes like (* ... *) on the same line
                $line1 =~ s/\(\*.*?\*\)//g;
                
                # Check if a multi-line block comment starts here
                if ($line1 =~ s/\/\*.*//) {
                    $in_block_comment = 1;
                    $block_comment_start_line = $j + 1;
                }
                
                # Check if a multi-line attribute starts here
                if ($line1 =~ s/\(\*.*//) {
                    $in_attribute = 1;
                }
                
                # Remove single line comments
                $line1 =~ s/\/\/.*//;
                last;
            }
        }
        
        # Save the cleaned line back to the array so All subroutines get the clean version!
        $VerilogParser::verilog_file[$j] = $line1;
    }

    if ($in_block_comment) {
        Diagnostics::report_diagnostic("Error", "3-1", "Unterminated block comment", $block_comment_start_line);
    }

   
    for ($i=0; $i < $max_line ; $i++) {
        $line1 = $VerilogParser::verilog_file[$i];
        chomp($line1);

        if ($module_defined == 0) {
            $i = check_module($i);
            my $out_dir = "sam_आन्तरिककुञ्जीमूल्यरूपम्";
            make_path($out_dir) unless -d $out_dir;
            open (MODULE_FILE, ">>:encoding(UTF-8)","$out_dir/all_modules.txt") or Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Cannot open all_modules.txt file", $i + 1);
            print MODULE_FILE "${module_name}\n";
            close(MODULE_FILE);
            $ModulePort::port_ordering =1;
            $CheckType::instance_no = 1;

        } elsif ($VerilogParser::verilog_file[$i] =~ /^\s*(?:wire|reg|logic|integer|real|realtime|time)\b/) {
            $i = ModulePort::populate_interconnect($i);
        } elsif ($VerilogParser::verilog_file[$i] =~ /^\s*input/) {
            $i = ModulePort::populate_port_afterwards($i);
            
        } elsif ($VerilogParser::verilog_file[$i] =~ /^\s*output/) {
            $i = ModulePort::populate_port_afterwards($i);
        } elsif ($VerilogParser::verilog_file[$i] =~ /^\s*inout/) {
            $i = ModulePort::populate_port_afterwards($i);
        } elsif ($VerilogParser::verilog_file[$i] =~ /^\s*assign/) {
           $i = CombCkt::check_assign($i);
        } elsif ($VerilogParser::verilog_file[$i] =~ /^\s*always/) {
           $i = AlwaysBlock::always_block($i);
        } elsif ($VerilogParser::verilog_file[$i] =~ /^\s*initial/) {

           $i = InitialBlock::initial_block($i);


        } elsif ($VerilogParser::verilog_file[$i] =~ /^\s*$/) {
            
        } elsif ($VerilogParser::verilog_file[$i] =~ /^\s*endmodule/) {
            last;
        } elsif ($VerilogParser::verilog_file[$i] =~ /^\s*(?:wand|wor|tri|triand|trior|tri0|tri1|trireg|uwire|supply0|supply1)\b/) {
            Diagnostics::report_diagnostic("Error", "ERR_UNSUPPORTED_NET", "Unsupported net type in declaration", $i + 1);
            # Advance to the end of the declaration so we don't crash the instance parser
            while ($VerilogParser::verilog_file[$i] !~ /;/) {
                $i++;
                if ($i >= $max_line) { last; }
            }
        } elsif ($VerilogParser::verilog_file[$i] =~ /^\s*[A-Za-z]/) {
            $i = CheckType::check_type($i);
        } else {
            Diagnostics::report_diagnostic("Error", "3-1", "Unknown bareword $VerilogParser::verilog_file[$i]", $i + 1);
        }
    }
   $verilog_file_lines = scalar @verilog_file;
}

#मॉड्यूलं परीक्ष्यताम्
sub check_module {
    my ($line_no) = @_;
    my $line1 = $verilog_file[$line_no];
    chomp($line1);
    while (1) {
        if ($line1 =~ /module\s+([A-Za-z_][A-Za-z0-9_]*)/) {
            $module_name = $1;
            last;
        }
        $line_no++;
        if ($line_no >= $max_line) {
            Diagnostics::report_diagnostic("Error", "4-1", "Max line reached without finding module name", $line_no);
            return $line_no;
        }
        $line1 .= " " . $verilog_file[$line_no];
        chomp($line1);
    }
    $module_defined  = 1;
    
    $JsonOutput::module_json{$VerilogParser::module_name}{"रेखाङ्कः"} = $line_no+1;
    $JsonOutput::module_json{$VerilogParser::module_name}{"सञ्चिकानाम"} = "sample.v";
    $JsonOutput::module_json{$VerilogParser::module_name}{"प्रकारः"}="घटकः";
    my $module_line_no= ModulePort::get_ports($line_no);
    return $module_line_no;

}
1;