
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


-------------------------------------------------------------------------------

# Available endpoints #

Currently there are two available endpoints:

- `/` is the default endpoint and it lists all the new Emacs Lisp repositories that were created during the current day
- `/nodotemacs` is an endpoint that lists all the new Emacs Lisp repositories that were created during the current day except for those repositories that look like a user's "dotemacs" or ".emacs.d" repositories
- `/noemacsmirror` is an endpoint that lists all the new Emacs Lisp repositories except those that already exist in the [emacsmirror user's repos](https://github.com/emacsmirror)

--------------------------------------------------------------------------------

# Database #

If you want to use the `/noemacsmirror` endpoint you will need to use a PostgreSQL database to store the existing repositories of [emacsmirror](https://github.com/emacsmirror).

The script `bin/fetch-emacsmirror-repos.pl` will collect all the repositories in the account emacsmirror and store then on the database specified in the environment variable `DATABASE_URL`.

The format of the variable `DATABASE_URL` should be the following:

    postgres://<USERNAME>:<PASSWORD>@<HOST>:<PORT>/<DBNAME>


If you are using heroku you can create a PostgreSQL database through their [web interface](https://www.heroku.com/postgres). You then add the connection to your app using the following command:

    heroku config:add DATABASE_URL=<POSTGRES_CONNECTION_STRING>


You can populate the database by running the `bin/fetch-emacsmirror-repos.pl` using the following command:

    heroku run perl bin/fetch-emacsmirror-repos.pl


To run the script automatically use the [heroku scheduler](https://devcenter.heroku.com/articles/scheduler) by using the following commands:

    heroku addons:add scheduler:standard
    heroku addons:open scheduler

And make the scheduler run the command `perl bin/fetch-emacsmirror-repos.pl` every day.

Keep in mind that the time used by the heroku scheduler counts towards your monthly bill. See [heroku's page on it's scheduler](https://devcenter.heroku.com/articles/scheduler) for more details.
