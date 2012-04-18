require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

require './options'
require './lib/audit_tentacles/redis'
require './lib/audit_tentacles/sso_auth'
require './lib/audit_tentacles/media'
require './lib/audit_tentacles/slurp'
require './lib/audit_tentacles/crawler'

#site = Sites.create :location => 'http://scienceonline.tki.org.nz/'

#Crawler.new(site).crawl
