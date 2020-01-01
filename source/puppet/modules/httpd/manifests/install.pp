class httpd::install {

    package{ ["httpd", "perl-XML-Simple", 'perl-JSON', 'perl-Clone', 'perl-Template-Toolkit', 'perl-Module-Build', 'perl-YAML']:
        ensure =>present,
    }


    file { "/root/.cpan":
      ensure => "directory",
      owner  => "root",
      group  => "root",
      mode   => 700,
    }

#    $my_modules= ['Module::Build', 'Date::Parse', 'Test::More', 'Lingua::Conjunction', 'Lingua::EN::Conjugate', 'Lingua::EN::Gender', 'Lingua::EN::Numbers', 'Lingua::EN::Titlecase', 'Math::Complex', 'Math::Trig', 'Number::Format', 'Template::Plugin::Lingua::EN::Inflect', 'Test::Exception', 'Lingua::EN::Inflect::Number', 'Lingua::EN::Inflect', 'XML::Simple', 'Template', 'Test::Harness', 'Clone', 'Email::Date::Format', 'List::MoreUtils', 'JSON', 'CGI' ]
#      cpan { $my_modules :
#        ensure => present,
#        require => Package['perl-CPAN'],
#      }


    define cpanMod {
      exec { "install $name":
        command => "cpan -if $name ",
        unless  => "perl -e 'require  $name; '",
        timeout => 300, 
        cwd =>'/root',
        logoutput =>true,
        returns =>[0],
        user    =>'root',
        path =>[ '/sbin','/bin','/usr/sbin','/usr/bin' ],
        require => Package['perl-CPAN', 'perl-XML-Simple', 'perl-JSON', 'perl-Clone', 'perl-Template-Toolkit','perl-Module-Build', 'perl-YAML'],
      }
    }


    $my_modules= [ 'Date::Parse', 'Number::Format', 'List::MoreUtils','Test::More', 'Lingua::Conjunction', 'Lingua::EN::Conjugate', 'Lingua::EN::Gender', 'Lingua::EN::Numbers', 'Lingua::EN::Titlecase', 'Template::Plugin::Lingua::EN::Inflect', 'Test::Exception', 'Lingua::EN::Inflect::Number', 'Lingua::EN::Inflect', 'Test::Harness', 'Email::Date::Format', ]
    cpanMod{ $my_modules : }

}
