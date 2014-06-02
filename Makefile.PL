use 5.014002;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Locale::Babelfish',
    VERSION_FROM      => 'lib/Locale/Babelfish.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Locale/Babelfish.pm', # retrieve abstract from module
       AUTHOR         => 'Mironov Igor <grif@cpan.org>') : ()),
);
