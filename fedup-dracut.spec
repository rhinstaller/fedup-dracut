%global dracutmoddir %{_prefix}/lib/dracut/modules.d
%global plymouthver 0.8.6

Name:       fedup-dracut
Version:    0.7.2
Release:    1%{?dist}
Summary:    The Fedora Upgrade tool initramfs environment

License:    GPLv2+
URL:        https://github.com/wgwoods/fedup-dracut
Source0:    https://github.com/downloads/wgwoods/fedup-dracut/%{name}-%{version}.tar.xz

Summary:        initramfs environment for system upgrades
BuildRequires:  rpm-devel >= 4.10.0
BuildRequires:  plymouth-devel >= %{plymouthver}
BuildRequires:  glib2-devel
Requires:       rpm >= 4.10.0
Requires:       plymouth >= %{plymouthver}
Requires:       systemd >= 195-8
Requires:       dracut

%package plymouth
BuildRequires:  plymouth-devel
BuildArch:      noarch
Requires:       plymouth-plugin-two-step >= %{plymouthver}
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
%doc README.asciidoc TODO.asciidoc COPYING
%{_libexecdir}/system-upgrade-fedora
%{dracutmoddir}/85system-upgrade-fedora
%{dracutmoddir}/90system-upgrade

%files plymouth
%{_datadir}/plymouth/themes/fedup


%changelog
* Wed Dec 05 2012 Will Woods <wwoods@redhat.com> 0.7.2-1
- Remove awful hack to forcibly sync data to disk (fixed in systemd 195-8)
- Clean up after upgrade finishes
- Fix progress screen and text output

* Thu Nov 15 2012 Will Woods <wwoods@redhat.com> 0.7.1-1
- install new kernel without removing old ones (#876366)

* Wed Nov 14 2012 Will Woods <wwoods@redhat.com> 0.7-2
- Awful hack to make journal work
- Send output to systemd journal
- Fix Requires: for fedup-dracut-plymouth
- Awful hack to make sure data gets written before reboot

* Thu Oct 25 2012 Will Woods <wwoods@redhat.com> 0.7-1
- Initial packaging
