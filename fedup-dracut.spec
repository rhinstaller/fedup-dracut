%global dracutmoddir %{_prefix}/lib/dracut

Name:       fedup-dracut
Version:    0.7
Release:    1%{?dist}
Summary:    the Fedora Upgrade tool

License:    GPLv2+
URL:        http://github.com/wgwoods/fedup
Source0:    %{name}-%{version}.tar.xz

Summary:        initramfs environment for system upgrades
BuildRequires:  rpm-devel >= 4.10.0
BuildRequires:  glib2-devel
#BuildRequires: plymouth-devel >= 0.8.6
Requires:       rpm >= 4.10.0
Requires:       plymouth >= 0.8.6
Requires:       dracut

%package plymouth
BuildRequires:  plymouth-devel
BuildArch:      noarch
Requires:       plymouth
Summary:        plymouth theme for system upgrade progress

%description
These dracut modules provide the framework for upgrades and the tool that
actually runs the upgrade itself.

%description plymouth
The plymouth theme used during system upgrade.


%prep
%setup -q


%build
make %{?_smp_mflags} CFLAGS="%{optflags}"


%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT \
             LIBEXECDIR=%{_libexecdir} \
             DRACUTMODDIR=%{dracutmoddir}

%files
%{_libexecdir}/system-upgrade-fedora
%{dracutmoddir}/85system-upgrade-fedora
%{dracutmoddir}/90system-upgrade

%files plymouth
%{_datadir}/plymouth/themes/fedup


%changelog
* Wed Oct 24 2012 Will Woods <wwoods@redhat.com> 0.7-1
- Initial packaging
