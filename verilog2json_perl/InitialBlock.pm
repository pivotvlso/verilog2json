package InitialBlock;
use InitialBlockIf;
use SemanticChecker;

use strict;
use warnings;
use utf8;


sub initial_block;
our $initial_block_count = 0;
our @initial_block_arr = ();
our $delay_val_cnt;

sub initial_block {

    my ($line_no) = @_;
    my $expect_end = 0;
    my $end_occurred=0;
    $delay_val_cnt = 0;
    $InitialBlockIf::initial_if_count = 0;
    my $line1 = $VerilogParser::verilog_file[$line_no];
    chomp($line1);


    if ($line1 =~ s/initial//){
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        while ($line1 =~ /^$/) {            
            $line_no = $line_no+1;
            if ($line_no > $VerilogParser::max_line) {
                Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Max line reached at check_module", $line_no);
            }
            $line1 .= $VerilogParser::verilog_file[$line_no];
            chomp($line1);
            $line1 =~ s/\s*//g;
        }
        $line1 =~ s/\s*//g;
        if ($line1 =~ /^begin/) {
           $expect_end=1;
           $line1 =~ s/begin//;
        }
        @initial_block_arr = ();
        push @initial_block_arr, $initial_block_count;
        push @initial_block_arr, "!";
       
        my $json_var = $JsonOutput::module_json{$VerilogParser::module_name};
        my $arr_cnt = scalar @initial_block_arr;
        my $arr_trk=0;
        my $statement_type;
        my $statement_count;
        my $json_statement;
        while ($arr_trk < $arr_cnt) {
            $statement_type = $initial_block_arr[$arr_trk+1];
            $statement_count = $initial_block_arr[$arr_trk];
            $arr_trk= $arr_trk+2;
            
            
            if ($statement_type eq "!") {
                $json_statement = "आद्यारम्भाङ्गम्_".${statement_count};
                $json_var->{$json_statement} //= {};
                $json_var = $json_var->{$json_statement};
            } elsif ($statement_type eq "-") {
                $json_statement = "विलम्बाङ्गम्_".${statement_count};
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
        $json_var->{"प्रकारः"} = "आद्यारम्भाङ्गम्";
        $json_var->{"क्रमः"} = $VerilogParser::statement_order;
        $initial_block_count = $initial_block_count+1;


        $VerilogParser::statement_order = $VerilogParser::statement_order+1;
        while (1) {
            while ($line1 =~ /^$/) {
                $line_no = $line_no+1;
                if ($line_no > $VerilogParser::max_line) {
                    Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Max line reached at initial_block", $line_no);
                }
                $line1 .= $VerilogParser::verilog_file[$line_no];
                chomp($line1);
                $line1 =~ s/#\s*(\d+)/#\($1\)/g;
                $line1 =~ s/\s*//g;
            }
            if ($line1 =~ /^\s*if/) { #Check for IF loop
                $line_no = InitialBlockIf::initial_block_if ($line1, $line_no);
                $line1 = "";
                if ($expect_end == 0) {
                    $end_occurred = 1;
                }
            #Check for END    
            } elsif ($line1 =~ /^\s*end\s*$/) {
                if ($expect_end == 1) {
                    $end_occurred = 1;
                } else {
                    Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Extra end present", $line_no);
                    $end_occurred =1;
                }
            } elsif ($line1 =~ /^#\(?(\d+)\)?/) {
                my $delay_val = $1;
                my $stt = ${delay_val_cnt}."_विलम्बाङ्गम्";
                $json_var->{$stt} //= {}; 
                $json_var->{$stt}->{"क्रमः"} = $VerilogParser::statement_order;
                $VerilogParser::statement_order = $VerilogParser::statement_order+1;
                $delay_val_cnt = $delay_val_cnt+1;
                $json_var->{$stt}->{"प्रकारः"} = "विलम्बाङ्गम्";
                $json_var->{$stt}->{"विलम्बः"} = $delay_val;
                $line1 =~ s/\#\(${delay_val}\)//;           
            } elsif ($line1 =~ /^\s*;\s*$/) { # Null statement
                $line1 = "";
                if ($expect_end == 0) {
                    $end_occurred = 1;
                }
            } elsif ($line1 =~ /^\s*([^=]+?)\s*(<=|=)\s*(.*)$/) { #Check for Statement
                my $lhs = $1;
                my $operator = $2;
                my $rhs = $3;
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
                $VerilogParser::statement_line = $VerilogParser::statement_line+1;
                if ($expect_end == 0) {
                    $end_occurred = 1;
                }
            } elsif ($line1 =~ /^\$/){
                if ($line1 =~ /\$finish/) {
                    my $stt = ${VerilogParser::statement_line}."_वाक्यम्";
                    $json_var->{$stt} //= {};
                    $json_var->{$stt}->{"प्रकारः"} = "समापनम्";
                    $json_var->{$stt}->{"क्रमः"} = $VerilogParser::statement_order;
                    $VerilogParser::statement_order = $VerilogParser::statement_order+1;
                    $line1 =~ s/\$finish//;
                    while ($line1 =~ /^$/) {
                        $line_no = $line_no+1;
                        if ($line_no > $VerilogParser::max_line) {
                            Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Max line reached at initial_block", $line_no);
                        }
                        $line1 .= $VerilogParser::verilog_file[$line_no];
                        chomp($line1);
                        $line1 =~ s/#\s*(\d+)/#\($1\)/g;
                        $line1 =~ s/\s*//g;
                    }
                    if ($line1 =~ /;/) {
                        $line1 =~ s/;//;
                    } else {
                        Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Semicolon missing at end of \$finish statement", $line_no);
                    }
                } elsif ($line1 =~ /\$display/) {
                    $line1 = $VerilogParser::verilog_file[$line_no];
                    while ($line1 !~ /;/) {
                        $line_no = $line_no+1;
                        if ($line_no > $VerilogParser::max_line) {
                            Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Max line reached at initial_block", $line_no);
                        }
                        $line1 .= $VerilogParser::verilog_file[$line_no];
                        chomp($line1);
                    }
                    if ($line1 =~ /;/) {
                        $line1 =~ s/;//;
                    } else {
                        print "Semicolon missing at end of \$display statement";
                    }
                    my $main_text;
                    my $var_list;
                    if ($line1 =~ /display\s*\(\s*\"((?:\\.|[^"\\])*)"(.*?)\)$/) {
                        $main_text = $1;
                        $var_list = $2;
                    } else {
                        Diagnostics::report_diagnostic("Error", "ERR_FATAL", " Print statement format is not correct", $line_no);
                    }
                    $var_list =~ s/\s*//g;
                    $main_text =~ s/%(\d*[ubohctsd])/<<%$1<</g;
                    my @text_parts = split /<</, $main_text;
                    my @var_parts = split /,/,$var_list;
                    my $part_no=1;
                    my $total_text_parts = scalar @text_parts;
                    my $total_var_parts = scalar @var_parts;
                    my $print_statement = "std::cout <<";
                    if((($total_text_parts)/2)+1 == $total_var_parts) {
                        foreach my $j (@text_parts) {
                            if ($j =~ /%(\d*)([ubohctsd])/) {
                                my $resolution = $1;
                                my $conversion = $2;
                                if ($resolution eq "") {
                                    $resolution = 0;
                                }
                                if ($conversion =~ /d/) {
                                    if ($JsonOutput::module_json{$VerilogParser::module_name}{$var_parts[$part_no]}{"प्रकारः"} eq "तारः") {

                                       $print_statement = $print_statement.CheckExprInitialBlock::दशमाननिर्गमः ($var_parts[$part_no])."<<";
                                    } else {
                                        Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Bare word $var_parts[$part_no] couldnot be identified in initial block", $line_no);
                                    }
                                }
                                $part_no++;
                            } else {
                                $print_statement = $print_statement.'"'.$j.'"'."<<";
                            }
                        }
                        $print_statement = $print_statement."endl;";
                        while ($line1 =~ /^$/) {
                            $line_no = $line_no+1;
                            if ($line_no > $VerilogParser::max_line) {
                                Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Max line reached at initial_block", $line_no);
                            }
                            $line1 .= $VerilogParser::verilog_file[$line_no];
                            chomp($line1);
                            $line1 =~ s/\s*//g;
                        }
                    } else {
                        Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Error in print statement, Format specifier and variables donot match", $line_no);
                    }
                    my $stt = ${VerilogParser::statement_line}."_वाक्यम्";
                    $json_var->{$stt} //= {};
                    $json_var->{$stt}->{"प्रकारः"} = "मुद्रणम्";
                    $json_var->{$stt}->{"क्रमः"} = $VerilogParser::statement_order;
                    $json_var->{$stt}->{"वाक्यम्"} = $print_statement; 
                    $VerilogParser::statement_order = $VerilogParser::statement_order+1;
                    $line1 = "";
                    $VerilogParser::statement_line = $VerilogParser::statement_line+1;                           
                } else {
                    Diagnostics::report_diagnostic("Error", "ERR_FATAL", " Unsupported system tasks", $line_no);
                }
            } elsif ($line1 =~ /endmodule|always/) {
                Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Missing end at $line_no with line $line1", $line_no);
            } else {
                Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Error occured $line1", $line_no);
            }
            if ($end_occurred == 1) {
                last;
           }
        }
    } else {
        Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Error in $line_no from initial block", $line_no);
    } 
    return $line_no;    
}
1;
