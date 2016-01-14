# Cookbook Name:: CIJenkins
# Recipe:: default
# Copyright 2015, Opex Software
# All rights reserved - Do Not Redistribute


# Recipe for debian only 
include_recipe 'apt'

# Recipe for php
#include_recipe 'php'

# Jenkins Master Installation Recipe

include_recipe 'jenkins::master'

# Jenkins Service

service 'jenkins' do
  action  :nothing
end

# SSH Key to Connect to Other Servers

cookbook_file "/var/lib/jenkins/ssh.key" do
  source "ssh.key"
  mode "600"
  owner "jenkins"
  group 'jenkins'
end

# File path to create jobs 

scmxml=File.join(Chef::Config[:file_cache_path], 'SCM.xml')
tmp=Chef::Config[:file_cache_path]

# Create a JOBs

template scmxml do
  source "scmxml.erb"
  mode "600"
  owner "jenkins"
  group 'jenkins'
end

template "#{tmp}/Build.xml" do
  source 'Build.xml'
  mode 0600
  owner 'jenkins'
  group 'jenkins'
end

template "#{tmp}/DeployNOW.xml" do
  source 'DeployNOW.xml'
  mode 0600
  owner 'jenkins'
  group 'jenkins'
end

template "#{tmp}/StaticCodeAnalysis.xml" do
  source 'StaticCodeAnalysis.xml'
  mode 0600
  group 'jenkins'
  owner 'jenkins'
end

template "#{tmp}/TestNOW.xml" do
  source 'TestNOW.xml'
  mode 0600
  owner 'jenkins'
  group 'jenkins'
end

template "#{tmp}/UnitTest.xml" do
  source 'UnitTest.xml'
  mode 0600
  owner 'jenkins'
  group 'jenkins'
end

# SonarQube and SonarRunner Settings

template "/var/lib/jenkins/hudson.plugins.sonar.SonarPublisher.xml" do
  source 'hudson.plugins.sonar.SonarPublisher.xml'
  mode 0600
  owner 'jenkins'
  group 'jenkins'
end

template "/var/lib/jenkins/hudson.plugins.sonar.SonarRunnerInstallation.xml" do
  source 'hudson.plugins.sonar.SonarRunnerInstallation.xml'
  mode 0600
  owner 'jenkins'
  group 'jenkins'
end

# Packages for Git and java
#TODO : move the list of packages to atrribute
packages = node['CIJenkins']['jenkins']['packages']
%W( packages ).each do |pkg|
  package "#{pkg}" do
    action :install
    ignore_failure true
  end
end

# Remove after adding LWRP to clone git repo with username and password
=begin

directory "/root/CDDemo" do
  action :delete
  recursive true
end

CIInABox_git_clone "#{node['CIJenkins']['git']['dir']}" do
  repo node['CIJenkins']['git']['url']
  username "#{node['CIJenkins']['git']['username']}"
  password "#{node['CIJenkins']['git']['password']}"
  action :sync
end


# Copy Users to Jenkins Server

execute "Copy users from deployNOW to jenkins" do
  cwd "/root"
  command "cp -r #{node['CIJenkins']['git']['dir']}/deployNOW/Jenkin/users /var/lib/jenkins/"
  action :run
end

# Copy vault Contents to Jenkins Server

execute "Copy vault to jenkins" do
  cwd "/root"
  command "cp -r #{node['CIJenkins']['git']['dir']}/TestNow/Jenkin/vault/vault /var/lib/jenkins/"
  action :run
end


execute "Change Permissions" do
	cwd "/var/lib/jenkins/jobs"
	command "chown -R jenkins:jenkins *"
	action :run
end

jenkins_password_credentials 'admin' do
  id '829d5ab8-0169-46d8-87e8-f90e0005da58'
  description 'Swati Rananaware'
  password    'opexadmin'
end
=end

# Change Permissions of Jenkins Home Directory

execute "Change Permissions of Jenkins dir" do
  cwd "/var/lib/jenkins/"
  command "chown -R jenkins:jenkins *"
  action :run
end

# Jenkins Authentication

cookbook_file "/var/chef/cache/jenkins-cli.jar" do
  source "jenkins-cli.jar"
  mode "600"
  owner "jenkins"
  group 'jenkins'
end

execute "Jenkins Login" do
  command "java -jar /var/chef/cache/jenkins-cli.jar -s http://localhost:8080 login --username admin --password opexadmin "
  action :run
  ignore_failure true
end

# Install Plugins for Jenkins 

node['CIJenkins']['jenkins']['plugins'].each do |plugin|
jenkins_plugin "#{plugin}" do
  install_deps true
  notifies :restart, 'service[jenkins]', :delayed
end
end

# Jenkins Job to pull and build project from git repo

jenkins_job "Build" do
  action :create
  config "#{tmp}/Build.xml"
end

# Jenkins Job to Unit Test the built Project

jenkins_job "UnitTest" do
  action :create
  config "#{tmp}/UnitTest.xml"
end

# Jenkins Job to Test the Project

jenkins_job "TestNOW" do
  action :create
  config "#{tmp}/TestNOW.xml"
end

# Jenkins Job to Deploy the Project App

jenkins_job "DeployNOW" do
  action :create
  config "#{tmp}/DeployNOW.xml"
end

# Static Code Analysis of the Project

jenkins_job "StaticCodeAnalysis" do
  action :create
  config "#{tmp}/StaticCodeAnalysis.xml"
end

# Credentials Required for the 'Build' Project
#TODO : move the credentials to attributes. user should be opexciinabox/0pexc11n@b0x
jenkins_password_credentials node['CIJenkins']['jenkins']['username'] do
  id 'd376a4f4-6dea-4455-a7c5-f9f55333b5c4'
  description 'Git'
  password    node['CIJenkins']['jenkins']['password']
end

# Config file for the Admin Credentials of Jenkins 

template "/var/lib/jenkins/config.xml" do
  source "config.xml.1"
  mode "600"
  owner "jenkins"
  notifies :restart, 'service[jenkins]', :delayed
end

# Directories required for Jobs

directory "/var/lib/jenkins/workspace" do
  action :create
  owner 'jenkins'
  group 'jenkins'
  mode 0755
  recursive true
end

directory "/var/lib/jenkins/builds" do
  action :create
  owner 'jenkins'
  group 'jenkins'
  mode 0755
  recursive true
end

# Git Clone Magento 

git "#{node['CIJenkins']['jenkins']['magento_dir']}" do
  user 'jenkins'
  group 'jenkins'
  repository node['CIJenkins']['jenkins']['magento_url']
  action :sync
end

# Composer Install to Download and Install Dependencies

execute "Install Composer in Magento Dir" do
  cwd "#{node['CIJenkins']['jenkins']['magento_dir']}"
  command "composer install -n"
  action :run
end