package ParseGithubFeed;

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

use XML::Feed;
use Data::Dumper;
use Net::GitHub::V3;
use DateTime;
use DateTime::Format::ISO8601;
use File::Slurp;

# Receive a hash containing the data returned by Net::GitHub::Query
# and return a hash with the following fields:
#
#     owner        -> Name of the owner of the repository
#     name         -> Name of the repository
#     url          -> Url of the repository
#     created_at   -> DateTime object containing the date of creation of the repository
#     description  -> Description of the repository
sub makeRepository {
  my $param = shift;
  return {
          owner => $param->{owner},
          name => $param->{name},
          url => $param->{url},
          created_at => DateTime::Format::ISO8601->parse_datetime($param->{created_at}),
          description => $param->{description},
         };
}

# Connects to the github API and downloads the "emacs-lisp"
# repositories created during the current day.
#
# The Github key should be in the environment variable GITHUB_TOKEN.
#
# Receives nothing.
#
# Returns an array containing the hashrefs returned by
# "makeRepository". The repositories are sorted by their creation date.
sub fetchRepositories {
  my $token = $ENV{GITHUB_TOKEN};

  # use OAuth to create token with user/pass
  my $github = Net::GitHub::V3->new(access_token => $token);


  my $search = $github->search;

  # Current date in format YYYY/MM/DD
  my $today = DateTime->now->ymd;


  my %data = $search->repos(sprintf('language:emacs-lisp created:%s', $today));


  my @parsedData = sort { DateTime->compare($a->{created_at}, $b->{created_at}) }
                   map { makeRepository($_) }
                   @{$data{repositories}};

  return @parsedData;
}

sub makeFeed {
  my @repositories = fetchRepositories();


  my $feed = XML::Feed->new('Atom');

  $feed->title("New GitHub Emacs Lisp Repos");
  $feed->link("http://github-elisp.herokuapp.com");

  foreach my $repo (@repositories) {
    $feed->add_entry(makeAtomEntry($repo));
  }

  return $feed->as_xml;
}


# Create an Atom entry for a single repository
#
# Receives a hash as returned by the function "makeRepository"
#
# Returns a XML::Feed::Entry object
sub makeAtomEntry {
  my $repoData = shift;

  my $entry = XML::Feed::Entry->new();
  $entry->link($repoData->{url});
  $entry->title($repoData->{name});
  $entry->summary($repoData->{description});
  $entry->modified($repoData->{created_at});
  $entry->author($repoData->{owner});

  return $entry;
}

# sub getEmacsMirrors {
#   my $token = read_file("token.txt");

#   # use OAuth to create token with user/pass
#   my $github = Net::GitHub::V3->new(access_token => $token);


#   my $repos = $github->repos;

#   my @repos = $repos->list_user('emacsmirror');
#   while ($repos->has_next_page) {
#     print "Ping...\n";

#     push @repos, $repos->query($repos->next_url);
#   }

#   my @rp = map { $_->{name} } @repos;

#   return @rp;
# }

# sub makeFeedNoMirror {
#   my @repositories = fetchRepositories();

#   my %repos = map { $_ => 1 } getEmacsMirrors();

#   my @foo = grep { not exists $repos{$_} } @repositories;
# }


1;
