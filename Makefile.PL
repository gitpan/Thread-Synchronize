require 5.008;
use threads (); # just to force breakage if threads are not available
use ExtUtils::MakeMaker;

WriteMakefile (
 NAME		=> "Thread::Synchronize",
 AUTHOR		=> 'Elizabeth Mattijsen (liz@dijkmat.nl)',
 ABSTRACT	=> 'synchronize subroutine calls between threads',
 VERSION_FROM	=> 'lib/Thread/Synchronize.pm',
 PREREQ_PM	=> {
                   },
);
