require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'byebug'
require 'active_support/inflector'

class ControllerBase
  attr_reader :req, :res, :params, :session

  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @session = Session.new(req)
    @params = req.params.merge!(route_params)

    @@protect_from_forgery ||= false
  end

  def already_built_response?
    @already_built_response ||= false
  end

  def redirect_to(url)
    raise 'Error' if already_built_response?
    self.res.set_header("Location", url)
    self.res.status = 302
    @session.store_session(res)
    @already_built_response = true
  end

  def render_content(content, content_type)
    raise 'Double render error' if already_built_response?
    self.res.write(content)
    self.res.set_header('Content-Type', content_type)
    @already_built_response = true
    @session.store_session(res)
  end

  def render(template_name)
    temp_path = "views/#{self.class.to_s.underscore}/#{template_name.to_s}.html.erb"
    temp = ERB.new(File.read(temp_path)).result(binding)
    render_content(temp, "text/html")
  end

  def session
    @session ||= Session.new(@req)
  end


  def invoke_action(name)
    if protect_from_forgery? && req.request_method != "GET"
      check_authenticity_token
    else
      form_authenticity_token
    end

    self.send(name)
    render(name) unless already_built_response?

    nil
  end


  def form_authenticity_token
    @token ||= generate_authenticity_token
    cookie = { path: '/', value: @token }

    res.set_cookie('authenticity_token', cookie)
    @token
  end


  protected

  def self.protect_from_forgery
    @@protect_from_forgery = true
  end

  private

  def protect_from_forgery?
    @@protect_from_forgery
  end

  def check_authenticity_token
    cookie = @req.cookies["authenticity_token"]
    unless cookie && cookie == params["authenticity_token"]
      raise "Invalid authenticity token"
    end
  end

  def generate_authenticity_token
    SecureRandom.urlsafe_base64(16)
  end

end
