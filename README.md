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
  wagon = Wagon.connect("username", "password")
  stake = wagon.stake #= <Wagon::Sake#Orem YSA 1st>
  home_ward = wagon.home_ward #= <Wagon::Ward#Orem YSA 11th>

  stake.wards #= [<Wagon::Ward#Orem YSA 1st>, <Wagon::Ward#Orem YSA 2nd>, ... ]
  stake.members #= [<Wagon::Member#Devin Christensen>, <Wagon::Member#Douglas Engelbart>, ...]
  ward.members #= [<Wagon::Member#Devin Christensen>, <Wagon::Member#Yukihiro Matsumoto>, ...]
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
