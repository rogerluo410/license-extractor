# license-extractor

This repo is going to improve working efficiency for finding packages' license. It almost repalces searching license on Internet manually now.

If a repository is one of based on Ruby,Go,Jave language, as long as providing Github URL of the repository and marking what kind of language as main language it is, the tool can extract its the third dependent packages' license info automatically.

Currently, it has been implemented for ruby's repo, Go and Java are pending.

###For example

- ***Writing a certain repository Github URL into input file `url_list.txt`, the format as follows:***    
```
ruby,https://raw.githubusercontent.com/cloudfoundry/cloud_controller_ng/master/Gemfile.lock
ruby,https://raw.githubusercontent.com/cloudfoundry-attic/vcap-services-base/master/Gemfile.lock
ruby,https://raw.githubusercontent.com/cloudfoundry/ibm-websphere-liberty-buildpack/master/Gemfile.lock
go,https://github.com/cloudfoundry/cli
 .
 .
 .
```
Note also that it must provide gemfile's url like this `https://raw.githubusercontent.com/cloudfoundry/cloud_controller_ng/master/Gemfile.lock`  for ruby repository.

- ***Run the tool:***  
The current solution is that running a shell script to execute every single task.  
The command is `./boot.sh url_list.txt`, before running it `chmod u+x boot.sh`  

- ***Output file***  
Output file is named by repo's name appending ‘_output’ string behind the name. its content is like this：  
```
builder,3.2.2,MIT,https://rubygems.org/gems/builder/versions/3.2.2
beefcake,1.0.0,MIT,https://rubygems.org/gems/beefcake/versions/1.0.0
CFPropertyList,2.3.0,MIT,https://rubygems.org/gems/CFPropertyList/versions/2.3.0
i18n,0.7.0,MIT,https://rubygems.org/gems/i18n
 .
 .
 .
```

###The whole process  
step 1 : `bundle install`  
step 2 : run `./boot.sh url_list.txt`  
step 3 : watching output files in same directory.   

