%w[
  hsbt
  mame
  k0kubun
  nobu
].each do |u|
  user u do
    case node[:platform]
    when 'debian', 'ubuntu'
      gid 27 # sudo
      shell '/bin/bash'
    when 'openbsd'
      gid 0 # wheel
    else
      gid 10 # wheel
    end
  end

  directory "/home/#{u}" do
    mode  '755'
    owner u
  end

  directory "/home/#{u}/.ssh" do
    mode  '700'
    owner u
  end

  remote_file "/home/#{u}/.ssh/authorized_keys" do
    source "keys/#{u}.keys"
    mode  '600'
    owner u
  end
end

user 'chkbuild' do
  case node[:platform]
  when 'debian', 'ubuntu'
    shell '/bin/bash'
  end
end

directory '/home/chkbuild' do
  mode  '755'
  owner 'chkbuild'
end

node.reverse_merge!(
  rbenv: {
    user: 'chkbuild',
    global: '2.5.7',
    versions: %w[
      2.5.7
    ],
    install_development_dependency: true,
  }
)

include_recipe 'rbenv::user'

git "chkbuild" do
  repository "https://github.com/ruby/chkbuild"
  user "chkbuild"
  not_if "test -e /home/chkbuild/chkbuild"
end

case node[:platform]
when 'fedora'
  package 'cronie'
  package 'cronie-anacron'
  service 'crond' do
    action [:enable, :start]
  end

  package 'patch'
end