# Elm-Data

This is an experiment and **is not meant for production use** any time soon.

Elm-Data aims to provide a library to load RESTful data from an API. You define a type alias for what your data looks like and it generates functions to load and retrieve the data, handling parsing, encoding, caching, error logging, and so on.

That's the goal, anyway. Currently, I only have a working example of what the generated code could look like for a simple resource (a `Book`). I also have a minimal Elm app that uses the "generated" code to let you load the data in a UI. Oh, and the server is expected to conform to [JSON API](http://jsonapi.org/format/).

There are two steps to obtaining a resource. First, `load` will create a Cmd that will fetch the data if it's not already present. Then, `get` will retrieve the data you have loaded for rendering (placed in a [RemoteData](http://package.elm-lang.org/packages/krisajenkins/remotedata/latest/RemoteData) container).

To run the example, run `elm-reactor` and navigate to `src/ui/Main.elm`. Also start the server (written in Ruby):

```shell
cd server
gem install bundler
bundle install
bundle exec ruby server.rb
```
