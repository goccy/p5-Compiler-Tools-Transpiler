package Compiler::Tools::Transpiler::Engine;
use strict;
use warnings;

sub new {
    my ($self, $engine_name) = @_;
    my $class = "Compiler/Tools/Transpiler/Engine/$engine_name";
    require "$class.pm";
    $class =~ s|/|::|g;
    return $class->new();

}

1;
