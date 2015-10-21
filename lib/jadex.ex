defmodule JadEx do
end
defmodule JadEx.CLI do

	use Application

	def start(_type, _args) do
		#Task.start &JadEx.CLI.startCLI/0
		IO.puts "Nothing"
	end

	def startCLI() do
		x = File.read! 'test.jade'
		IO.puts x
		ExParsec.parse_value(x, many JadEx.Parse.line) |> IO.inspect
		IO.puts 'Done'
		#ExParsec.parse_value x, many sequence([letter, newline]) |> IO.inspect
	end
end