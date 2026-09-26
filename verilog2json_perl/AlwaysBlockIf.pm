package AlwaysBlockIf;

use strict;
use warnings;
use utf8;

our $always_if_count;
sub always_comb_if {
    my ($line1,$line_no) = @_;
    my $expect_end =0;
    my $orig_line_no = $line_no;
    my $end_occurred = 0;
    my $conditional_statement;
    my $token;
    $line1 =~ s/if//;
    $line1 =~ s/\s*//g;
    while ($line1 =~ /^$/) {
        $line_no = $line_no+1;
        if ($line_no > $VerilogParser::max_line) {
            Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Max line reached at always_block_if", $line_no);
        }
        $line1 .= $VerilogParser::verilog_file[$line_no];
        chomp($line1);
        $line1 =~ s/\s*//g;
    }
    my $conditional_expr1;
    my @conditional_expr;
    if ($line1 =~ /\(([\w=!<>\?\|:&\+\-\*\/%^!~\(\)\']+)\)/) {
        $conditional_expr1 = $1;
        @conditional_expr = CheckExpr::create_postfix($conditional_expr1, $line_no);
    } else {
        Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Error from always_comb_if no proper expression", $line_no);
    }
    $line1 =~ s/\s*\(\s*$conditional_expr1\s*\)\s*//;
    while ($line1 =~ /^\s*$/) {
        $line_no = $line_no+1;
        if ($line_no > $VerilogParser::max_line) {
            Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Max line reached at check_module", $line_no);
        }
        $line1 .= $VerilogParser::verilog_file[$line_no];
        chomp($line1);
        $line1 =~ s/\s*//g;        
    }
    #$JsonOutput::module_json{$VerilogParser::module_name}{"${always_count}_सदाङ्ग"}{${if_count}_यद्यङ्ग"}{"प्रकारः"} = "यद्यङ्ग";
    push @AlwaysBlock::always_block_arr, $always_if_count;
    push @AlwaysBlock::always_block_arr, "_";
    $always_if_count = $always_if_count+1;
    my $json_var = $JsonOutput::module_json{$VerilogParser::module_name};
    my $arr_cnt = @AlwaysBlock::always_block_arr;
    my $arr_trk=0;
    my $statement_type;
    my $statement_count;
    my $json_statement;
    while ($arr_trk < $arr_cnt) {
        $statement_type = $AlwaysBlock::always_block_arr[$arr_trk+1];
        $statement_count = $AlwaysBlock::always_block_arr[$arr_trk];
        $arr_trk= $arr_trk+2;       
        if ($statement_type eq "\$") {
            $json_statement = "सदाङ्गम्_".${statement_count};
            $json_var = $json_var->{$json_statement};





        } elsif ($statement_type eq "_") {
            $json_statement = "यद्यङ्गम्_".${statement_count};
            $json_var->{$json_statement} //= {};
            $json_var = $json_var->{$json_statement};
        } elsif ($statement_type eq "#") {
            $json_statement = "अन्यथायद्यङ्गम्_".${statement_count};
            $json_var->{$json_statement} //= {};
            $json_var = $json_var->{$json_statement};
        } elsif ($statement_type eq "&") {
            $json_statement = "अन्यथाङ्गम्_".${statement_count};
            $json_var->{$json_statement} //= {};
            $json_var = $json_var->{$json_statement};                
        }
    }
    $conditional_statement = "";
    foreach $token (@conditional_expr) {
        $conditional_statement = $conditional_statement." ".$token;
    }    
    $json_var->{"प्रकारः"} = "यद्यङ्गम्";
    $json_var->{"शर्तिः"} = $conditional_statement;
    $json_var->{"क्रमः"} = $VerilogParser::statement_order;
    $VerilogParser::statement_order = $VerilogParser::statement_order+1;
    if ($line1 =~ /^\s*begin/) {
        $expect_end = 1;
        $line1 =~ s/^\s*begin//;
    }
    while (1) {
        while ($line1 =~ /^$/) {
            $line_no = $line_no+1;
            if ($line_no > $VerilogParser::max_line) {
                Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Max line reached at always_comb_if", $line_no);
            }
            $line1 .= $VerilogParser::verilog_file[$line_no];
            chomp($line1);
            $line1 =~ s/\s*//g;        
        }        
        if ($line1 =~ /^\s*end\s*/ ) {
            if ($expect_end == 1) {
                $end_occurred = 1;
            } else {
                Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Extra end present", $line_no);
                $end_occurred =1;
            }    










        
        } elsif ($line1 =~ /^if/) {
            $line_no = always_comb_if ($line1, $line_no);
            $line1 = "";
            if ($expect_end == 0) {
                $end_occurred = 1;
            }
        } elsif ($line1 =~ /^\s*;\s*$/) { # Null statement
            $line1 = "";
            if ($expect_end == 0) {
                $end_occurred = 1;
            }
        } elsif ($line1 =~ /^\s*([^=]+?)\s*(?:<=|=)\s*(.*)$/) { #Check for Statement
            my $lhs = $1;
            my $rhs = $2;
            chomp($line1);
            SemanticChecker::validate_assignment($lhs, $line_no);
            my $statement;
            my @statement_temp = CheckExpr::create_postfix($line1, $line_no);
            $statement = join(" ",@statement_temp);
            my $stt = ${VerilogParser::statement_line}."_वाक्यम्";
            $json_var->{$stt} //= {};
            $json_var->{$stt}->{"प्रकारः"} = "वाक्यम्";
            $json_var->{$stt}->{"वाक्यम्"} = $statement;
            $json_var->{$stt}->{"क्रमः"} = $VerilogParser::statement_order;
            $VerilogParser::statement_order = $VerilogParser::statement_order+1;
            $line1 = "";

            if ($expect_end == 0) {
                $end_occurred = 1;
            }
        } elsif ($line1 =~ /^\$/){
            if ($expect_end == 0) {
                $end_occurred = 1;
            }
            if ($line1 =~ /;/) {
                $line1 =~ s/;//;
            } else {
                print "Semicolon missing at end of system tasks";
            }










        } elsif ($line1 =~ /endmodule|always/) {
            Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Missing end at $line_no with line $line1", $line_no);
        } else {
            Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Error occured $line1", $line_no);
        }
        if ($end_occurred==1) {
            last;
       }
    }
    $orig_line_no=$line_no;
    while ($line1 =~ /^$/) {
        $line_no = $line_no+1;
        if ($line_no > $VerilogParser::max_line) {
            Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Max line reached at always_comb_if", $line_no);
        }
        $line1 .= $VerilogParser::verilog_file[$line_no];
        chomp($line1);
        $line1 =~ s/\s*//g;        
    }
    if ($line1 =~ /^\s*else/) {
        my $if_symbol = pop @AlwaysBlock::always_block_arr;
        $always_if_count = pop @AlwaysBlock::always_block_arr;
        push @AlwaysBlock::always_block_arr,$always_if_count ;
        push @AlwaysBlock::always_block_arr,$if_symbol;
        push @AlwaysBlock::always_block_arr,$always_if_count ;
        push @AlwaysBlock::always_block_arr,$if_symbol;
    }
    while ($line1 =~ /^\s*else/) {
        $line1 =~ s/\s*else//;
        while ($line1 =~ /^$/) {
            $line_no = $line_no+1;
            if ($line_no > $VerilogParser::max_line) {
                Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Max line reached at always_block_if", $line_no);
            }
            $line1 .= $VerilogParser::verilog_file[$line_no];
            chomp($line1);
            $line1 =~ s/\s*//g;        
        }
        if ($line1 =~ /if/) {
            $line_no = AlwaysBlockElseIf::always_block_elseif($line1,$line_no);
            $line1 = "";
        }  else {
            $line_no = AlwaysBlockElseOnly::always_block_elseonly($line1,$line_no);
            $line1 = "";
        }
        $orig_line_no = $line_no;
        while ($line1 =~ /^$/) {
            $line_no = $line_no+1;
            if ($line_no > $VerilogParser::max_line) {
                Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Max line reached at always_block_if", $line_no);
            }
            $line1 .= $VerilogParser::verilog_file[$line_no];
            chomp($line1);
            $line1 =~ s/\s*//g;        
        }
    } 
    pop @AlwaysBlock::always_block_arr;
    pop @AlwaysBlock::always_block_arr;
    return $orig_line_no;
}
1;
