package ModulePort;
use strict;
use VerilogParser;
use JsonOutput;
use Diagnostics;
use warnings;
use utf8;

sub get_ports;
sub populate_port;
sub populate_port_direction;
sub populate_port_varga;
sub populate_wire;
sub populate_reg;
sub populate_interconnect;
our $port_ordering=0;

sub get_ports {
    my ($line_no) = @_;
    my $line1 = $VerilogParser::verilog_file[$line_no];
    while ($line1 !~ /;/) {
        chomp($line1);
        $line_no++;
        if ($line_no > $VerilogParser::max_line) {
            Diagnostics::report_diagnostic("Error", "ERR_MAX_LINE", "Max line reached at ModulePort.pm", $line_no);
        }
        $line1 .= $VerilogParser::verilog_file[$line_no];
        
    }
    chomp ($line1);
    
    # Strip any parameter lists e.g. #(parameter W = 8)
    while ($line1 =~ s/#\s*\((?:[^)(]*(?:\([^)(]*\)[^)(]*)*)*\)//g) {}
    
    if ($line1 =~ /\((.*)\)\s*;/s) {
        my $port_list = $1;
        if (defined $port_list && $port_list !~ /^\s*$/) {
            my @port_array = split (/,/,$port_list);
            foreach my $port (@port_array) {
                populate_port($port, $line_no);
            }
        }
    }
    return $line_no;
}

sub populate_port {
    my ($port_inst, $line_no) = @_;
    my $port_direction;
    $port_inst =~ /([A-Za-z][A-Za-z0-9_]*)(?:\s*\[[^\]]*\])*\s*$/;
    my $port_name = $1;
    $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"प्रकारः"} = "तारः";
    $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"दिशा"} = "";
    $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"निश्चितवर्गः"} = "";
    $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"वर्गः"} = "";
    $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"क्रमः"} = $port_ordering;
    $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"द्वारम्"} = "सत्यम्";
    $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"अवगाढता"} = 0;
    $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"चरणम्"} = [];
    $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"चिह्नितम्"} = "असत्यम्";
    #$JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"आद्यसूचकः"} = 0;
    #$JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"अन्त्यसूचकः"} =0;
    $port_ordering++;
    $port_inst =~ s/\b$port_name\b//;
    if ($port_inst !~ /^\s*$/) {
        populate_port_direction($port_name, $port_inst, $line_no);
    }
    
}
sub populate_port_afterwards {
    my ($line_no) = @_;
    my $line1 = $VerilogParser::verilog_file[$line_no];
    while ($line1 !~ /;/) {
        chomp($line1);
        $line_no++;
        if ($line_no > $VerilogParser::max_line) {
            Diagnostics::report_diagnostic("Error", "ERR_MAX_LINE", "Max line reached at ModulePort.pm", $line_no);
        }
        $line1 .= $VerilogParser::verilog_file[$line_no];
        
    }
    chomp($line1);
    $line1 =~ s/;//;
    my $port_direction;
    $line1 =~ /([A-Za-z][A-Za-z0-9_]*)$/;
    my $port_name = $1;
    $line1 =~ s/$port_name//;
    if ($JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"द्वारम्"} eq "सत्यम्") {
        if ($line1 !~ /^\s*$/) {
            populate_port_direction($port_name, $line1, $line_no);
        }
    } else {
        Diagnostics::report_diagnostic("Error", "ERR_UNDECLARED_PORT", "$port_name not declared", $line_no);
    }
    return $line_no;
    
}

sub populate_port_direction {
    my ($port_name,$port_direction,$line_no, $unpacked_dims) = @_;
    my $matched_port_direction;
    if ($port_direction =~ /input/ ) {
        if ($JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"दिशा"} eq "") {
            $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"दिशा"} = "प्रवेशः";
            $matched_port_direction = "input";
        } else {
            Diagnostics::report_diagnostic("Error", "ERR_PORT_REDECLARATION", "Redeclaration of direction for port $port_name", $line_no);
        }
    } elsif ($port_direction =~ /output/ ) {
        if ($JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"दिशा"} eq "") {
            $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"दिशा"} = "निर्गमः";
            $matched_port_direction = "output";
        } else {
            Diagnostics::report_diagnostic("Error", "ERR_PORT_REDECLARATION", "Redeclaration of direction for port $port_name", $line_no);
        }
    } elsif ($port_direction =~ /inout/ ) {
        if ($JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"दिशा"} eq "") {
            $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"दिशा"} = "प्रवेशनिर्गमः";
            $matched_port_direction = "inout";
        } else {
            Diagnostics::report_diagnostic("Error", "ERR_PORT_REDECLARATION", "Redeclaration of direction for port $port_name", $line_no);
        }
    } else {
        Diagnostics::report_diagnostic("Error", "ERR_PORT_DIRECTION", "Error in port direction (populate_port_direction)", $line_no);
    }
    $port_direction =~ s/$matched_port_direction//;
    if ($port_direction !~ /^\s*$/ || (defined $unpacked_dims && $unpacked_dims !~ /^\s*$/)) {
        populate_port_varga($port_name,$port_direction,"",$line_no, $unpacked_dims);
    }
}

sub populate_port_varga {
    my ($port_name,$port_desc,$initial_value,$line_no, $unpacked_dims) = @_;
    my $matched_port_varga;
    if ($JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"निश्चितवर्गः"} eq "") {
        if ($port_desc =~ /wire/ ) {
            $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"निश्चितवर्गः"} = "स्मृतिरहितम्";
            $port_desc =~ s/wire//;
        } elsif ($port_desc =~ /reg/ ) {
            $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"निश्चितवर्गः"} = "स्मृतिसम्पन्नम्";
            $port_desc =~ s/reg//;
        } elsif ($port_desc =~ /logic/ ) {
            $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"निश्चितवर्गः"} = "स्मृतिसम्पन्नम्";
            $port_desc =~ s/logic//;
        } elsif ($port_desc =~ /integer/ ) {
            $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"निश्चितवर्गः"} = "स्मृतिसम्पन्नम्";
            $port_desc =~ s/integer/signed [31:0]/;
        } elsif ($port_desc =~ /realtime/ ) {
            $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"निश्चितवर्गः"} = "स्मृतिसम्पन्नम्";
            $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"वास्तविकम्"} = "सत्यम्";
            $port_desc =~ s/realtime/signed [63:0]/;
        } elsif ($port_desc =~ /real/ ) {
            $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"निश्चितवर्गः"} = "स्मृतिसम्पन्नम्";
            $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"वास्तविकम्"} = "सत्यम्";
            $port_desc =~ s/real/signed [63:0]/;
        } elsif ($port_desc =~ /time/ ) {
            $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"निश्चितवर्गः"} = "स्मृतिसम्पन्नम्";
            $port_desc =~ s/time/[63:0]/;
        } elsif ($port_desc =~ /parameter/ ) {
            $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"निश्चितवर्गः"} = "स्मृतिसम्पन्नम्";
            $port_desc =~ s/parameter//;
        } elsif ($port_desc =~ /localparam/ ) {
            $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"निश्चितवर्गः"} = "स्मृतिसम्पन्नम्";
            $port_desc =~ s/localparam//;
        } elsif ($port_desc =~ /^\s*(?:signed)?\s*(?:\[[^\]]*\])?\s*$/ ) {
            # Untyped parameter/net, default to wire/reg equivalent type
            $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"निश्चितवर्गः"} = "स्मृतिसम्पन्नम्";
        } else {
            Diagnostics::report_diagnostic("Error", "ERR_MISSING_PORT_DECL", "Missing port declaration", $line_no);
        }
    } else {
        Diagnostics::report_diagnostic("Error", "ERR_WIRE_REDECLARATION", "Attempt to redeclare same wire $port_name in ModulePort", $line_no);
    }

    if ($port_desc =~ s/^\s*signed\b//) {
        $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"चिह्नितम्"} = "सत्यम्";
    } else {
        $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"चिह्नितम्"} = "असत्यम्";
    }
    while ($port_desc =~ /^\s*\[/) {
        if ($port_desc =~ /\[\s*(\d*):(\d*)\s*\]/) {
            $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"अवगाढता"}++;
            my $अस्थायि = $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"अवगाढता"};
            $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{$अस्थायि."_आद्यसूचकः"} = $2;
            $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{$अस्थायि."_अन्त्यसूचकः"} =$1;
            $port_desc =~ s/\[//;
            $port_desc =~ s/\]//;
            $port_desc =~ s/://;
            $port_desc =~ s/$JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{$अस्थायि."_अन्त्यसूचकः"}//;
            $port_desc =~ s/$JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{$अस्थायि."_आद्यसूचकः"}//;

        } else {
            Diagnostics::report_diagnostic("Error", "ERR_PORT_DECLARATION", "Error in port declaration $port_name", $line_no);
        }

    }
    
    $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"अनावृत_अवगाढता"} = [];
    if (defined $unpacked_dims && $unpacked_dims ne "") {
        while ($unpacked_dims =~ /^\s*\[/) {
            if ($unpacked_dims =~ /\[\s*(\d+)\s*:\s*(\d+)\s*\]/) {
                my $lsb = $2;
                my $msb = $1;
                push @{ $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"अनावृत_अवगाढता"} }, { "आद्यसूचकः" => $lsb, "अन्त्यसूचकः" => $msb };
                $unpacked_dims =~ s/\[\s*$msb\s*:\s*$lsb\s*\]//;
            } else {
                Diagnostics::report_diagnostic("Error", "ERR_PORT_DECLARATION", "Error in unpacked declaration $port_name", $line_no);
            }
        }
        if ($unpacked_dims !~ /^\s*$/) {
            Diagnostics::report_diagnostic("Error", "ERR_UNKNOWN_BAREWORD", "Unknown bareword $unpacked_dims in ModulePort::populate_port_varga unpacked", $line_no);
        }
    }
    
    if (defined $initial_value && $initial_value ne "") {
        my $target_bitwidth = 1;
        my $depth = $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"अवगाढता"};
        if (defined $depth && $depth > 0) {
            for (my $i = 1; $i <= $depth; $i++) {
                my $msb = $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{$i."_अन्त्यसूचकः"};
                my $lsb = $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{$i."_आद्यसूचकः"};
                $msb = 0 if !defined $msb || $msb eq "";
                $lsb = 0 if !defined $lsb || $lsb eq "";
                $target_bitwidth *= (abs($msb - $lsb) + 1);
            }
        }
        my ($bin_val, $val_is_signed, $metadata) = convert_to_binary($initial_value, $target_bitwidth, $line_no);
        $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"मूल्यम्"} = $bin_val;
        $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"चिह्नितम्"} = $val_is_signed ? "सत्यम्" : "असत्यम्";
        if (defined $metadata) {
            foreach my $k (keys %$metadata) {
                $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{$k} = $metadata->{$k};
            }
        }
    } else {
        $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"मूल्यम्"} = "";
        $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"चिह्नितम्"} = "असत्यम्";
    }
    if ($port_desc !~ /^\s*$/) {
        Diagnostics::report_diagnostic("Error", "ERR_UNKNOWN_BAREWORD", "Unknown bareword $port_desc in ModulePort::populate_port_varga", $line_no);
    }
    

}

sub populate_interconnect {
    my ($line_no) = @_;
    my $line1 = $VerilogParser::verilog_file[$line_no];
    while ($line1 !~ /;/) {
        chomp($line1);
        $line_no++;
        if ($line_no > $VerilogParser::max_line) {
            Diagnostics::report_diagnostic("Error", "ERR_MAX_LINE", "Max line reached at ModulePort.pm", $line_no);
        }
        $line1 .= $VerilogParser::verilog_file[$line_no];
        
    }
    chomp($line1);
    $line1 =~ s/;//;
    my $initial_value = "";
    if ($line1 =~ s/\s*=\s*(.*?)\s*$//) {
        $initial_value = $1;
    }
    $line1 =~ /([A-Za-z][A-Za-z0-9_]*)(?:\s*\[[^\]]*\])*\s*$/;
    my $port_name = $1;
    my $unpacked_dims = "";
    if ($line1 =~ s/\b$port_name\b(.*)$//) {
        $unpacked_dims = $1;
    }
    
    if (exists $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}) {
        if ($JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"द्वारम्"} eq "सत्यम्") {
            populate_port_varga($port_name,$line1,$initial_value,$line_no, $unpacked_dims);
        } else {
            Diagnostics::report_diagnostic("Error", "ERR_REDECLARATION", "Redeclaration of $port_name", $line_no);
        }

    } else {
        $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"प्रकारः"} = "तारः";
        $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"दिशा"} = "";
        $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"निश्चितवर्गः"} = "";
        $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"वर्गः"} = "";
        $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"क्रमः"} = -1;
        $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"द्वारम्"} = "असत्यम्";
        $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"अवगाढता"} = 0;
        $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"चरणम्"} = [];
        $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"चिह्नितम्"} = "असत्यम्";
        populate_port_varga($port_name, $line1, $initial_value, $line_no, $unpacked_dims);
    }
    return $line_no;
}

sub populate_parameter {
    my ($line_no) = @_;
    my $line1 = $VerilogParser::verilog_file[$line_no];
    while ($line1 !~ /;/) {
        chomp($line1);
        $line_no++;
        if ($line_no > $VerilogParser::max_line) {
            Diagnostics::report_diagnostic("Error", "ERR_MAX_LINE", "Max line reached at ModulePort.pm parameter parsing", $line_no);
        }
        $line1 .= $VerilogParser::verilog_file[$line_no];
    }
    chomp($line1);
    $line1 =~ s/;//;
    
    my $initial_value = "";
    if ($line1 =~ s/\s*=\s*(.*?)\s*$//) {
        $initial_value = $1;
    } else {
        Diagnostics::report_diagnostic("Error", "ERR_PARAM_NO_VALUE", "Parameter declaration missing assigned value", $line_no);
    }
    
    $line1 =~ /([A-Za-z][A-Za-z0-9_]*)(?:\s*\[[^\]]*\])*\s*$/;
    my $port_name = $1;
    my $unpacked_dims = "";
    if ($line1 =~ s/\b$port_name\b(.*)$//) {
        $unpacked_dims = $1;
    }
    
    $line1 =~ s/\b(?:parameter|localparam)\b//g;
    if (exists $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}) {
        Diagnostics::report_diagnostic("Error", "ERR_REDECLARATION", "Redeclaration of parameter $port_name", $line_no);
    } else {
        $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"प्रकारः"} = "प्राचलम्";
        $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"दिशा"} = "";
        $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"निश्चितवर्गः"} = "";
        $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"वर्गः"} = "";
        $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"क्रमः"} = -1;
        $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"द्वारम्"} = "असत्यम्";
        $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"अवगाढता"} = 0;
        $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"चरणम्"} = [];
        $JsonOutput::module_json{$VerilogParser::module_name}{$port_name}{"चिह्नितम्"} = "असत्यम्";
        populate_port_varga($port_name, $line1, $initial_value, $line_no, $unpacked_dims);
    }
    return $line_no;
}
sub populate_reg {
    my ($line_no) = @_;
    my $line1 = $VerilogParser::verilog_file[$line_no];
    while ($line1 !~ /;/) {
        chomp($line1);
        $line_no++;
        if ($line_no > $VerilogParser::max_line) {
            Diagnostics::report_diagnostic("Error", "ERR_MAX_LINE", "Max line reached at ModulePort.pm", $line_no);
        }
        $line1 .= $VerilogParser::verilog_file[$line_no];
        
    }
    chomp($line1);
    $line1 =~ s/;//;
    my $first_width =0;
    my $last_width = 0;
    $line1 =~ s/\s*reg//;
    $line1 =~ s/\s//g;
    if ($line1 =~ /\[(\d+):(\d+)\]/) {
       $last_width = $1;
       $first_width = $2;
       $line1 =~ s/${last_width}:${first_width}//;
    }
    $line1 =~ s/;$//;
    my @wires = split(/,/, $line1);
    for (my $i = 0; $i < scalar @wires; $i=$i+1) {
        $JsonOutput::module_json{$VerilogParser::module_name}{$wires[$i]}{"प्रकारः"} = "तारः";
        $JsonOutput::module_json{$VerilogParser::module_name}{$wires[$i]}{"निश्चितवर्गः"} = "स्मृतिसम्पन्नम्";
    }

    return $line_no;

}

sub populate_wire {
    my ($line_no) = @_;
    my $line1 = $VerilogParser::verilog_file[$line_no];
    while ($line1 !~ /;/) {
        chomp($line1);
        $line_no++;
        if ($line_no > $VerilogParser::max_line) {
            Diagnostics::report_diagnostic("Error", "ERR_MAX_LINE", "Max line reached at ModulePort.pm", $line_no);
        }
        $line1 .= $VerilogParser::verilog_file[$line_no];
        
    }
    chomp($line1);
    $line1 =~ s/;//;
    my $first_width =0;
    my $last_width = 0;
    $line1 =~ s/\s*wire//;
    $line1 =~ s/\s//g;
    if ($line1 =~ /\[(\d+):(\d+)\]/) {
       $last_width = $1;
       $first_width = $2;
       $line1 =~ s/${last_width}:${first_width}//;
    }
    $line1 =~ s/;$//;
    my @wires = split(/,/, $line1);
    for (my $i = 0; $i < scalar @wires; $i=$i+1) {
        $JsonOutput::module_json{$VerilogParser::module_name}{$wires[$i]}{"प्रकारः"} = "तारः";
        $JsonOutput::module_json{$VerilogParser::module_name}{$wires[$i]}{"निश्चितवर्गः"} = "स्मृतिरहितम्";
    }

    return $line_no;

}

sub parse_array_literal {
    my ($val, $target_size, $line_no) = @_;
    $val =~ s/^\s*'\{\s*//;
    $val =~ s/\s*\}\s*$//;
    
    my @elements = ();
    my $depth = 0;
    my $current = "";
    for (my $i = 0; $i < length($val); $i++) {
        my $char = substr($val, $i, 1);
        if ($char eq '{') {
            $depth++;
            $current .= $char;
        } elsif ($char eq '}') {
            $depth--;
            $current .= $char;
        } elsif ($char eq ',' && $depth == 0) {
            push @elements, $current;
            $current = "";
        } else {
            $current .= $char;
        }
    }
    push @elements, $current if $current ne "";
    
    my @parsed_elements = ();
    my $any_signed = "असत्यम्";
    foreach my $elem (@elements) {
        $elem =~ s/^\s+|\s+$//g;
        my ($parsed, $signed, $meta) = convert_to_binary($elem, $target_size, $line_no);
        $any_signed = 1 if $signed;
        push @parsed_elements, $parsed;
        $any_signed = "सत्यम्" if $signed eq "सत्यम्";
    }
    
    return (\@parsed_elements, $any_signed);
}

sub convert_to_binary {
    my ($val, $target_size, $line_no) = @_;
    
    # Parse unpacked array literals dynamically
    if ($val =~ /^\s*'\{/) {
        return parse_array_literal($val, $target_size, $line_no);
    }

    # Parse time literals (e.g. 2ns, 1.5us)
    if ($val =~ /^\s*([\d\.]+)\s*(s|ms|us|ns|ps|fs)\s*$/) {
        my $num = $1;
        my $unit = $2;
        # Evaluate to 64-bit unsigned binary integer
        my $bin_str = sprintf("%064b", int($num));
        return ($bin_str, 0, { "कालम्" => "सत्यम्", "काल_एककम्" => $unit }); 
    }

    # Parse floating-point literals (e.g. 1.23, 123.4e-2)
    if ($val =~ /^\s*[-+]?[0-9]*\.[0-9]+(?:[eE][-+]?[0-9]+)?\s*$/ || $val =~ /^\s*[-+]?[0-9]+[eE][-+]?[0-9]+\s*$/) {
        my $float_val = $val + 0; # enforce numeric context
        # Pack to big-endian IEEE 754 64-bit double precision float
        my $bin_str = unpack("B64", scalar reverse pack("d", $float_val));
        return ($bin_str, 1, { "वास्तविकम्" => "सत्यम्", "वास्तविक_मूल्यम्" => "$float_val" }); # reals are inherently signed
    }

    $val =~ s/_//g;
    
    # Replace ? with z for standard verilog parsing
    $val =~ s/\?/z/g;
    
    my $is_signed = 0;
    
    if ($val =~ /^\s*(-)?\s*(?:(\d*)')?([sS])?([bBoOdDhH])?(.*)$/) {
        my $is_negative = defined $1 && $1 ne "" ? 1 : 0;
        my $size = $2;
        my $signed_modifier = $3;
        my $base = lc($4 || 'd');
        my $num = lc($5);
        
        $is_signed = $is_negative;
        
        if (defined $signed_modifier && $signed_modifier ne "") {
            $is_signed = 1;
        }

        my $bin_str = "";
        
        if ($base eq 'b') {
            if ($num !~ /^[01xz]+$/) {
                Diagnostics::report_diagnostic("Error", "ERR_INVALID_LITERAL", "Invalid character in binary literal '$val' in ModulePort", $line_no);
            }
            $bin_str = $num;
        } elsif ($base eq 'h') {
            if ($num !~ /^[0-9a-fxz]+$/) {
                Diagnostics::report_diagnostic("Error", "ERR_INVALID_LITERAL", "Invalid character in hexadecimal literal '$val' in ModulePort", $line_no);
            }
            my %h2b = (
                '0' => '0000', '1' => '0001', '2' => '0010', '3' => '0011',
                '4' => '0100', '5' => '0101', '6' => '0110', '7' => '0111',
                '8' => '1000', '9' => '1001', 'a' => '1010', 'b' => '1011',
                'c' => '1100', 'd' => '1101', 'e' => '1110', 'f' => '1111',
                'x' => 'xxxx', 'z' => 'zzzz'
            );
            foreach my $char (split //, $num) {
                $bin_str .= $h2b{$char} if exists $h2b{$char};
            }
        } elsif ($base eq 'o') {
            if ($num !~ /^[0-7xz]+$/) {
                Diagnostics::report_diagnostic("Error", "ERR_INVALID_LITERAL", "Invalid character in octal literal '$val' in ModulePort", $line_no);
            }
            my %o2b = (
                '0' => '000', '1' => '001', '2' => '010', '3' => '011',
                '4' => '100', '5' => '101', '6' => '110', '7' => '111',
                'x' => 'xxx', 'z' => 'zzz'
            );
            foreach my $char (split //, $num) {
                $bin_str .= $o2b{$char} if exists $o2b{$char};
            }
        } elsif ($base eq 'd') {
            if ($num !~ /^[0-9xz]+$/) {
                Diagnostics::report_diagnostic("Error", "ERR_INVALID_LITERAL", "Invalid character in decimal literal '$val' in ModulePort", $line_no);
            }
            if ($num =~ /^[0-9]+$/) {
                $bin_str = sprintf("%b", $num);
            } else {
                return ($num, $is_signed);
            }
        }
        
        # 1. Base Padding
        my $working_size = defined $size ? $size : (defined $target_size ? $target_size : 32);
        
        my $len = length($bin_str);
        if ($len < $working_size) {
            my $pad_char = '0';
            if ($num =~ /^[xz]$/) { $pad_char = $num; }
            $bin_str = ($pad_char x ($working_size - $len)) . $bin_str;
        } elsif ($len > $working_size) {
            $bin_str = substr($bin_str, -$working_size);
        }
        
        # 2. Two's complement for negatives
        if ($is_negative) {
            $bin_str =~ tr/01/10/;
            my $carry = 1;
            for (my $i = length($bin_str) - 1; $i >= 0; $i--) {
                my $bit = substr($bin_str, $i, 1);
                if ($bit eq '0') {
                    substr($bin_str, $i, 1) = '1' if $carry;
                    $carry = 0;
                } elsif ($bit eq '1') {
                    substr($bin_str, $i, 1) = '0' if $carry;
                }
            }
        }
        
        # 3. Target size adjustment (if $size was defined, we might need to stretch to $target_size)
        if (defined $size && defined $target_size && $size != $target_size) {
            my $final_len = length($bin_str);
            if ($final_len < $target_size) {
                my $pad_char = '0';
                if ($num =~ /^[xz]$/) { 
                    $pad_char = $num; 
                } elsif ($is_signed) {
                    $pad_char = substr($bin_str, 0, 1);
                }
                $bin_str = ($pad_char x ($target_size - $final_len)) . $bin_str;
            } elsif ($final_len > $target_size) {
                $bin_str = substr($bin_str, -$target_size);
            }
        }

        return ($bin_str, $is_signed);
    }
    return ($val, $is_signed);
}

1;
