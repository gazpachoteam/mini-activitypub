# Hanatachi

Hanatachi is a **free, open-source social network server** for **federated blogging** based on the ActivityPub open web protocol.

## Configuration for development and test environments

Prerequisites: install git, Ruby 2.4.2, bundler gem, and MySQL (5.7.5+).

```bash
git clone https://gitlab.com/ortegacmanuel/hanatachi.git
cd hanatachi
bundle install
cp config/application.yml.example config/application.yml
bin/rake db:create
bin/rake db:migrate
```

Run the app locally:

```
bin/rails s
```
