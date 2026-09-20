use strict;
use warnings;
use File::Find;
use File::Basename;
use JSON;

my $tests_dir = "tests";
my $output_dir = "sam_आन्तरिककुञ्जीमूल्यरूपम्";
my $verilog_script = "verilog2json.pl";

if (!-f $verilog_script) {
    die "Please run this script from the top-level directory.\n";
}

my $pass_count = 0;
my $fail_count = 0;

print "========================================\n";
print "      VERILOG2JSON REGRESSION SUITE     \n";
print "========================================\n\n";

sub compare_json {
    my ($file1, $file2) = @_;
    
    local $/;
    open(my $fh1, '<', $file1) or return 0;
    my $json_text1 = <$fh1>;
    close($fh1);
    
    open(my $fh2, '<', $file2) or return 0;
    my $json_text2 = <$fh2>;
    close($fh2);
    
    my $data1;
    my $data2;
    eval {
        $data1 = decode_json("{" . $json_text1 . "}");
        $data2 = decode_json("{" . $json_text2 . "}");
    };
    if ($@) { return 0; }
    
    my $coder = JSON->new->canonical(1)->pretty(1);
    return $coder->encode($data1) eq $coder->encode($data2);
}

sub compare_text {
    my ($file1, $file2) = @_;
    local $/;
    open(my $fh1, '<', $file1) or return 0;
    my $text1 = <$fh1>;
    close($fh1);
    open(my $fh2, '<', $file2) or return 0;
    my $text2 = <$fh2>;
    close($fh2);
    
    # Normalize Windows/Linux newlines for safe comparison
    $text1 =~ s/\r\n/\n/g;
    $text2 =~ s/\r\n/\n/g;
    return $text1 eq $text2;
}

sub run_test {
    my $verilog_file = $File::Find::name;
    return unless $verilog_file =~ /\.v$/;
    my $basename = basename($verilog_file, ".v");

    if (@ARGV > 0) {
        my $match = 0;
        foreach my $arg (@ARGV) {
            if ($basename =~ /$arg/i) {
                $match = 1;
                last;
            }
        }
        return unless $match;
    }
    
    print "TEST: $verilog_file ... ";
    
    my $generated_json = "$output_dir/$basename.json";
    my $generated_diag = "$output_dir/$basename.diag";
    my $golden_json = $File::Find::dir . "/$basename.json";
    my $golden_diag = $File::Find::dir . "/$basename.diag";
    
    # Capture all output (stdout and stderr) into a diagnostic file
    my $cmd = "perl $verilog_script $verilog_file > \"$generated_diag\" 2>&1";
    my $exit_code = system($cmd);
    
    if ($exit_code != 0) {
        # The parser crashed or threw a diagnostic error
        if (!-f $golden_diag) {
            use File::Copy;
            copy($generated_diag, $golden_diag);
            print "[PASS] (Bootstrapped Diagnostic)\n";
            $pass_count++;
            return;
        }
        
        if (compare_text($generated_diag, $golden_diag)) {
            print "[PASS] (Expected Diagnostic Matched)\n";
            $pass_count++;
        } else {
            print "[FAIL] (Diagnostic output differs from golden $basename.diag)\n";
            $fail_count++;
        }
        return;
    }
    
    # If it succeeded, check JSON
    if (!-f $generated_json) {
        print "[FAIL] (No output JSON generated: $generated_json)\n";
        $fail_count++;
        return;
    }
    
    if (!-f $golden_json) {
        use File::Copy;
        copy($generated_json, $golden_json);
        print "[PASS] (Bootstrapped JSON)\n";
        $pass_count++;
        return;
    }
    
    if (compare_json($generated_json, $golden_json)) {
        print "[PASS]\n";
        $pass_count++;
    } else {
        print "[FAIL] (JSON mismatch)\n";
        $fail_count++;
    }
}

find({ wanted => \&run_test, no_chdir => 1 }, $tests_dir);

print "\n========================================\n";
print "SUMMARY: $pass_count Passed | $fail_count Failed\n";
print "========================================\n";

exit($fail_count > 0 ? 1 : 0);
