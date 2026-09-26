package SemanticChecker;
use strict;
use warnings;
use utf8;
use Diagnostics;

sub validate_assignment {
    my ($lhs, $line_no) = @_;
    
    # Strip spaces
    $lhs =~ s/\s*//g;
    
    # Extract root variable and indices
    my $var_name;
    my @indices = ();
    
    if ($lhs =~ /^([A-Za-z_]\w*)(.*)$/) {
        $var_name = $1;
        my $remainder = $2;
        
        while ($remainder =~ s/^\[([^\]]+)\]//) {
            push @indices, $1;
        }
    } else {
        return; # Could not parse LHS
    }
    
    # Check if variable exists in symbol table
    if (!exists $JsonOutput::module_json{$VerilogParser::module_name}{$var_name}) {
        return;
    }
    
    my $var_data = $JsonOutput::module_json{$VerilogParser::module_name}{$var_name};
    
    # Count expected unpacked dimensions
    my $unpacked_dims = 0;
    if (exists $var_data->{"अनावृत_अवगाढता"}) {
        $unpacked_dims = scalar @{$var_data->{"अनावृत_अवगाढता"}};
    }
    
    # Rule 1: Full Array Write check
    my $provided_indices = scalar @indices;
    
    if ($unpacked_dims > 0) {
        if ($provided_indices < $unpacked_dims) {
            Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Illegal Syntax: Attempt to write to entire array or array slice without fully indexing unpacked dimensions for '$var_name'", $line_no);
        }
        
        # Rule 2: Part Select on Unpacked dimensions
        # A part select looks like [msb:lsb]
        for (my $i = 0; $i < $provided_indices; $i++) {
            my $index_str = $indices[$i];
            if ($index_str =~ /:/) { # It's a slice/part-select
                if ($i < $unpacked_dims) {
                    Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Illegal Syntax: Attempt to use part-select on unpacked dimension of '$var_name'", $line_no);
                }
            }
        }
    }
}

sub validate_continuous_assignment {
    my ($lhs, $line_no) = @_;
    
    if ($lhs =~ /^\{/) {
        my $stripped = $lhs;
        $stripped =~ s/[\{\}]//g;
        my @parts = split(/,/, $stripped);
        foreach my $part (@parts) {
            validate_continuous_assignment($part, $line_no);
        }
        return;
    }
    
    $lhs =~ s/\s*//g;
    
    my $var_name;
    if ($lhs =~ /^([A-Za-z_]\w*)(.*)$/) {
        $var_name = $1;
    } else {
        return;
    }
    
    if (!exists $JsonOutput::module_json{$VerilogParser::module_name}{$var_name}) {
        return;
    }
    
    my $var_data = $JsonOutput::module_json{$VerilogParser::module_name}{$var_name};
    
    if (exists $var_data->{"निश्चितवर्गः"} && $var_data->{"निश्चितवर्गः"} eq "स्मृतिसम्पन्नम्") {
        Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Illegal Syntax: Continuous assignment to a reg/variable type '$var_name' is not allowed.", $line_no);
    }
}

1;
