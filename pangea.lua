-- pang: polish notation language
-- pang: linguaggio a notazione polacca

local pang_version="028 (PanGea:1.0.1)" -- versione
local language=nil --"italian" -- lingua -- nil

if arg[1]=="italian" then
  language="italian"
  table.remove(arg, 1)
end

local translate_italian={
  ["pang version: "]="pang versione: ",
  ["exit"]="esci",
  ["print"]="stampa",
  ["define_word"]="definisci_parola",
  ["multiply"]="moltiplica",
  ["argument"]="argomento",
  ["do"]="fai",["end"]="fine",
  
  ["set"]="metti",
  ["get"]="prendi",
  ["variable_set"]="metti_variabile",
  ["variable_get"]="prendi_variabile",
  ---metti_chiamante
  ["caller_set"]="metti_chiamante",
  ["caller_get"]="prendi_chiamante",
  
  ["while"]="mentre",
  ["not"]="non",
  ["greater"]="maggiore",

  ["if"]="se",
  ["equal"]="uguale",
  ["modulus"]="modulo",
  ["string"]="stringa",
  ["add"]="somma",
  
  ["true"]="vero",
  ["false"]="falso",
  
  ["dont"]="non_fare",
  
  ["word:"]="parola:",
  [" definition not found"]=" definizione non trovata",
  
  ["command_prompt"]="richiesta_comandi",
  
}
function tr(string) -- translate / traduci
  if language=="italian" then -- italiano supportato
    local traduced=translate_italian[string]
    if traduced==nil then print("can't translate: "..string) return string end
    return traduced
  end
  return string
end
print(tr("pang version: ")..pang_version)

local words={}

local word_definitions={}

-- print <printable>
function print_function(arguments)
  local value=evaluate_word(arguments[1])
  print(value)
  return value
end

-- add <number> <number>
function add_function(arguments)
  local first_number=evaluate_word(arguments[1])
  local second_number=evaluate_word(arguments[2])
  return first_number+second_number
end

-- multiply <number> <number>
function multiply_function(arguments)
  return evaluate_word(arguments[1])*evaluate_word(arguments[2])
end

function true_function(arguments)
  return true
end
function false_function(arguments)
  return false
end

-- if <condition> <if true> <if false>
function if_function(arguments)
  if evaluate_word(arguments[1]) then
    return evaluate_word(arguments[2])
  else
    return evaluate_word(arguments[3])
  end
end

-- while <condition> <do while true>
function while_function(arguments)
  while evaluate_word(arguments[1]) do
    local result=evaluate_word(arguments[2])
    if result=="break" then break end
  end
end

-- not <boolean>
function not_function(arguments)
  return not evaluate_word(arguments[1])
end

-- equal <first to compare> <second to compare>
function equal_function(arguments)
  local first=evaluate_word(arguments[1])
  local second=evaluate_word(arguments[2])
  return first==second
end

--local variables={}
local call_stack={{}}

-- get <variable name>
function get_function(arguments)
  local variables=call_stack[#call_stack]
  local variable_name=evaluate_word(arguments[1])
  local returned_value=variables[variable_name]
  if returned_value==nil then print("nil returning from get_function()") end
  return returned_value
end

-- set <variable name> <value to set>
function set_function(arguments)
  local variables=call_stack[#call_stack]
  local variable_name=evaluate_word(arguments[1])
  local variable_value=evaluate_word(arguments[2])
  variables[variable_name]=variable_value
end

word_definitions[tr("set")]={2,set_function}
word_definitions[tr("get")]={1,get_function}

---------------------------------------

-- variable_get <namespace> <variable name>
function variable_get_function(arguments)
  local namespace=evaluate_word(arguments[1])
  local variable_name=evaluate_word(arguments[2])
  return namespace[variable_name]
end

-- variable_set <namespace> <variable name> <value to set>
function variable_set_function(arguments)
  local namespace=evaluate_word(arguments[1])
  local variable_name=evaluate_word(arguments[2])
  local variable_value=evaluate_word(arguments[3])
  namespace[variable_name]=variable_value
end

--variable_
word_definitions[tr("variable_set")]={3,variable_set_function}
word_definitions[tr("variable_get")]={2,variable_get_function}

--
word_definitions["namespace"]={0,function() return call_stack[#call_stack] end }
---------------------------------------
-- string <word as string>
function string_function(arguments)
  return words[arguments[1]]
end

-- word <word (not processed)>
function word_function(arguments)
  return words[arguments[1]]
end

-- modulus <dividend> <divisor>
function modulus_function(arguments)
  return evaluate_word(arguments[1])%evaluate_word(arguments[2])
end
function lesser_than_or_equal_function(arguments)
  return evaluate_word(arguments[1])<=evaluate_word(arguments[2])
end
-- greater <lesser> <greater>
function greater_function(arguments)
  return evaluate_word(arguments[1])>evaluate_word(arguments[2])
end
-- local word_definitions
--word_definitions={
word_definitions[tr("print")]={1,print_function}
word_definitions[tr("add")]={2,add_function}
word_definitions[tr("true")]={0,true_function}
word_definitions[tr("false")]={0,false_function}
word_definitions[tr("if")]={3,if_function}
word_definitions[tr("while")]={2,while_function}
word_definitions[tr("not")]={1,not_function}
word_definitions[tr("equal")]={2,equal_function}

word_definitions[tr("string")]={1,string_function}
word_definitions[tr("modulus")]={2,modulus_function}
word_definitions[tr("greater")]={2,greater_function}
word_definitions[":"]={1,word_function}
--}

word_definitions[tr("multiply")]={2,multiply_function}

function list_word_definitions_function(arguments)
  for word,word_definition in pairs(word_definitions) do
    io.write(word.."<"..word_definition[1].." ")
  end
  io.write("\n")
end
word_definitions["?"]={0,list_word_definitions_function}

function phrase_length(word_index)
  local word=words[word_index]
  local length=1
  if word_index>1 and words[word_index-1]==":" then return 1 end
  if word==tr("do") then
    while true do
      if words[word_index+length]==tr("end") or 
      words[word_index+length]==nil
      then return length+1 end
      length=length+phrase_length(word_index+length)
    end
  end
  local number=tonumber(word)
  if number~=nil then return 1 end
  local word_definition=word_definitions[word]
  
  --if word_definition==nil or word_index>1 and (words[word_index-1]==tr("string") or words[word_index-1]==tr("define_word") or words[word_index-1]==tr("set") or words[word_index-1]==tr("increment")) then return 1 end
  
  ----if word_definition==nil or word_index>1 and words[word_index-1]==":" then return 1 end
  --if word_index>1 and words[word_index-1]==":" then return 1 end
  if word_definition==nil then return 1 end
  
  local argument_length=word_definition[1]
  for argument_index=1,argument_length do
    length=length+phrase_length(word_index+length)
  end
  return length
end

function evaluate_word(word_index)
  local returned_value
  local word=words[word_index]
  returned_value=tonumber(word)
  if returned_value~=nil then return returned_value end
  local word_definition
  word_definition=word_definitions[word]
  if word==tr("do") then
    local do_word_index=word_index+1
    local evaluated
    while words[do_word_index]~=tr("end") and words[do_word_index]~=nil do
      evaluated=evaluate_word(do_word_index)
      local current_phrase_length=phrase_length(do_word_index)
      do_word_index=do_word_index+current_phrase_length
    end
    return evaluated
  end
  if nil==word_definition then print(tr("word:")..word..tr(" definition not found")) return end
  local arguments={}, arity, argument_word_index
  arity=word_definition[1]
  argument_word_index=word_index+1
  for argument_index=1,arity do
    table.insert(arguments,argument_word_index)
    argument_word_index=argument_word_index+phrase_length(argument_word_index)
  end
  returned_value=word_definition[2](arguments)
  return returned_value
end

function program_words(pn_program)
  local quoted=""
  local opened=false
  local quote='"'
  for word in string.gmatch(pn_program, "%S+") do
    if word==quote then
      if opened then
        --print(quote..quoted..quote)
        table.insert(words,quoted)
        quoted=""
      end
      opened=not opened
    elseif opened then
      if quoted~="" then quoted=quoted.." " end
      quoted=quoted..word
    else
      --print(word)
      table.insert(words,word)
    end
  end
end

function execute_program(pn_program)

  pn_program=tr("do").." "..pn_program.." "..tr("end")

  local words_to_add=#words
  
  --[[
  for word in string.gmatch(pn_program, "%S+") do
    table.insert(words,word)
  end
  --]]
  --words=program_words(pn_program)
  program_words(pn_program)
  
  if #words==words_to_add then
    --print("empty program")
    return
  end
  
  if false then -- DEBUG
    for word_index=words_to_add+1,#words do
      io.write("["..words[word_index].."]"..phrase_length(word_index).." ")
    end
    print()
  end

  evaluate_word(1+words_to_add)

end

-- ignore hashbang if present
function hashbang_remove(pn_program)
    function remove_first_line(text)
        i=string.find(text,"\n")
        return string.sub(text,i+1)
    end
    if pn_program:sub(1,1)=="#" then -- hasbang present
        pn_program=remove_first_line(pn_program)
    end
    return pn_program
end
  
function execute_words_file(file_name)
  --local file_name=words[arguments[1]]
  local file=io.open(file_name,"r")
  
  local program=""
  while true do
    local program_line=file:read()
    if program_line==nil then break end
    program=program..program_line.."\n"
  end
  
  file:close()
  
  -- ignore hashbang if present
  program=hashbang_remove(program)

  --print(program)
  execute_program(program)
end

-- execute_words_file <filename>
function execute_words_file_function(arguments)
  local file_name=evaluate_word(arguments[1])
  execute_words_file(file_name)
end
word_definitions["!"]={1,execute_words_file_function}

-- dont <skip this>
word_definitions[tr("dont")]={1,function() end}

--local call_stack={{}}
-- define_word <name> <arity> <action>
function define_word_function(arguments)
  local arity=evaluate_word(arguments[2])
  local word_function=function(word_arguments)
    
    local value_arguments={}
    for argument_index,word_argument in pairs(word_arguments) do
      value_arguments[argument_index]=evaluate_word(word_argument)
    end
    
    local returned
    table.insert(call_stack,value_arguments)
    returned=evaluate_word(arguments[3])
    table.remove(call_stack)
    return returned
  end
  word_definitions[evaluate_word(arguments[1])]={arity,word_function}
end
word_definitions[tr("define_word")]={3,define_word_function}

-- argument <argument index>
function argument_function(arguments)
  local last=call_stack[#call_stack]
  local argument_index=evaluate_word(arguments[1])
  local returned=last[argument_index]
  return returned
end
word_definitions[tr("argument")]={1,argument_function}

-- TEST for word definition and use with arguments
-- porting to Italian added
--execute_program("define_word square 1 multiply argument 1 argument 1")  --> English
--execute_program("definisci_parola quadrato 1 moltiplica argomento 1 argomento 1") --> Italian
--execute_program("print square 4") --> 16 --> English
--execute_program("stampa quadrato 4") --> 16 --> Italian

-- TEST for recursion
--execute_program("define_word factorial 1 if equal 0 argument 1 1 multiply argument 1 factorial add -1 argument 1")
--execute_program("print factorial 0") --> 1
--execute_program("print factorial 4") --> 24

function read_execute_loop()
  while true do
    local program=io.read()
    if program==nil or program==tr("exit") then break end --- may it be "end"? TODO
    execute_program(program)
  end
end
word_definitions[tr("command_prompt")]={0,read_execute_loop}

-- EXAMPLES
--- metti i somma 1 prendi i
function increment_function(arguments)
  local variables=call_stack[#call_stack]
  local variable_name=evaluate_word(arguments[1]) --evaluate_word(arguments[1])
  variables[variable_name]=variables[variable_name]+1
  local return_value=variables[variable_name]
  return return_value
end


-- definition
translate_italian["increment"]="incrementa"
word_definitions[tr("increment")]={1,increment_function}

---]] block WIP considered harmful getting the caller's namespace without caller passing it
-- definition
translate_italian["get_caller"]="prendi_chiamante"
word_definitions[tr("get_caller")]={1,get_caller_function}

-- definition
translate_italian["set_caller"]="metti_chiamante"
word_definitions[tr("set_caller")]={2,set_caller_function}
--]]


local test_string_bug_hunt=[[

stampa 1
: non_fare
: fai
stampa 2

]]

-- : non_fare
-- : fai
--- TO DO incrementa stringa i   | incrementa : 1
test_string=[[

: " 'incrementa' is a Lua function "

: non_fare
: fai

 : inizio

metti : i 1
stampa prendi : i
incrementa : i
incrementa : i
stampa prendi : i

: fine

non_fare
fai

stampa : " ('conta1') namespaces issues (previous way, not working, security issues) "

definisci_parola : prendi_chiamante 1 : " not implemented here (chiamante means caller function/namespace) "
definisci_parola : metti_chiamante 2 : " not implemented here "

definisci_parola : conta1 1 non_fare metti_chiamante argomento 1 somma 3 prendi_chiamante argomento 1

metti : n 1
stampa prendi : n
conta1 : n
stampa prendi : n
conta1 : n
stampa prendi : n

stampa : " ('conta2') namespaces issues (current way, working). security issue namespace can be accessed for other variables beyond the one specified by name "

definisci_parola : conta2 2 metti_variabile argomento 2 argomento 1 somma prendi_variabile argomento 2 argomento 1 3

metti : n 1
stampa prendi : n
conta2 : n namespace
stampa prendi : n
conta2 : n namespace
stampa prendi : n

stampa : " 'conta0' previous work... much started from here "
metti : numero 10
definisci_parola : conta0 1 metti argomento 1 somma 1 prendi argomento 1
non_fare conta0 : numero
stampa prendi : numero
]]
--execute_program(test_string) -- test_string_bug_hunt

--execute_words_file("principale-001.parole")

function main()
  print("? for help")
  local filename=arg[1]
  if filename~=nil then 
    if filename=="-" then read_execute_loop() else
    execute_words_file(filename)
    if arg[2]=="-" then read_execute_loop() end
    end
  else
    read_execute_loop()
  end
  print("bye")
end
main()
