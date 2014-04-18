use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  VERSION   => '0.01',
  PREREQ_PM => {'Mojolicious' => '4.83',
                'XML::Feed' => '0',
                'Net::GitHub::V3' => '0',
                'DateTime::Format::ISO8601' => '0'
               },
  test      => {TESTS => 't/*.t'}
);
