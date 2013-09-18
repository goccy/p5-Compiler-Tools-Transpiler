package Compiler::Tools::Transpiler::Engine::JavaScript;
use strict;
use warnings;
use File::Temp qw/tempfile/;

sub new {
    my ($class) = @_;
    return bless {}, $class;
}

sub transpile {
    my ($self, $llvm_ir) = @_;
    my ($fh, $filename) = tempfile(SUFFIX => '.ll');
    print $fh $llvm_ir;
    close $fh;
    print $filename;
    system "emcc $filename";
    die "cannot execute emcc $@" if ($@);
    open $fh, '<', 'a.out.js';
    my $transpiled_code = do { local $/; <$fh> };
    unlink $_ or die "cannot unlink $_ : $!" foreach qw/a.out.js a.out.js.map/;
    return $transpiled_code;
}

1;
