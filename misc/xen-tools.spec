Name:           xen-tools
Version:        3.6
Release:        1%{?dist}
Summary:        Scripts used to create new Xen domains

Group:          Applications/Emulators
License:        GPLv2 or Artistic
URL:            http://xen-tools.org/software/xen-tools/
Source0:        http://xen-tools.org/software/xen-tools/xen-tools-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildArch:      noarch
Requires:       perl perl-Text-Template perl-Config-IniFiles perl-Expect
AutoReqProv:    no

%description
xen-tools is a collection of simple perl scripts which allow you to
easily create new guest Xen domains.

%prep
%setup -q


%build


%install
rm -rf $RPM_BUILD_ROOT
make install prefix=$RPM_BUILD_ROOT


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/etc/xen-tools
/etc/bash_completion.d/*
/usr/bin/*
/usr/share/man/man8/*
/usr/lib/xen-tools


%changelog
* Wed Jul 25 2007 Gordon Messmer <gmessmer@ee.washington.edu>
- Initial build

