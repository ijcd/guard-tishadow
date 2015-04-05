# Guard::Tishadow

Guard::Tishadow manages [TIShadow](http://tishadow.yydigital.com/) for easier Titanium development.

## Installation

Add this line to your application's Gemfile:

    gem 'guard-tishadow'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install guard-tishadow

## Usage

```
guard 'tishadow', :app_root => "testapp" do
  watch(%r{^testapp/app/.*})
  watch(%r{^testapp/tiapp.xml})
  watch(%r{^testapp/spec/(.*)\.js})
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
