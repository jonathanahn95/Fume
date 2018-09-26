require 'json'

class Flash
  attr_reader :now

  def initialize(req)
    cookie = req.cookies['_fume_app_flash']

    @now = cookie ? JSON.parse(cookie) : {}
    @flash = {}
  end

  def [](key)
    @flash[key.to_s] || @now[key.to_s]
  end

  def []=(key, value)
    @flash[key.to_s] = value
  end

  def store_flash(res)
    cookie = { path: '/', value: @flash.to_json }
    res.set_cookie('_fume_app_flash', cookie)
  end

end
