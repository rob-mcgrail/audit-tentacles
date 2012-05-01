require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

$term = HighLine.new

require './options'
require './lib/audit_tentacles/redis'
require './lib/audit_tentacles/sso_auth'
require './lib/audit_tentacles/media'
require './lib/audit_tentacles/slurp'
require './lib/audit_tentacles/crawler'
require './lib/audit_tentacles/mms'
require './lib/audit_tentacles/output'
