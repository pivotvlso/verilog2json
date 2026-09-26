package CombCkt;
use strict;
use warnings;
use utf8;
use VerilogParser;
use CheckExpr;
use SemanticChecker;
use Diagnostics;

our $assign_stt_cnt = 0;

sub check_assign {
    my ($line_no) = @_;
    my $line1 = $VerilogParser::verilog_file[$line_no];
    chomp($line1);
    
    if ($line1 =~ /^\s*assign\b/) {
        while ($line1 !~ /;/) {
            $line_no++;
            if ($line_no >= $VerilogParser::max_line) {
                Diagnostics::report_diagnostic("Error", "ERR_FATAL", "assign statement missing semicolon", $line_no);
                return $line_no;
            }
            $line1 .= " " . $VerilogParser::verilog_file[$line_no];
            chomp($line1);
        }
        
        $line1 =~ s/^\s*assign\s*//;
        
        # Extract optional delay
        my $delay_val = "";
        if ($line1 =~ /^#\s*(\d+)\s+/) {
            $delay_val = $1;
            $line1 =~ s/^#\s*\d+\s+//;
        } elsif ($line1 =~ /^#\s*\(\s*(\d+)\s*\)\s+/) {
            $delay_val = $1;
            $line1 =~ s/^#\s*\(\s*\d+\s*\)\s+//;
        }
        
        if ($line1 =~ /^\s*([^=]+?)\s*=\s*(.*)$/) {
            my $lhs = $1;
            my $rhs = $2;
            
            SemanticChecker::validate_continuous_assignment($lhs, $line_no);
            
            my $statement;
            my @statement_temp = CheckExpr::create_postfix($line1, $line_no);
            $statement = join(" ", @statement_temp);
            
            my $block_key = $assign_stt_cnt . "_योजयति";
            $JsonOutput::module_json{$VerilogParser::module_name}{$block_key} //= {};
            my $json_var = $JsonOutput::module_json{$VerilogParser::module_name}{$block_key};
            
            $json_var->{"प्रकारः"} = "योजयति";
            $json_var->{"क्रमः"} = $VerilogParser::statement_order;
            
            if ($delay_val ne "") {
                $json_var->{"विलम्बः"} = $delay_val;
            }
            
            $json_var->{"वाक्यम्"} = $statement;
            
            $assign_stt_cnt++;
            $VerilogParser::statement_order++;
            
        } else {
             Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Malformed assign statement", $line_no);
        }
    }
    return $line_no;
}

1;
