package Diagnostics;

use strict;
use warnings;
use utf8;

our @diagnostics = ();

sub report_diagnostic {
    my ($type, $code, $message, $line_number) = @_;
    push @diagnostics, {
        "type" => $type,
        "code" => $code,
        "message" => $message,
        "line" => $line_number
    };
    if ($type eq "Error") {
        print_diagnostics();
        die;
    }
}

sub print_diagnostics {
    if (scalar @diagnostics > 0) {
        print "\n--- DIAGNOSTICS REPORT ---\n";
        foreach my $diag (@diagnostics) {
            print "$diag->{type} [$diag->{code}]: $diag->{message} (Line $diag->{line})\n";
        }
        print "--------------------------\n\n";
    }
}

1;
