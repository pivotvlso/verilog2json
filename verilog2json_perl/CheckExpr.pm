package CheckExpr;

use strict;
use warnings;
use utf8;


#sub check_conditional_expr;
sub create_postfix;
sub is_operator;
sub validate_operand;


our %precedence = (
        '~'  => 11, '!' => 11, '~&' => 11, '~|' => 11, '~^' => 11, '^~' => 11,
        'U+' => 11, 'U-' => 11, 'U&' => 11, 'U|' => 11, 'U^' => 11,
        '*'  => 10, '/' => 10, '%' => 10,
        '+'  => 9, '-'  => 9,
        '<<' => 8, '>>' => 8,
        '<'  => 7, '<=' => 7, '>' => 7, '>=' => 7,
        '==' => 6, '!=' => 6, '===' => 6, '!==' => 6,
        '&'  => 5,
        '^'  => 4,
        '|'  => 3,
        '&&' => 2,
        '||' => 1,
        '=' => 0, '+=' =>0, '-=' =>0,
        '?:' => -1, ':' => -1, '+:' => -1, '-:' => -1,
    );
    # Associativity (default left)
    our %assoc = (
        '~'  => 'right',
        '!'  => 'right',
        '~&' => 'right',
        '~|' => 'right',
        '~^' => 'right',
        '^~' => 'right',
        'U+' => 'right',
        'U-' => 'right',
        'U&' => 'right',
        'U|' => 'right',
        'U^' => 'right',
        '?:' => 'right', ':' => 'right', '+:' => 'right', '-:' => 'right',
        '='  => 'right',
        '+=' => 'right',
        '-=' => 'right'
    );



sub create_postfix {
    my ($expr, $line_no) = @_;
    my $i;
    my $j;
    my @stack;
    my @output;
    # Operator precedence (higher number = higher precedence)

    $expr =~ s/;//g;
    my @tokens = $expr =~ /([A-Za-z_]\w*|\d*\'[sS]?[bodhBODH][a-fA-F0-9xXzZ_]+|\d+|\*\*|<<<|>>>|===|!==|==|!=|<=|>=|=|<<|>>|\+:|\-:|\?|:|&&|\|\||~&|~\||~\^|\^~|[+\-*\/%<>&|^!~()?:{}\[\],])/g;
    my $stack_length=-1;
    my $prev_was_operand = 0;
    foreach $i (@tokens) {
        if ($i =~ /^(?:\*\*|<<<|>>>)$/) {
            Diagnostics::report_diagnostic("Error", "ERR_UNSUPPORTED_OPERATOR", "Unsupported operator $i", $line_no);
            $prev_was_operand = 0;
        } elsif ($i eq '(' || $i eq '[') {
            push @stack,$i;
            $stack_length +=1;
            $prev_was_operand = 0;
        } elsif ($i eq '{') {
            if ($prev_was_operand) {
                push @stack, "आवृत्तिः";
                $stack_length +=1;
            }
            push @stack, "{1";
            $stack_length +=1;
            $prev_was_operand = 0;
        } elsif ($i eq ',') {
            $j = pop @stack;
            $stack_length -= 1;
            while (defined $j && $j !~ /^\{\d+$/) {
                push @output, $j;
                $j = pop @stack;
                $stack_length -= 1;
            }
            if (!defined $j) {
                Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Error from create_postfix: Comma outside concatenation", $line_no);
            } elsif ($j =~ /^\{(\d+)$/) {
                my $n = $1 + 1;
                push @stack, "{$n";
                $stack_length += 1;
            }
            $prev_was_operand = 0;
        } elsif ($i eq ')' || $i eq ']' || $i eq '}') {
            my $match = $i eq ')' ? '(' : ($i eq ']' ? '[' : '{');
            $j = pop @stack;
            $stack_length -= 1;
            while (defined $j && ($match eq '{' ? ($j !~ /^\{\d+$/) : ($j ne $match))) {
                push @output,$j;
                if (!@stack) {
                    Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Error from create_postfix: No start brackets found", $line_no);
                }
                $j = pop @stack;
                $stack_length -= 1;
            }
            if ($i eq ']') {
                push @output, "सूचकः";
            } elsif ($i eq '}') {
                if ($j =~ /^\{(\d+)$/) {
                    push @output, "शृङ्खला$1";
                }
                if ($stack_length >= 0 && $stack[$stack_length] eq "आवृत्तिः") {
                    push @output, pop @stack;
                    $stack_length -= 1;
                }
            }
            $prev_was_operand = 1;
        }  elsif (is_operator($i)) {
            if (!$prev_was_operand && $i =~ /^[+\-&|^]$/) {
                $i = "U$i";
            }
            while ($stack_length >= 0 && is_operator($stack[$stack_length])) {
                my $top = $stack[$stack_length];
                # Since all our binary operators are left associative except assignments, and unary are right.
                # If top has strictly greater precedence, pop.
                # If equal precedence, pop if left associative.
                my $assoc_i = exists $assoc{$i} ? $assoc{$i} : 'left';
                if ($precedence{$top} > $precedence{$i} || 
                   ($precedence{$top} == $precedence{$i} && $assoc_i eq 'left')) {
                    push @output, pop @stack;
                    $stack_length -= 1;
                } else {
                    last;
                }
            }
            push @stack, $i;
            $stack_length += 1;
            $prev_was_operand = 0;
        } else {
            push @output, $i;
            $prev_was_operand = 1;
        }
    }
    while (@stack) {
        my $top = pop @stack;
        if ($top eq '(' || $top eq '[' || $top =~ /^\{\d+$/) {
            Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Unmatched bracket in expression", $line_no);
        }
        push @output, $top;
    }
    return @output;
}

sub is_operator {
    my ($tok) = @_;
    return exists $precedence{$tok};
}




1;