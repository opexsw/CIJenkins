actions :sync
default_action :sync

attribute :dir, :name_attribute => true, :kind_of => String, :required => true
attribute :repo, :kind_of => String, :required => true
attribute :username, :kind_of => String, :required => true
attribute :password, :kind_of => String, :required => true
