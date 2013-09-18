# NAME

Compiler::Tools::Transpiler - Transpile Perl5 code to JavaScript code

# SYNOPSIS

    use Compiler::Tools::Transpiler;

    my $filename = $ARGV[0];
    open(my $fh, '<', $filename) or die("$filename could not find.");
    my $perl5_code = do { local $/; <$fh> };
    my $transpiler = Compiler::Tools::Transpiler->new({
        engine => 'JavaScript'
    });
    my $javascript_code = $transpiler->transpile($perl5_code);

# DESCRIPTION

Compiler::Tools::Transpiler transpile Perl5 code to JavaScript code.

# METHODS

- my $transpiler = Compiler::Tools::Transpiler->new($options);

        Create new instance of Compiler::Tools::Transpiler.
- my $javascript\_code = $transpiler->transpile($code);

        Get JavaScript source code.
        This method requires Perl5's source code in string.

# AUTHOR

Masaaki Goshima (goccy) <goccy54@gmail.com>

# COPYRIGHT AND LICENSE

Copyright (C) Masaaki Goshima (goccy).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
