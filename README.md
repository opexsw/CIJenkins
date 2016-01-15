CIJenkins Cookbook
==================
This cookbook installs and configures Jenkins as needed for CIInABox on Ubuntu platform machines.


Requirements
------------
Ensure the dependant cookbooks mentioned in metadata are present in the same cookbooks folder. 


Attributes
----------
Template File:-
default['CIJenkins']['jenkins']['job_build_cfg'] : The .xml file with job details 

Magento Details:-
default['CIJenkins']['jenkins']['magento_dir'] : The Magento Directory
default['CIJenkins']['jenkins']['magento_url'] : The git url
default['CIJenkins']['magento']['enc']

Jenkins Details:-
default['CIJenkins']['jenkins']['plugins'] : The list of jenkins plugins to be installed
default['CIJenkins']['jenkins']['packages'] : The list of ubuntu packages to be installed
default['CIJenkins']['jenkins']['username'] : The username of Jenkins build project 
default['CIJenkins']['jenkins']['password'] : The password of Jenkins build project 



Usage
-----
CIJenkins::default

To include `CIJenkins` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[CIJenkins]"
  ]
}
```


License and Authors
-------------------
Opex Software, Pune