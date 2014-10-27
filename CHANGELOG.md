# 0.6.2 / 2014-10-27

* Respond to /crossdomain.xml for Flash-based usage

# 0.6.1 / 2014-10-27

* Expire the cache when the version of Texrack changes
* Pass trim=1 to have ImageMagick trim the image before returning it

# 0.6.0 / 2014-06-23

* Cache the generated images and return proper ETags

# 0.5.1 / 2013-11-07

* Oh, git. And stupid authors…
  Make sure `File.chmod` is called **before** sending the file.

# 0.5.0 / 2013-11-07

* A typo snuck in, referencing FileText instead of FileTest
* Make the generated PNG readable by the world, to avoid potential issues
  with serving the file.
* Allow passing in a own logger, e.g. `Rails.logger`

# 0.4.0 / 2013-11-07

* Allow configuring where to find binaries

# 0.3.0 / 2013-11-05

* Allow forcing the response status to 200 OK
* Remove unused code

# 0.2.0 / 2013-11-01

* Replace RMagick with Cocaine and ImageMagick
* Better error handling
* Work when mounted somewhere other than /

# 0.1.0 / 2013-10-28

* Initial version
