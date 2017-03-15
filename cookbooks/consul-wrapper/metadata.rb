name 'consul-wrapper'
maintainer 'Jason Anderson'
maintainer_email 'darth.scrumlord@gmail.com'
license 'Apache 2.0'
description 'Wrapper cookbook used to install and configure a consul cluster'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url 'https://github.com/Jazun713/consul-wrapper'
issues_url 'https://github.com/Jazun713/consul-wrapper/issues'
version '0.1.0'

supports 'centos', '>= 7.1'
supports 'ubuntu', '>= 14.04'

depends 'consul-platform', '>= 1.0.0'
