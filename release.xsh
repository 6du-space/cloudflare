#!/usr/bin/env xonsh

from os.path import abspath,dirname,join
from json import loads,dumps

ROOT = dirname(dirname(abspath(__file__)))

package_json = join(ROOT, "sh/package.json")
with open(package_json) as package:
  package = loads(package.read()) 
  version = package['version'].split('.')
  version[-1] = str(int(version[-1])+1)
  package['version'] = '.'.join(version)
  package = dumps(package,indent=2)
  echo @(package) > @(package_json)
  cd @(ROOT)/sh
  version = "v%s"%version
  git commit -m @(version)
  git tag @(version)
  git push origin @(version)
