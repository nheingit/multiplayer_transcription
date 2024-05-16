defmodule MultiTranscription.MP3Stat do
  def parse(path) do
    case System.cmd("ffmpeg", ["-i", path, "-f", "null", "-"], stderr_to_stdout: true) do
      {output, 0} ->
        case parse_duration(output) do
          {:ok, duration} -> {:ok, %{duration: duration}}
          error -> error
        end

      {error_message, _} ->
        {:error, error_message}
    end
  end

  defp parse_duration(output) do
    case Regex.run(~r/Duration: (\d+):(\d+):(\d+\.\d+)/, output) do
      [_, hours, minutes, seconds] ->
        duration =
          String.to_integer(hours) * 3600 +
            String.to_integer(minutes) * 60 +
            String.to_float(seconds)

        {:ok, duration}

      _ ->
        {:error, "Unable to parse duration"}
    end
  end
end
