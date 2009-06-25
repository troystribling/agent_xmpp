$:.unshift(File.dirname(__FILE__))

require 'find'
require 'ftools'
require 'singleton'
require 'logger'
require 'socket'
require 'optparse'

require 'eventmachine'
require 'evma_xmlpushparser'

require 'agent_xmpp/patches'
require 'agent_xmpp/config'
require 'agent_xmpp/utils'
require 'agent_xmpp/app'
require 'agent_xmpp/client'
require 'agent_xmpp/xmpp'
require 'agent_xmpp/main'
