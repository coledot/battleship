# Battleship

Battleship in Ruby/Rails and Coffeescript. If it looks janky, that's on purpose. Currently incomplete.

NOTE: To start a new game, you must restart the server. The database is cleared on restart as well.

Usage (w/ Docker):

- `docker build .` and note the ID of the newly created image, it will be a string of hex chars on the last line, like "Successfully built $container_id"

- `docker run --publish 3000:3000 --detach --name battleship $container_id` (with $container_id replaced with the above ofc)

- `docker start battleship`

- First player should point their browser to `localhost:3000`, a ship layout will be assigned to them

- Repeat for second player

- ...and that's it for now :/

Usage (w/o Docker):

- `bundle exec rails server`

- Remaining steps are same as w/ Docker from step 4 onward

