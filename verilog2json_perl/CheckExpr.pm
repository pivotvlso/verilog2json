package CheckExpr;

use strict;
use warnings;
use utf8;


#sub check_conditional_expr;
sub create_postfix;
sub is_operator;
sub validate_operand;


our %precedence = (
        '~'  => 11, '!' => 11,
        '*'  => 10, '/' => 10, '%' => 10,
        '+'  => 9, '-'  => 9,
        '<<' => 8, '>>' => 8,
        '<'  => 7, '<=' => 7, '>' => 7, '>=' => 7,
        '==' => 6, '!=' => 6,
        '&'  => 5,
        '^'  => 4,
        '|'  => 3,
        '&&' => 2,
        '||' => 1,
        '=' => 0, '+=' =>0, '-=' =>0,
        '?:' => -1,    # ternary operator (lowest)
    );
    # Associativity (default left)
    our %assoc = (
        '~'  => 'right',
        '!'  => 'right',
        '?:' => 'right',
        '='  => 'right',
        '+=' => 'right',
        '-=' => 'right'
    );



sub create_postfix {
    my ($expr) = @_;
    my $i;
    my $j;
    my @stack;
    my @output;
    # Operator precedence (higher number = higher precedence)

    $expr =~ s/;//g;
    my @tokens = $expr =~ /([A-Za-z_]\w*|\d*\'[bodh][a-fA-F0-9]+|\d+|==|!=|<=|>=|=|<<|>>|\?|:|&&|\|\||[+\-*\/%<>&|^!~()?:])/g;
    my $stack_length=-1;
    foreach $i (@tokens) {
        if ($i eq '(') {
            push @stack,$i;
            $stack_length +=1;
        } elsif ($i eq ')') {
            $j = pop @stack;
            $stack_length -= 1;
            if ($j eq '(') {
                Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Error from create_postfix: Brackets empty", -1);
            }
            while ($j ne '(') {
                push @output,$j;
                if (!@stack) {
                    Diagnostics::report_diagnostic("Error", "ERR_FATAL", "Error from create_postfix: No start brackets found", -1);
                }
                $j = pop @stack;
                $stack_length -= 1;
            }
        }  elsif (is_operator($i)) {
            if ($stack_length == -1) {
                push @stack, $i;
                $stack_length += 1;
            } elsif (is_operator($stack[$stack_length])) {
                if ($precedence{$stack[$stack_length]} > $precedence{$i}) {
                    push @output, $i;
                } else {
                    push @stack, $i;
                    $stack_length += 1;
                }
                
            } else {
                push @stack, $i;
                $stack_length += 1;
            }
        } else {
            push @output, $i;
        }
    }
    while (@stack) {
        push @output, pop @stack;
    }
    return @output;
}

sub is_operator {
    my ($tok) = @_;
    return exists $precedence{$tok};
}




1;