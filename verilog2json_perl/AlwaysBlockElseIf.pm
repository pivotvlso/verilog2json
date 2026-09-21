package AlwaysBlockElseIf;

use strict;
use warnings;
use utf8;

sub always_block_elseif {
    my ($line1,$line_no) = @_;
    my $expect_end =0;
    my $orig_line_no = $line_no;
    my $end_occurred = 0;
    my $conditional_statement;
    my $token;
    $line1 =~ s/if//g;
    $line1 =~ s/\s*//g;
    while ($line1 =~ /^$/) {
        $line_no = $line_no+1;
        if ($line_no > $VerilogParser::max_line) {
            Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Max line reached at AlwaysBlockIf::always_block_elseif", $line_no);
        }
        $line1 .= $VerilogParser::verilog_file[$line_no];
        chomp($line1);
        $line1 =~ s/\s*//g;
    }
    my @conditional_expr;
    my $conditional_expr1;
    if ($line1 =~ /\(([\w=!<>\?\|:&\+\-\*\/%^!~\(\)]+)\)/) {
        $conditional_expr1 = $1;
        @conditional_expr = CheckExpr::create_postfix($conditional_expr1);
    } else {
        Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Error from AlwaysBlockElseIf::always_block_else_if no proper expression", $line_no);
    }
    $line1 =~ s/\($conditional_expr1\)//;
    while ($line1 =~ /^$/) {
        $line_no = $line_no+1;
        if ($line_no > $VerilogParser::max_line) {
            Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Max line reached at check_module", $line_no);
        }
        $line1 .= $VerilogParser::verilog_file[$line_no];
        chomp($line1);
        $line1 =~ s/\s*//g;        
    }
    pop @AlwaysBlock::always_block_arr;
    $AlwaysBlockIf::Always_if_count = pop @AlwaysBlock::always_block_arr;
    $AlwaysBlockIf::Always_if_count =   $AlwaysBlockIf::always_if_count+1;
    push @AlwaysBlock::always_block_arr,$AlwaysBlockIf::always_if_count;
    push @AlwaysBlock::always_block_arr,"#";
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
            $json_var->{$json_statement} //= {};
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
    $conditional_statement = join(" ",@conditional_expr);
    $json_var->{"प्रकारः"} = "अन्यथायद्यङ्गम्";
    $json_var->{"शर्तिः"} = $conditional_statement;
    $json_var->{"क्रमः"} = $VerilogParser::statement_order;
    $VerilogParser::statement_order = $VerilogParser::statement_order+1;
    if ($line1 =~ /^begin/) {
        $expect_end = 1;
        $line1 =~ s/begin//;
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
        if ($line1 =~ /^end$/) {
            if ($expect_end == 1) {
                $end_occurred = 1
            } else {
                Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Extra end present", $line_no);
                $end_occurred =1;
            }











        } elsif ($line1 =~ /^if/) { #Check for IF loop
            $line_no = AlwaysBlockIf::always_block_if ($line1, $line_no);
            $line1 = "";
            if ($expect_end == 0) {
                $end_occurred = 1;
            }    
        } elsif ($line1 =~ /([a-zA-Z_]+)=/) { #Check for Statement
            my $var_name = $1;
            chomp($line1);
            my $statement;
            my @statement_temp = CheckExpr::create_postfix($line1);
            $statement = join(" ",@statement_temp);
            my $stt = ${VerilogParser::statement_line}."_वाक्यम्";
            $json_var->{$stt} //= {};
            $json_var->{$stt}->{"प्रकारः"} = "वाक्यम्";
            $json_var->{$stt}->{"वाक्यम्"} = $statement;
            $json_var->{$stt}->{"क्रमः"} = $VerilogParser::statement_order;
            $VerilogParser::statement_order = $VerilogParser::statement_order+1;
            $line1 = "";
            $VerilogParser::statement_line = $VerilogParser::statement_line+1;
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
        if ($end_occurred) {
            last;
       }
    }
    return $line_no;
}
1;