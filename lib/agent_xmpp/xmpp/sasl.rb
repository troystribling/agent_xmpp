# Original from XMPP4R - XMPP Library for Ruby Website::http://home.gna.org/xmpp4r/
##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  module Xmpp

    #####-------------------------------------------------------------------------------------------------------
    module SASL

      #.....................................................................................................
      NS_SASL = 'urn:ietf:params:xml:ns:xmpp-sasl'

      #####-------------------------------------------------------------------------------------------------------
      class << self
        
        #.....................................................................................................
        def new(mechanism)
          case mechanism
            when 'DIGEST-MD5'
              DigestMD5.new
            when 'PLAIN'
              Plain.new
            when 'ANONYMOUS'
              Anonymous.new
            else
              raise AgentXmppError "Unknown SASL mechanism: #{mechanism}"
          end
        end
      
        #.........................................................................................................
        def authenticate(stream_mechanisms)
          if stream_mechanisms.include?('PLAIN')
            Send(new('PLAIN').auth(AgentXmpp.jid, AgentXmpp.password))
          else
            raise AgentXmppError, "PLAIN authentication required"
          end
        end

      #### self
      end
    
      #####-------------------------------------------------------------------------------------------------------
      class Base

        #.....................................................................................................
        def initialize
        end

        private

        #.....................................................................................................
        def generate_auth(mechanism, text=nil)
          auth = REXML::Element.new 'auth'
          auth.add_namespace NS_SASL
          auth.attributes['mechanism'] = mechanism
          auth.text = text
          auth
        end

        #.....................................................................................................
        def generate_nonce
          Digest::MD5.hexdigest(Time.new.to_f.to_s)
        end
      
      #### Base
      end

      #####-------------------------------------------------------------------------------------------------------
      class Plain < Base

        #.....................................................................................................
        def auth(jid, password)
          auth_text = "#{jid.strip}\x00#{jid.node}\x00#{password}"
          generate_auth('PLAIN', Base64::encode64(auth_text).gsub(/\s/, ''))
        end

      ### Plain
      end

      #####-------------------------------------------------------------------------------------------------------
      class Anonymous < Base

        #.....................................................................................................
        def auth(password)
          auth_text = "#{@stream.jid.node}"
          error = nil
          @stream.send(generate_auth('ANONYMOUS', Base64::encode64(auth_text).gsub(/\s/, ''))) do |reply|
            error = reply.first_element(nil).name if reply.name != 'success'
            true
          end
          raise error if error
        end
        
      #### Anonymous
      end

      #####-------------------------------------------------------------------------------------------------------
      class DigestMD5 < Base

        #.....................................................................................................
        def initialize(stream)
          super
          challenge = {}
          error = nil
          @stream.send(generate_auth('DIGEST-MD5')) { |reply|
            if reply.name == 'challenge' and reply.namespace == NS_SASL
              challenge = decode_challenge(reply.text)
            else
              error = reply.first_element(nil).name
            end
            true
          }
          raise error if error
          @nonce = challenge['nonce']
          @realm = challenge['realm']
        end

        #.....................................................................................................
        def decode_challenge(challenge)
          text = Base64::decode64(challenge)
          res = {}

          state = :key
          key = ''
          value = ''

          text.scan(/./) do |ch|
            if state == :key
              if ch == '='
                state = :value
              else
                key += ch
              end

            elsif state == :value
              if ch == ','
                res[key] = value
                key = ''
                value = ''
                state = :key
              elsif ch == '"' and value == ''
                state = :quote
              else
                value += ch
              end

            elsif state == :quote
              if ch == '"'
                state = :value
              else
                value += ch
              end
            end
          end
          res[key] = value unless key == ''

          res
        end

        #.....................................................................................................
        def auth(password)
          response = {}
          response['nonce'] = @nonce
          response['charset'] = 'utf-8'
          response['username'] = @stream.jid.node
          response['realm'] = @realm || @stream.jid.domain
          response['cnonce'] = generate_nonce
          response['nc'] = '00000001'
          response['qop'] = 'auth'
          response['digest-uri'] = "xmpp/#{@stream.jid.domain}"
          response['response'] = response_value(@stream.jid.node, @stream.jid.domain, response['digest-uri'], password, @nonce, response['cnonce'], response['qop'], response['authzid'])
          response.each do |key,value|
            unless %w(nc qop response charset).include? key
              response[key] = "\"#{value}\""
            end
          end

          response_text = response.collect { |k,v| "#{k}=#{v}" }.join(',')
          r = REXML::Element.new('response')
          r.add_namespace NS_SASL
          r.text = Base64::encode64(response_text).gsub(/\s/, '')

          success_already = false
          error = nil
          @stream.send(r) do |reply|
            if reply.name == 'success'
              success_already = true
            elsif reply.name != 'challenge'
              error = reply.first_element(nil).name
            end
            true
          end

          return if success_already
          raise error if error

          r.text = nil
          @stream.send(r) do |reply|
            if reply.name != 'success'
              error = reply.first_element(nil).name
            end
            true
          end
          raise error if error
          
        end

        private

        #.....................................................................................................
        def h(s); Digest::MD5.digest(s); end

        #.....................................................................................................
        def hh(s); Digest::MD5.hexdigest(s); end

        #.....................................................................................................
        def response_value(username, realm, digest_uri, passwd, nonce, cnonce, qop, authzid)
          a1_h = h("#{username}:#{realm}:#{passwd}")
          a1 = "#{a1_h}:#{nonce}:#{cnonce}"
          if authzid
            a1 += ":#{authzid}"
          end
          if qop == 'auth-int' || qop == 'auth-conf'
            a2 = "AUTHENTICATE:#{digest_uri}:00000000000000000000000000000000"
          else
            a2 = "AUTHENTICATE:#{digest_uri}"
          end
          hh("#{hh(a1)}:#{nonce}:00000001:#{cnonce}:#{qop}:#{hh(a2)}")
        end
      end
      
    #### DigestMD5 
    end
    
  #### XMPP
  end

#### AgentXmpp
end

