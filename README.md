Wagon
==============
Provided a valid lds.org username and password Wagon will download the
information and pictures from the Photo Directory page and compile it
into a convenient PDF.

Usage
--------------
    require 'wagon'
    user = Wagon::connect('username', 'password')
    pdf = user.ward.to_pdf(:font_size => 10, :rows => 9, ...)
    pdf.render_file('photo_directory.pdf')

Terminal Usage
--------------
    wagon --help

Installation
--------------
    gem install wagon

Copyright
--------------

Copyright (c) 2012 Devin Christensen. See {file:LICENSE.txt LICENSE} for details.
