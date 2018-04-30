package Text::Markdown::GFM::FFI;
use strict;
use warnings;

use Alien::libcmark_gfm;
use FFI::Platypus;
use FFI::Platypus::Buffer qw( scalar_to_buffer buffer_to_scalar );
use Exporter qw(import);

our @EXPORT_OK = qw(
    cmark_parser_new
);

my $ffi = FFI::Platypus->new(
    lib => [Alien::libcmark_gfm->dynamic_libs],
);

$ffi->package;

my %OPTIONS = (
    default                       => 0,
    sourcepos                     => ( 1 << 1 ),
    hardbreaks                    => ( 1 << 2 ),
    safe                          => ( 1 << 3 ),
    nobreaks                      => ( 1 << 4 ),
    normalize                     => ( 1 << 8 ),
    validate_utf8                 => ( 1 << 9 ),
    smart                         => ( 1 << 10 ),
    github_pre_lang               => ( 1 << 11 ),
    liberal_html_tag              => ( 1 << 12 ),
    footnotes                     => ( 1 << 13 ),
    strikethrough_double_tilde    => ( 1 << 14 ),
    table_prefer_style_attributes => ( 1 << 15 ),
);

$ffi->attach('core_extensions_ensure_registered' => [] => 'void');

$ffi->attach(cmark_markdown_to_html => ['opaque', 'int', 'int'] => 'string',
    sub {
        my $c_func = shift;
         my($markdown, $markdown_length) = scalar_to_buffer $_[0];
         my $option_hash = $_[1];
         my $options = 0;
         foreach my $key (keys %OPTIONS) {
             if ($option_hash->{$key}) {
                 $options |= $OPTIONS{$key};
             }
         }
         return $c_func->($markdown, $markdown_length, $options);
    }
);

$ffi->attach(cmark_parser_new => [ 'int' ] => 'opaque');

core_extensions_ensure_registered();

1;

__END__
