VERSION=$(vagrant --version | awk '{print $2}')
. /opt/vagrant/embedded/gems/gems/vagrant-$VERSION/contrib/bash/completion.sh
