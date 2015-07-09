# VCR::API

Extensions for the VCR gem that provide tools to test APIs, particularly for
service oriented architectures operating over HTTP.

## Testing APIs in Feature Specs

Keeping API tests fresh in feature specs or Cukes can be a losing battle.  The
API may change frequently (sometimes with a pleasing version bump, and
sometimes not) and your tests are no good if you have to KNOW when the API has
changed.

While there is no way to completely automate the process short of setting up
the entire cluster, `vcr-api` aims to at least make it less painful.

1) It sets up "known" apis that your application uses.
2) It can query those apis to see if there has been a known version change.
3) It keeps track of how often the API requests are recorded and can
transparently re-record them.

(3 is already support by VCR, but only at that the cassette level.
VCR-API organizes cassettes along API lines, so can expire cassettes along
service boundaries.)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'vcr-api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vcr-api

## Usage

Within your spec_helper.rb or env.rb file, define APIs, then enable those
APIs using Rspec or Cucumber metadata.

The simplest possible configuration.

```ruby
VCR.configure do |c|
  c.add_api :my_service_name, 'locahost:3002'
end

RSpec.describe SomeClass, :my_service_name do
  it 'will record requests to localhost:3002'
end
```

Using within an example it's not enabled for raises an error by default.
If you want to make this less obtrusive, configure with the
`c.always_allow_api_access = true`

Before it attempts to record interactions with the API, VCR-API will attempt
to determine if the API has a live instance present - therefore - *use the
instance of the API you would like to record from* - if it finds a live
instance and the API recording has expired, the cassette will be re-recorded.
By default, API recordings never expire.

For testing services where you control all of the instance, you probably want
the exact opposite of that, which is for APIs to be re-recorded whenever a
running instance is present.  Just pass "expires: true" flag to your API
definition.  For other situations you can pass a proc to expires, which will be
used to determine if the API should be re-recorded.

If you are recording feature specs using selenium or phantomjs, you may have
noticed that those services communicate over HTTP with a localhost based
server. VCR-API will automatically detect and exclude communication with
Selenium, PhantomJS, etc unless you specifically enable those recordings.
`c.record_feature_interactions = true`

## Contributing

1. Fork it ( https://github.com/[my-github-username]/vcr-api/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
6. Rebase as asked, please.
