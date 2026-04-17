class profile::webserver {

  package { 'nginx':
    ensure => installed,
  }

  file { '/usr/share/nginx/html/index.html':
    ensure  => file,
    content => "<html><body><h1>Deployed by Jenkins + Terraform + Puppet</h1></body></html>\n",
    require => Package['nginx'],
  }

  service { 'nginx':
    ensure    => running,
    enable    => true,
    require   => Package['nginx'],
    subscribe => File['/usr/share/nginx/html/index.html'],
  }
}
