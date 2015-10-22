defmodule JadEx do
end


#Supervisor module that allows calling from CLI <mix run --no-halt>
defmodule JadEx.CLI do

	use Application

	def start(_type, _args) do
		Task.start &JadEx.CLI.startCLI/0
	end

	def startCLI() do
		#spec.jade => will be used for tests later
		x = File.read! 'spec.jade'
		IO.puts x
		ExParsec.parse_value(x, many JadEx.Parse.line) |> IO.inspect
		IO.puts 'Done'
		#ExParsec.parse_value x, many sequence([letter, newline]) |> IO.inspect
	end
end