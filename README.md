AWS Reserved Instance Analyzer
==============================

This tool compares reserved instances against running instances on an AWS account to 
show you if there are any unused RIs or any running instances that should be reserved.

Install
-------

```bash
$ git clone git@github.com:esripdx/aws-ri-analyzer.git
$ cd aws-ri-analyzer
$ bundle install
```

You will then need to define the list of accounts you want to use in the auth.yml file.
Copy `auth.example.yml` to `auth.yml` and fill in the values or create new sections.

The format of the file allows you to support multiple AWS accounts, and each account
can support multiple regions. You'll need to add the access key and secret for each 
region individually.

```yaml
account-name:
  us-east-1:
    access_key_id: 
    secret_access_key: 
  us-west-2:
    access_key_id: 
    secret_access_key: 
another-account:
  us-east-1:
    access_key_id: 
    secret_access_key: 
```


Usage
-----

Running the analyze.rb script with no arguments will give you a usage example and list
out the accounts that are configured.

```bash
$ bundle exec ruby analyze.rb
Usage: bundle exec ruby analyze.rb --account=account-name,another-account --region=us-east-1,us-west-2
```

To analyze a specific region, specify both arguments:

```bash
$ bundle exec ruby analyze.rb --account=account-name --region=us-east-1
```

The script will find all current reserved instances, and find all running instances,
and show you if there are any that don't match. For example:

```
Purchased RIs that are not in use by any running EC2 instances:
  m1.large/us-west-2a

Running instances that are not yet reserved:
  c1.medium/us-west-2a
  c1.medium/us-west-2a
```

This should help you figure out if you should resize any running instances to match
RIs that aren't being used, or whether you should purchase RIs for running instances.


License
-------

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
