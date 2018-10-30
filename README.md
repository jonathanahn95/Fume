# Fume
Fume is a ORM (Object Relational Management) and MVC (Model View Controller) framework written in Ruby. 
ControllerBase provides a base controller class, and Router provides basic routing capabilities with that renders corresponding views.

## ControllerBase
Custom classes that extend `ControllerBase` can use the following methods:
* `render(template_name)`: Creates a new instance of an ERB object and renders a template located in app/views/<controller_name>.
* `render_content(content, content_type)`: Renders the custom content being passed and sets the headers content-type to the specified content_type being passed.
* `redirect_to(url)`: Redirects to the URL being passed as in argument.
* `session`: key/value pairs saved to this hash are saved as cookies.
* `flash and flash.now`: key/values pairs saved to this hash will persist through the next session and the current session only, respectively.


```  
  def render_content(content, content_type)
    raise 'Double render error' if already_built_response?
    self.res.write(content)
    self.res.set_header('Content-Type', content_type)
    @already_built_response = true
    @session.store_session(res)
  end
```

## Router
Can handle incoming requests and direct them to the proper controller and action.


```
  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern,http_method,controller_class, action_name)
    end
  end
```

## Running the app
* `git clone https://github.com/jonathanahn95/Fume.git`
* `cd fume`
* `bundle install`
* Visit `localhost:3000`


