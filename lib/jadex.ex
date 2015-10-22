import ExParsec.Base
import ExParsec.Text

#Parse module
defmodule JadEx.Parse do

	##
	#Handles a single line
	#
	def line() do
		choice [
			ignore(sequence( [JadEx.Helpers.handle_tab, either(newline, eof) ])), 		#Ignores empty lines. TODO: make sure it doesn't interfere with multi line strings :(
			sequence( [JadEx.Helpers.handle_tab, line_parsers, either(newline, eof) ])	#Sends everything else to the 
		]
	end

	##
	# Tries every line type
	defp line_parsers do
		choice [
			simple_tag
		]
	end

	##
	# Simplest Jade tag
	#	[tagname][id/classes]_space_[text]
	# `div.menu-left#list Hello there`
	#
	defp simple_tag() do
		#IO.puts "3test"
		sequence [
			tag_name#,   #Selects _the_ tag. Can be alphanumeric only
			#id_class	#Selects tagname/classname. [A-Z][0-9][-]
		]
	end

	##
	#Tries to find the tag name, returns "div" is none
	#
	defp tag_name do #Returns tagname if set. Div if not
		map(
			many(alphanumeric), fn(x)->
				if (length(x) == 0 ) do
					ret = "div"
				else
					ret = to_string(x)
				end
				{:ok, {:tag_name, ret}}
			end
		)
	end
	##
	# Part of the basic handler
	# Handles stuff like 
	# #test.yourclass
	#
	defp id_class() do
		map many1(
				map(sequence([
						either(string("#"), string(".")),
						many( either(alphanumeric, string("-")) )
					]), fn(x)->

						cond do
							hd(x) == "#"->
								type = "id"
							hd(x) == "."->
								type = "class"
						end
						return {:ok, {type: type, value: to_string(tl(x))}}
					end
				)

			), fn(x)-> #This aggregates all of the ids/tags. Ensures that length(id) <=1. Returns: :id => "", :classes => ["",...]
				IO.inspect x
				{:ok, {:tag_name, to_string(x)}}
			end
	end
end


defmodule JadEx.Helpers do
	def handle_tab() do
		map many(tab), fn(x)->{:ok, {:indent_level, length(x)}}end
	end
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