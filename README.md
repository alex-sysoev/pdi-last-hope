# PDI Last Hope

A small elixir scraper based on [Hound](https://github.com/HashNuke/hound). It helps one to reserve appointment in chilean PDI.


## Usage

This application requires selenium server running, erlang and elixir installed. You can configure access to it in config files.
Also you must specify credentials to access `www.reservahora.extranjeria.gob.cl` and the procedure
you want to subscribe to.

To execute the app just run `iex -S mix`, that will open the elixir console with app's context and here you go. Application will automatically launsh the supervisor with scraping task. Once the appointment was resered the scraper terminates.
If there is no available time to reserve it starts again in 3 minutes automatically and restarts if error occures.

Another way to start application is to export your credentials:

```
export EMAIL=my@email.com
export PASSWORD=my-password
export ISSUE=33
```

then build release with `mix release` command and execute it in foreground `_build/dev/rel/pdi_last_hope/bin/pdi_last_hope foreground`.

Enjoy.

