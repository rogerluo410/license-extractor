# license-extractor

This repo is going to improve working efficiency for finding packages' license. It almost repalces searching license on Internet manually now.

If the repository is one of based on Ruby,Go,Jave language, as long as providing Github URL of a certain repository and marking what kind of language as main language  it is, the tool can extract its the third dependent packages' license info automatically.

Currently, it has been implemented for ruby's repo, Go and Java are pending.

###For example,

- ***Writing a certain repository Github URL into input file `url_list.txt`, the format as follows:***    
```
ruby,https://raw.githubusercontent.com/cloudfoundry/cloud_controller_ng/master/Gemfile.lock
ruby,https://raw.githubusercontent.com/cloudfoundry-attic/vcap-services-base/master/Gemfile.lock
ruby,https://raw.githubusercontent.com/cloudfoundry/ibm-websphere-liberty-buildpack/master/Gemfile.lock
go,https://github.com/cloudfoundry/cli
```
Note also that it must provide gemfile's url like this `https://raw.githubusercontent.com/cloudfoundry/cloud_controller_ng/master/Gemfile.lock`  for ruby repository.

- ***Run the tool:***  
The current solution is that running a shell script to execute every single task.  
The command is `./boot.sh url_list.txt` before running it `chmod u+x boot.sh`  
