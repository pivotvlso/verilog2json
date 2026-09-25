package CheckType;
use strict;
use warnings;
use utf8;

# Subroutines
sub check_type;
our $instance_no;
our $instance_port_no;



sub check_type {
    my ($line_no) = @_;
    my $first_word;
    my $second_word;
    my $line1 = $VerilogParser::verilog_file[$line_no];
    if ($line1 =~ /^\s*([A-Za-z][A-Za-z0-9_]*)/) {
        $first_word = $1;
        $JsonOutput::module_json{$VerilogParser::module_name}{${instance_no}."_प्रतिरूपम्"}{"प्रकारः"} = "प्रतिरूपम्";
        $JsonOutput::module_json{$VerilogParser::module_name}{${instance_no}."_प्रतिरूपम्"}{"रूपनाम"} = $first_word;


    } else {
        Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Error from Check_Type::check_type proc; Unknown bareword $line1", $line_no);
    }
    $line1 =~ s/$first_word//;
    $line1 =~ s/^\s*//;
    if ($line1 =~ /^;$/) {
        return $line_no;
    }

    while ($line1 =~ /^$/) {
        
        $line_no = $line_no+1;
        if ($line_no > $VerilogParser::max_line) {
            Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Max line reached at CheckType::check_type after first_word", $line_no);
        }
        $line1 .= $VerilogParser::verilog_file[$line_no];
        chomp($line1);
        $line1 =~ s/\s*//g;
    }
    if ($line1 =~ /^\s*([A-Za-z][A-Za-z0-9_]*)/) {
        $second_word = $1;
        $JsonOutput::module_json{$VerilogParser::module_name}{${instance_no}."_प्रतिरूपम्"}{"प्रतिरूपनाम"} = $second_word;

    } else {
        Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Error from Check_Type::check_type proc; Unknown bareword $line1", $line_no);
    }
    $line1 =~ s/$second_word//;
    $line1 =~ s/^\s*//;
    if ($line1 =~ /^;$/) {
        return $line_no;
    }
    while ($line1 =~ /^$/) {   
        $line_no = $line_no+1;
        if ($line_no > $VerilogParser::max_line) {
            Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Max line reached at CheckType::check_type after second_word", $line_no);
        }
        $line1 .= $VerilogParser::verilog_file[$line_no];
        chomp($line1);
        $line1 =~ s/\s*//g;
    }
    if ($line1 =~ /^\(/) {
        $instance_port_no = 0;
        ($line1,$line_no) = parse_instantiation($line1,$line_no);

    } else {
        Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Need to update in CheckType::check_type", $line_no);
    }
    
    if ($line1 =~ /^\s*$/) {
        $instance_no++;
        return $line_no;
    } else {
        Diagnostics::report_diagnostic("Error", "ERR_FATAL", " Need to handle unknown statements in CheckType::check_type with bareword $line1\n", $line_no);
    }
}

sub parse_instantiation {
    my ($line1,$line_no) = @_;
    $line1 =~ s/\(//;
    while ($line1 =~ /^$/) {   
        $line_no = $line_no+1;
        if ($line_no > $VerilogParser::max_line) {
            Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Max line reached at CheckType::check_type after second_word", $line_no);
        }
        $line1 .= $VerilogParser::verilog_file[$line_no];
        chomp($line1);
        $line1 =~ s/\s*//g;
    }
    if ($line1 =~ /^\s*\./) {
        ($line1,$line_no) = named_port_connection($line1,$line_no);
    } elsif ($line1 =~ /\s*[A-Za-z0-9]/) {
        ($line1,$line_no) = ordered_port_connection($line1,$line_no);

    } else {
        Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Error in module instantiation in CheckType::parse_instantion\n", $line_no);
    }
    return ($line1,$line_no);
}

sub named_port_connection {
    my ($line1,$line_no) = @_;
    while(1) {
        $instance_port_no = $instance_port_no+1;
        if ($line1 =~ /^\s*\./) {
            $line1 =~ s/^\s*\.//;
        } else {
            Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Missing \. in CheckType::named_port_connection\n", $line_no);
        }
        
        while ($line1 =~ /^$/) {   
            $line_no = $line_no+1;
            if ($line_no > $VerilogParser::max_line) {
                Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Max line reached at CheckType::named_port_connection after second_word", $line_no);
            }
            $line1 .= $VerilogParser::verilog_file[$line_no];
            chomp($line1);
            $line1 =~ s/\s*//g;
        }

        $JsonOutput::module_json{$VerilogParser::module_name}{${instance_no}."_प्रतिरूपम्"}{${instance_port_no}."_द्वारक्रमः"}{"प्रकारः"} = "द्वारक्रमः";

        $JsonOutput::module_json{$VerilogParser::module_name}{${instance_no}."_प्रतिरूपम्"}{${instance_port_no}."_द्वारक्रमः"}{"द्वारसंयोजनम्"} = "";
        $JsonOutput::module_json{$VerilogParser::module_name}{${instance_no}."_प्रतिरूपम्"}{${instance_port_no}."_द्वारक्रमः"}{"द्वारक्रमः"} = -1;
        if ($line1 =~ s/^\s*([A-Za-z][A-Za-z0-9_]*)\s*//) {
            $JsonOutput::module_json{$VerilogParser::module_name}{${instance_no}."_प्रतिरूपम्"}{${instance_port_no}."_द्वारक्रमः"}{"रूपद्वारम्"} = $1;

        } else {
            Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Error from CheckType::named_port_connection with bareword $line1", $line_no);
        }

        while ($line1 =~ /^\s*$/) {   
            $line_no = $line_no+1;
            if ($line_no > $VerilogParser::max_line) {
                Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Max line reached at CheckType::named_port_connection after second_word", $line_no);
            }
            $line1 .= $VerilogParser::verilog_file[$line_no];
            chomp($line1);
            $line1 =~ s/\s*//g;
        }
        if ($line1 =~ /\(/) {
            $line1 =~ s/\(//;
        } else {
            Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Error in CheckType::named_port_connection", $line_no);
        }
        if ($line1 =~ s/^\s*([A-Za-z0-9_][A-Za-z0-9_\[\]\:\']*|\{(?:[^{}]+|(?1))*\})\s*//) {
            $JsonOutput::module_json{$VerilogParser::module_name}{${instance_no}."_प्रतिरूपम्"}{${instance_port_no}."_द्वारक्रमः"}{"द्वारसंयोजनम्"} = $1;
        } elsif ($line1 =~ /^\s*[,)]/) {
            $JsonOutput::module_json{$VerilogParser::module_name}{${instance_no}."_प्रतिरूपम्"}{${instance_port_no}."_द्वारक्रमः"}{"द्वारसंयोजनम्"} = "";
        } else {
            Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Error from CheckType::named_port_connection with bareword $line1", $line_no);
        }

        while ($line1 =~ /^$/) {   
            $line_no = $line_no+1;
            if ($line_no > $VerilogParser::max_line) {
                Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Max line reached at CheckType::named_port_connection after second_word", $line_no);
            }
            $line1 .= $VerilogParser::verilog_file[$line_no];
            chomp($line1);
            $line1 =~ s/\s*//g;
        }
        if ($line1 =~ s/^\s*\)//) {
            # Port mapping closed. Check what's next.
            if ($line1 =~ s/^\s*,//) {
                # More ports to come
                while ($line1 =~ /^$/) {   
                    $line_no = $line_no+1;
                    if ($line_no > $VerilogParser::max_line) {
                        Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Max line reached at CheckType::named_port_connection after second_word", $line_no);
                    }
                    $line1 .= $VerilogParser::verilog_file[$line_no];
                    chomp($line1);
                    $line1 =~ s/\s*//g;
                }
            } elsif ($line1 =~ s/^\s*\)//) {
                # End of instantiation
                last;
            } else {
                Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Error in CheckType::named_port_connection with extra bareword $line1", $line_no);
            }
        } else {
            Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Missing closing parenthesis for named port in CheckType::named_port_connection", $line_no);
        }
    }
    while ($line1 =~ /^\s*$/) {   
        $line_no = $line_no+1;
        if ($line_no > $VerilogParser::max_line) {
            Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Max line reached at CheckType::named_port_connection after second_word", $line_no);
        }
        $line1 .= $VerilogParser::verilog_file[$line_no];
        chomp($line1);
        $line1 =~ s/\s*//g;
    }
    if ($line1 =~ s/^\s*;\s*$//) {

    } else {
        die "Missing semicolon in instantiation $JsonOutput::module_json{$VerilogParser::module_name}{${instance_no}.\"_प्रतिरूपम्\"}{\"प्रतिरूपनाम\"}";
    }
    return ($line1,$line_no);


}

sub ordered_port_connection {
    my ($line1,$line_no) = @_;
    while(1) {
        $instance_port_no = $instance_port_no+1;

        if ($line1 =~ s/^\s*([A-Za-z0-9_][A-Za-z0-9_\[\]\:\']*|\{(?:[^{}]+|(?1))*\})\s*//) {
            $JsonOutput::module_json{$VerilogParser::module_name}{${instance_no}."_प्रतिरूपम्"}{${instance_port_no}."_द्वारक्रमः"}{"द्वारसंयोजनम्"} = $1;
            $JsonOutput::module_json{$VerilogParser::module_name}{${instance_no}."_प्रतिरूपम्"}{${instance_port_no}."_द्वारक्रमः"}{"रूपद्वारम्"} = "";
            $JsonOutput::module_json{$VerilogParser::module_name}{${instance_no}."_प्रतिरूपम्"}{${instance_port_no}."_द्वारक्रमः"}{"प्रकारः"} = "द्वारक्रमः";
            $JsonOutput::module_json{$VerilogParser::module_name}{${instance_no}."_प्रतिरूपम्"}{${instance_port_no}."_द्वारक्रमः"}{"द्वारक्रमः"} = $instance_port_no;
        } elsif ($line1 =~ /^\s*[,)]/) {
            $JsonOutput::module_json{$VerilogParser::module_name}{${instance_no}."_प्रतिरूपम्"}{${instance_port_no}."_द्वारक्रमः"}{"द्वारसंयोजनम्"} = "";
            $JsonOutput::module_json{$VerilogParser::module_name}{${instance_no}."_प्रतिरूपम्"}{${instance_port_no}."_द्वारक्रमः"}{"रूपद्वारम्"} = "";
            $JsonOutput::module_json{$VerilogParser::module_name}{${instance_no}."_प्रतिरूपम्"}{${instance_port_no}."_द्वारक्रमः"}{"प्रकारः"} = "द्वारक्रमः";
            $JsonOutput::module_json{$VerilogParser::module_name}{${instance_no}."_प्रतिरूपम्"}{${instance_port_no}."_द्वारक्रमः"}{"द्वारक्रमः"} = $instance_port_no;
        } else {
            Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Error in CheckType::ordered_port_connection", $line_no);
        }

        while ($line1 =~ /^$/) {   
            $line_no = $line_no+1;
            if ($line_no > $VerilogParser::max_line) {
                Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Max line reached at CheckType::named_port_connection after second_word", $line_no);
            }
            $line1 .= $VerilogParser::verilog_file[$line_no];
            chomp($line1);
            $line1 =~ s/\s*//g;
        }
        if ($line1 =~ s/^\s*\)//) {
            last;
        } elsif ($line1 =~ /^\s*,/) {
            $line1 =~ s/,//;
            while ($line1 =~ /^\s*$/) {   
                $line_no = $line_no+1;
                if ($line_no > $VerilogParser::max_line) {
                    Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Max line reached at CheckType::named_port_connection after second_word", $line_no);
                }
                $line1 .= $VerilogParser::verilog_file[$line_no];
                chomp($line1);
                $line1 =~ s/\s*//g;
            }
        } else {
            Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Error in CheckType::ordered_port_connection with extra bareword $line1", $line_no);
        }

    }
    if ($line1 =~ s/^\s*;\s*$//) {

    } else {
        die "Missing semicolon in instantiation $JsonOutput::module_json{$VerilogParser::module_name}{${instance_no}.\"_प्रतिरूपम्\"}{\"प्रतिरूपनाम\"}";
    }
    return ($line1,$line_no);


}

1;