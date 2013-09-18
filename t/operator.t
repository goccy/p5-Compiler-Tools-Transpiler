use strict;
use warnings;
use Test::More;
use Compiler::Tools::Transpiler;

my $code = do { local $/; <DATA> };
my $transpiler = Compiler::Tools::Transpiler->new({
    engine => 'JavaScript'
});
my $transed_code = $transpiler->transpile($code);


__DATA__
say undef;
say 1;
say 2;
say 1 + 2 == 3;
say 1.2;
say 1.2 + 2.3 == 3.5;
say 2.1 + 2 == 4.1;
say 1 - 2 == -1;
say 1.3 - 2 == -0.7;
say 1.3 * 2 == 2.6;
say 1.3 * -2 == -2.6;
say 1.3 / 2 == 0.65;
say 1.3 / -2 == -0.65;
say 1 != 2;
say 1.2 != 2.4;
say 2 > 1;
say 1 < 2;
say 1 & 2;
say 0 & 1;

my $a = 1;
my $b = 2;
say $a;
say $a + 2;
say 2 + $b;
say $a + 2.1;
say 2.1 + $b;
