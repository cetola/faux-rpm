#!/bin/bash
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]
  then
    echo "Usage: faux-rpm NAME VERSION REV ARCH"; exit 1
fi
NAME=$1
VER=$2
REV=$3
ARCH=$4
LONGNAME=${NAME}-${VER}
RPMDIR="rpmbuild-$1"
cat <<EOF >~/.rpmmacros
%_topdir   %(echo $HOME)/${RPMDIR}
%_tmppath  %{_topdir}/tmp
EOF
mkdir -p ~/$RPMDIR/{RPMS,SRPMS,BUILD,SOURCES,SPECS,tmp}
cd ~/$RPMDIR
mkdir ${LONGNAME}
mkdir ${LONGNAME}/faux-${NAME}
tar -zcvf ${LONGNAME}.${ARCH}.tar.gz ${LONGNAME}
cp ${LONGNAME}.${ARCH}.tar.gz SOURCES/
cat <<EOF > SPECS/${NAME}.spec
# Don't try fancy stuff like debuginfo, which is useless on binary-only
# packages. Don't strip binary too
# Be sure buildpolicy set to do nothing
%define        __spec_install_post %{nil}
%define          debug_package %{nil}
%define        __os_install_post %{_dbpath}/brp-compress

Summary: A very simple toy bin rpm package
Name: ${NAME}
Version: ${VER}
Release: ${REV}
License: GPL+
Group: System Environment/Libraries
SOURCE0 : ${LONGNAME}.${ARCH}.tar.gz
URL: http://stuff.company.com/
BuildArch: ${ARCH}

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
how should i know

%prep
%setup -q

%build
# Empty section.

%install
rm -rf %{buildroot}
mkdir -p  %{buildroot}

# in builddir
cp -a * %{buildroot}


%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)

%changelog
* Thu Apr 27 2017  Some Person <devzero2000@rpm5.org> 1.0-1
- First Build
EOF
rpmbuild -ba SPECS/${NAME}.spec
