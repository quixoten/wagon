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
  user = Wagon::User.new("username", "password") #=> <Wagon::User#Devin>
  user.wards #=> [<Wagon::Ward#1st Ward>, <Wagon::Ward#2nd Ward>, ... ]
  user.home_ward #=> <Wagon::Ward#1st Ward>

  stake = user.stake #=> <Wagon::Sake#1st Stake>
  stake.wards #=> [<Wagon::Ward#1st Ward>, <Wagon::Ward#2nd Ward>, ... ]
  stake.members #=> [<Wagon::Member#Devin>, <Wagon::Member#Tyden>, ...]
  stake.to_pdf filename: "#{stake.name}.pdf", pictures: true

  home_ward = user.home_ward
  home_ward.members #=> [<Wagon::Member#Devin>, <Wagon::Member#Tyden>, ...]
  home_ward.to_pdf do |pdf|
    pdf.filename = "#{home_ward.name}.pdf"
    pdf.columns = 5
    pdf.rows = 6
    pdf.email = true
    pdf.address = false
    pdf.phone_number = true
    pdf.pictures = true
  end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
