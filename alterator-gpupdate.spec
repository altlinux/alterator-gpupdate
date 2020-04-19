Name: alterator-gpupdate
Version: 1.1
Release: alt1

Source:%name-%version.tar

Summary: Alterator module for group policy settings
License: GPL
Group: System/Configuration/Other
Requires: alterator >= 4.7-alt4
Requires: alterator-l10n >= 2.0-alt1
Requires: gpupdate

BuildPreReq: alterator >= 5.0 alterator-lookout

%ifarch %e2k
BuildRequires: guile20-devel libguile20-devel
%else
BuildRequires: guile22-devel
%endif

%description
Alterator module for group policy settings

%prep
%setup -q

%build
%make_build libdir=%_libdir

%install
export GUILE_LOAD_PATH=/usr/share/alterator/lookout
%makeinstall

%files
%_alterator_datadir/applications/*
%_alterator_datadir/ui/*/
%_alterator_backend3dir/*

%changelog
* Mon Apr 20 2020 Evgeny Sinelnikov <sin@altlinux.org> 1.1-alt1
- Adapted backend for gpupdate-setup CLI
- Add support for multiple profiles
- Improve ui display

* Thu Apr 02 2020 Rustem Bapin <rbapin@altlinux.org> 1.0-alt1
- First working version

