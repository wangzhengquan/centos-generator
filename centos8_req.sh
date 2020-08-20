
sudo dnf install -y elfutils-libelf-devel

# for lorax
sudo dnf install -y python3-devel python3-gobject gtk3 libgit2-glib libgit2
sudo pip3 install nose pytest-cov rpmfluff   ansible-runner pycdlib semantic_version


# fro anaconda
sudo dnf install -y lorax-lmc-virt libguestfs-tools python3-libvirt virt-install  \
 	glib2 glib2-devel audit-libs-devel rpm-devel

#  install "parallel" from source code 


dnf --enablerepo=PowerTools install -y glade-devel libxklavier-devel gobject-introspection-devel \
	libarchive-devel libarchive-devel gtk-doc


 