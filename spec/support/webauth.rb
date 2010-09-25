require 'erb'

# Generates a valid CAS XMl structure for faking a CAS user login.
def render_webauth_xml(name, uid)
  xml_text = File.read("spec/support/webauth_xml.erb")
  erb = ERB.new(xml_text)
  erb.result(binding())
end

def webauth_valid_ticket_for(ticket, name, uid)
  xml_text = render_webauth_xml(name, uid)
  webauth_setup_url(ticket, xml_text)
end

def webauth_invalid_ticket(ticket)
  xml_text = File.read("spec/support/webauth_badticket.xml")
  webauth_setup_url(ticket, xml_text)
end

def webauth_config
  Rack::Webauth::Configuration.options
end

def webauth_setup_url(ticket, xml_text)
  url = "https://#{webauth_config.server_host}"
  url << "#{webauth_config.server_validate}?ticket=#{ticket}"
  url << "&service=#{webauth_config.send(:escape, webauth_config.url)}"
  FakeWeb.clean_registry
  FakeWeb.register_uri(:get, url, :body => xml_text)
end