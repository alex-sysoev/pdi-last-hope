# PDI Last Hope

A small elixir scraper based on [Hound](https://github.com/HashNuke/hound). It helps one to reserve appointment in chilean PDI.


## Usage

This application requires selenium server running. You can configure access to it in config files.
Also you must specify credentials to access `www.reservahora.extranjeria.gob.cl` and the procedure
you want to subscribe for.

To execute the app just run this `iex -S mix` that will open the elixir console with app's context.
After that just execute `PdiLastHope.exec` and here you go. Once the appointment was resered the scraper terminates.
If there is no available time to reserve it starts again in 3 minutes automatically and restarts if error occures.

Enjoy.

