#!/usr/bin/env perl

# Copyright (C) 2014 Rolando Pereira
#
# Author: Rolando Pereira <rolando_pereira@sapo.pt>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;

use DBI;
use DBD::Pg;

use Net::GitHub::V3;

## Fetch the repos in the user "emacsmirror"
my $token = $ENV{GITHUB_TOKEN};

my $github = Net::GitHub::V3->new(access_token => $token);


my $repos = $github->repos;

print "Fetching page 1\n";
my @emacsMirrorRepos = $repos->list_user('emacsmirror');

my $page_counter = 1;
while ($repos->has_next_page) {

  $page_counter++;

  print "Fetching page $page_counter\n";

  push @emacsMirrorRepos, $repos->next_page;
}

print "num of repos: >" . (scalar @emacsMirrorRepos) . "<\n";
########################################

## Get just the names
my @repoNames = map { $_->{name} } @emacsMirrorRepos;

## Connect to the database
my $dbh;

# When this site is running in Heroku the database connection string
# is stored in the environment variable DATABASE_URL
#
# The format for this variable is the follow:
#
#    postgres://<$USERNAME>:<$PASSWORD>@<$HOST>:<$PORT>/<$DBNAME>
if (defined $ENV{DATABASE_URL}) {
  if ($ENV{DATABASE_URL} =~ m|^postgres://(.*?):(.*?)@(.*?):(.*?)/(.*?)$|) {
    my $username = $1;
    my $password = $2;
    my $host = $3;
    my $port = $4;
    my $dbname = $5;

    # The string used by DBD::Pg to connect to the PostgreSQL
    # database has the following format:
    #
    #    dbi:Ph:dbname=<$DBNAME>;host=<$HOST>;port=<$PORT>
    $dbh = DBI->connect("dbi:Pg:dbname=$dbname;host=$host;port=$port",
                        $username, $password,
                        {
                         AutoCommit => 0 }
                       );
  }
  # We are running this application locally
  elsif ($ENV{DATABASE_URL} =~ m|^postgres://localhost/(.*?)$|) {
    my $dbname = $1;

    $dbh = DBI->connect("dbi:Pg:dbname=$dbname", '', '', {AutoCommit => 0});
  }
  else {
    warn "Format of DATABASE_URL is wrong. Got $ENV{DATABASE_URL}";
  }
} else {
  die "Environment variable DATABASE_URL doesn't exist.";
}
########################################

# Create table if needed
print "Running CREATE TABLE\n";
$dbh->do('CREATE TABLE IF NOT EXISTS emacsmirror_repos (
              name TEXT NOT NULL UNIQUE
          )');



## Remove all the names that already exist in the database
my $namesInDB = $dbh->selectall_arrayref("SELECT name FROM emacsmirror_repos");

my %repoNamesInDB = map { $_->[0] => 1}
                    @{ $namesInDB };


my @namesToBeInserted = grep { not exists $repoNamesInDB{$_} }
                        @repoNames;
########################################


## Insert the new repos into the database
my $sth = $dbh->prepare('INSERT INTO emacsmirror_repos(name) VALUES (?)');

foreach my $repoName (@namesToBeInserted) {
  print "Inserting: $repoName\n";
  $sth->execute($repoName);
}

$dbh->commit();
########################################
