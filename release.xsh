#!/usr/bin/env xonsh

from os.path import abspath,dirname,join
from json import loads,dumps
PWD = dirname(abspath(__file__))
ROOT = dirname(PWD)

package_json = join(ROOT, "sh/package.json")
with open(package_json) as package:
  package = loads(package.read()) 
  version = package['version'].split('.')
  version[-1] = str(int(version[-1])+1)
  package['version'] = version = '.'.join(version)
  package = dumps(package,indent=2)
  echo @(package) > @(package_json)
  cd @(ROOT)/sh
  version = "v%s"%version
  git add -u
  git commit -m @(version)
  git tag @(version)
  git push origin @(version)
  @(PWD)/cloudflare-6du.js
