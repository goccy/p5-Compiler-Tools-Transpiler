package Compiler::Tools::Transpiler;
use 5.008_001;
use strict;
use warnings;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Compiler::CodeGenerator::LLVM;
use Compiler::Tools::Transpiler::Engine;

our $VERSION = '0.01';

sub new {
    my ($class, $options) = @_;
    my $engine_name = $options->{engine} || 'JavaScript';
    my $self = {
        input  => $options->{input}  || '-',
        output => $options->{output} || 'transpiled.ll',
        debug  => $options->{debug}  || 0,
        engine => Compiler::Tools::Transpiler::Engine->new($engine_name),
        library_path => $options->{library_path} || \@INC
    };
    return bless $self, $class;
}

sub transpile {
    my ($self, $code) = @_;
    my $llvm_ir = $self->__compile($code);
    return $self->{engine}->transpile($llvm_ir);
}

sub debug_run {
    my ($self, $code) = @_;
    my $ast = $self->__make_ast($code);
    pipe(my $reader, my $writer);
    select($writer);
    select STDOUT;
    local $| = 1;

    my $generator = Compiler::CodeGenerator::LLVM->new();
    my @captured_results;
    if (my $pid = fork()) {
        close $writer;
        waitpid($pid, 0);
        push @captured_results, map {
            chomp($_); $_;
        } <$reader>;
    } else {
        close $reader;
        open STDOUT, '>&', $writer;
        $generator->debug_run($ast);
        exit;
    }
    return \@captured_results;
}

sub __compile {
    my ($self, $code) = @_;
    my $ast = $self->__make_ast($code);
    my $generator = Compiler::CodeGenerator::LLVM->new();
    return $generator->generate($ast);
}

sub __make_ast {
    my ($self, $code) = @_;
    return $self->{ast} if ($self->{ast});

    my $lexer = Compiler::Lexer->new($self->{input});
    my $parser = Compiler::Parser->new();
    $lexer->set_library_path($self->{library_path});
    my $results = $lexer->recursive_tokenize($code);

    my %ast;
    foreach my $module_name (keys %$results) {
        my $tokens = $results->{$module_name};
        next unless @$tokens;
        $ast{$module_name} = $parser->parse($tokens);
    }
    $parser->link_ast(\%ast);
    my $main_ast = $ast{main};

    if ($self->{debug}) {
        my $renderer = Compiler::Parser::AST::Renderer->new();
        $renderer->render($main_ast);
    }

    $self->{ast} = $main_ast;
    return $main_ast;
}

1;
__END__

=head1 NAME

Compiler::Tools::Transpiler - Transpile Perl5 code to JavaScript code

=head1 SYNOPSIS

    use Compiler::Tools::Transpiler;

    my $filename = $ARGV[0];
    open(my $fh, '<', $filename) or die("$filename could not find.");
    my $perl5_code = do { local $/; <$fh> };
    my $transpiler = Compiler::Tools::Transpiler->new({
        engine => 'JavaScript'
    });
    my $javascript_code = $transpiler->transpile($perl5_code);

=head1 DESCRIPTION

Compiler::Tools::Transpiler transpile Perl5 code to JavaScript code.

=head1 METHODS

=over

=item my $transpiler = Compiler::Tools::Transpiler->new($options);

    Create new instance of Compiler::Tools::Transpiler.

=item my $javascript_code = $transpiler->transpile($code);

    Get JavaScript source code.
    This method requires Perl5's source code in string.

=back

=head1 AUTHOR

Masaaki Goshima (goccy) <goccy54@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) Masaaki Goshima (goccy).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
