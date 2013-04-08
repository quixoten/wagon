# Wagon

Wagon is a Ruby API for the tools and information available on the lds.org website

## Installation

Add this line to your application's Gemfile:

    gem 'wagon'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wagon

## Usage

```ruby
  wagon = Wagon.new("username", "password")
  wagon.current_user #= <Wagon::Member#Devin Christensen>
  wagon.stake #= <Wagon::Sake#The 1st Stake>
  wagon.wards #= [<Wagon::Ward#The 1st Ward>, <Wagon::Ward#The 2nd Ward>, ... ]

  home_ward = wagon.home_ward #= <Wagon::Ward#The 1st Ward>
  members = home_ward.members #= [<Wagon::Member#Devin Christensen>, <Wagon::Member#Yukihiro Matsumoto>, ...]
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
