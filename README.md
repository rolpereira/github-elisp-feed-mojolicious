
(To see this code in action, see http://github-elisp.herokuapp.com )

Inspired by Zach's
[feed for new Common Lisp repos](http://xach.livejournal.com/298220.html).

The code was based on [tempire's example of a Mojolicious app hosted in heroku](http://tempire.github.io/mojolicious-command-deploy-heroku/).

You can find the feed in [Gwene.org](http://gwene.org) with the name `gwene.com.herokuapp.github-elisp`

-------------------------------------------------------------------------------

# Instalation #

Clone this repository into a folder using the following command:

    git clone git@github.com:rolpereira/github-elisp-feed-mojolicious.git


Inside the new folder, create a heroku app using the heroku command-line client like so:

    heroku create -s cedar --buildpack http://github.com/judofyr/perloku.git


To access the Github API, the site expects a Github key in the environment variable `GITHUB_TOKEN`. You can create that key using the [Github web interface](https://help.github.com/articles/creating-an-access-token-for-command-line-use).


After creating the key add it to your heroku application using the following command:

    heroku config:add GITHUB_TOKEN=<TOKEN_API>


Finally deploy it to heroku using:

    git push heroku master


To open your application in a browser use the command:

    heroku open
