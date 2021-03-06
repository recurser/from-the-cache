
About
-----

I've been scraping some sites recently for a side-project, and it occurred to me that I could save the target site bandwidth (and probably speed up the scrape process) if I **check the google cache first**, and only scrape the site itself as a last resort.

Thus was [fromthecache.com](http://fromthecache.com/) born. When you enter a URL, it will return the cached version from google if available; if not, it will scrape the original site. It stores the resulting page in memcached for 30 minutes, so popular requests return instantly.

Another use is an easy way to post mirror links when a site goes down - simply put _fromthecache.com/_ in front of the URL and you have an instant cache link.

Demo Site
---------

You can try out a live demo of the project at [fromthecache.com](http://fromthecache.com/).

I'm not sure about the legalities of removing the google cache header text (I do link to the google cache result though), and I have a suspicion the site may end up blocked from google anyway for looking like a bot.

Feel free to call the service programmatically if you wish, and basically do whatever you want with it. If anyone has complaints or comments, please [drop me a line](http://recursive-design.com/contact.)

License
-------

This project is distributed under the [MIT License](http://en.wikipedia.org/wiki/MIT_license). See the [License](https://github.com/recurser/from-the-cache/blob/master/LICENSE) file for details.

Installation
------------

To get started, first download the source via git

```bash
> git clone git://github.com/recurser/from-the-cache.git
> cd from-the-cache
```

Next, install the requisite gems :

```bash
> gem install bundler
> bundle install
```

Run memcached if available - the app will cache requests for 30 minutes by default. You'll need to run memcached to use the test suite, but it's not strictly necessary just to run the app.

```bash
> memcached -d
```

Finally, run the local development server to try it out :

```bash
> rails s
```

The demo application should now be available at [http://localhost:3000/](http://localhost:3000/.)

Testing
-------

_From The Cache_ comes pre-configured for [Spork](http://github.com/timcharper/spork) and [autotest](http://www.zenspider.com/ZSS/Products/ZenTest/#rsn) support. I generally work by running _spork_ in one terminal :

```bash
> cd from-the-cache
> spork
Using RSpec
Loading Spork.prefork block...
Spork is ready and listening on 8989!
```

... and running _autotest_ in another :

```bash
> cd from-the-cache
> autotest
........................................................................................

Finished in 29.27 seconds
41 examples, 0 failures
```

Autotest will run the test suite automatically whenever you save changes, and if you're working on OSX, it will provide [Growl](http://growl.info/) feedback every time the test suite is run :

![Autotest growl notification](http://recursive-design.com/images/projects/from-the-cache/autotest_growl_notification.png)

Deploying to Heroku
-------------------

To deploy the application to [Heroku](http://heroku.com/,) simply run _heroku create_ :

```bash
> heroku create
Creating evening-beach-14... done
Created http://evening-beach-14.heroku.com/ | git@heroku.com:evening-beach-14.git
Git remote heroku added
```

The _evening-beach-14_ part will vary depending on the name Heroku chooses for your application.

To push your newly created application to Heroku, do a _git push heroku master_ :

```bash
> git push heroku master
Counting objects: 1669, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (629/629), done.
Writing objects: 100% (1669/1669), 382.36 KiB, done.
Total 1669 (delta 955), reused 1657 (delta 949)

-----> Heroku receiving push
-----> Rails app detected
-----> Gemfile detected, running Bundler version 1.0.0
       Unresolved dependencies detected; Installing...
       Fetching source index for http://rubygems.org/
       
       ...
       [installing a bunch of gems]
       ...
       
       Your bundle is complete! Use `bundle show [gemname]` to see where a bundled gem is installed.
       
       Your bundle was installed to `.bundle/gems`
       Compiled slug size is 25.6MB
-----> Launching.... done
       http://evening-beach-14.heroku.com deployed to Heroku

To git@heroku.com:evening-beach-14.git
 * [new branch]      master -> master
```

You should also install the free [SendGrid](http://sendgrid.com/) add-on for email delivery :

```bash
> heroku addons:add sendgrid:free
```

And finally the free memcached add-on :

```bash
> heroku addons:add memcache:5mb
```

Your application should now be available at [http://evening-beach-14.heroku.com/](http://evening-beach-14.heroku.com/) (substitute the domain you received from _git push heroku_ here).

Whenever you push changes to git, you can update heroku by doing _git push heroku_ again.

Git hooks
---------

CoffeeScript and Compass both require generated files to be saved when they're compiled - this causes a problem on Heroku because access to the filesystem is limited. There are various hacks to get around this by saving to the _tmp_ folder and re-routing requests, but I decided it was probably easiest to just add the generated files to git and deploy them normally.

To achieve this, I added a post-commit hook to the repository to generate these files whenever changes are committed. To add these, create the file _.git/hooks/pre-commit_ , make it executable, and add the following contents :

```bash
#!/bin/sh

compass compile
rake public/javascripts/application.js
jammit

git add public/assets/common*
git add public/javascripts/application.js
```

The first two commands generate the CSS and Javascript respectively, and the 3rd command packages them up using Jammit.

Stylesheets
-----------

Stylesheets in the _public/stylesheets_ folder are automatically generated by compass, so any changes you make to these files will be lost. Instead, you should edit the _sass_ files in _app/stylesheets_.

When altering stylesheets during development, you should run _compass watch_ to make sure your changes are automatically compiled to _public/stylesheets_ :

```bash
> compass watch
>>> Compass is watching for changes. Press Ctrl-C to Stop.
```

Javascript
----------

Similarly, _public/javascripts/application.js_ is automatically generated by the CoffeeScript compiler. Instead of editing it directly, edit _application/scripts/application.coffee_ instead. 

Unlike Compass, there is no need to run a _watch_ script for this file during development - it will automatically be compiled for you.

Asset Packaging
---------------

JavaScript and CSS are automatically compressed and packaged for production with [Jammit](http://documentcloud.github.com/jammit/). During development, the non-compressed versions will be served to speed things up. This packaging should be fairly transparent to you if you set up the git pre-commit hook described above - if you choose not to do this you will need to run the _jammit_ command manually before committing changes.

Bug Reports
-----------

If you come across any problems, please [create a ticket](https://github.com/recurser/from-the-cache/issues) and we'll try to get it fixed as soon as possible.


Contributing
------------

Once you've made your commits:

1. [Fork](http://help.github.com/fork-a-repo/) from-the-cache
2. Create a topic branch - `git checkout -b my_branch`
3. Push to your branch - `git push origin my_branch`
4. Create a [Pull Request](http://help.github.com/pull-requests/) from your branch
5. That's it!


Author
------

Dave Perrett :: mail@recursive-design.com :: [@recurser](http://twitter.com/recurser)


Copyright
---------

Copyright (c) 2010 Dave Perrett. See [License](https://github.com/recurser/from-the-cache/blob/master/LICENSE) for details.

