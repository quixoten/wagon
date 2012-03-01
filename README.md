# Wagon

Provided a valid [lds.org](https://www.lds.org/SSOSignIn) username and password, Wagon will create a photo directory of your home ward.

## Usage
    require 'wagon'

    member = Wagon::connect('username', 'password')
    home_ward = member.home_ward
    directory = home_ward.households.to_pdf(:font_size => 10, :rows => 9, ...)
    directory.render_file('photo_directory.pdf')

## Terminal Usage
    wagon --help

## Installation
    gem install wagon

## Copyright

Copyright (c) 2009 Devin Christensen. See {file:LICENSE} for details.
