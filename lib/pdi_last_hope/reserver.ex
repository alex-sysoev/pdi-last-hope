defmodule PdiLastHope.Reserver do
  use Task, restart: :transient

  def start_link([]) do
    Task.start_link(__MODULE__, :run, [])
  end

  def run do
    date =
      :calendar.local_time()
      |> elem(0)
      |> Date.from_erl!()

    time =
      :calendar.local_time()
      |> elem(1)
      |> Time.from_erl!()

    IO.puts "Starting/Restarting scraper at #{date} : #{time}."

    case PdiLastHope.exec() do
      :done ->
        :done

      :restart ->
        :timer.sleep(3 * 60_000)
        run()
    end
  end
end