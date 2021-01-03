-- ok i know ths code is hot stinky garbage but it *works*, god damn-it.


-- it works most of the time. most of the time.
local discordia = require('discordia')
local client = discordia.Client()
_G["prefix"] = "c!"
_G["privatestuff"] = require('privatestuff')
_G["json"] = require('libs/json')
_G["fs"] = require('fs')
_G["dpf"] = require('libs/dpf')
_G["utils"] = require('libs/utils')
_G["inspect"] = require('libs/inspect')
_G["trim"] = function (s)
   return s:match "^%s*(.-)%s*$"
end



-- import all the commands
_G['cmd'] = {}
cmd.ping = require('commands/ping')
cmd.help = require('commands/help')
cmd.resetclock = require('commands/resetclock')
cmd.uptime = require('commands/uptime')
cmd.testcards = require('commands/testcards')
cmd.pull = require('commands/pull')
cmd.inventory = require('commands/inventory')
cmd.show = require('commands/show')
cmd.give = require('commands/give')
cmd.trade = require('commands/trade')
cmd.store = require('commands/store')
cmd.storage = require('commands/storage')
cmd.checkcollectors = require('commands/checkcollectors')
cmd.checkmedals = require('commands/checkmedals')
cmd.reloaddb = require('commands/reloaddb')
cmd.medals = require('commands/medals')
cmd.crash = require('commands/crash')
cmd.showmedal = require('commands/showmedal')


-- import reaction commands
cmdre = {}
cmdre.trade = require('reactions/trade')
cmdre.store = require('reactions/store')

_G['defaultjson'] = {inventory={},storage={},medals={},lastpull=-24}

_G['debug'] = true



_G['sw'] = discordia.Stopwatch()
sw:start()
cj =  io.open("data/cards.json", "r")
_G['cdata'] = json.decode(cj:read("*a"))
cj:close()
--generate pull table
_G['ptable'] = {}
_G['cdb'] = {}
for i,v in ipairs(cdata.groups) do
  for w,x in ipairs(v.cards) do
    
    for y=1,(cdata.basemult*v.basechance*x.chance) do
      table.insert(ptable,x.filename)
    end
    table.insert(cdb,x)
    print(x.name.. " loaded!")
  end
end
print("here is cdb")
print(inspect(cdb))
print("here is ptable")
print(inspect(ptable))

print("loading collector's info")
_G['coll'] = dpf.loadjson("data/coll.json",defaultjson)
print("loading medaldb")
_G['medaldb'] = dpf.loadjson("data/medals.json",defaultjson)
print("loading medal requires")
_G['medalrequires'] = dpf.loadjson("data/medalrequires.json",defaultjson)

print("loading functions")

_G['fntoname'] = function (x)
  print("finding "..x)
  for i,v in ipairs(cdb) do
    if string.lower(v.filename) == string.lower(x) then
      local match = v.name
      print(x.." = "..v.name)
      return v.name
    end
  end
  
end

_G['nametofn'] = function (x)
  for i,v in ipairs(cdb) do
    if string.lower(v.name) == string.lower(x) then
      local match = v.filename
      return v.filename
    end
  end
end

_G['resetclocks'] = function ()
  for i,v in ipairs(scandir("savedata")) do
    cuj = dpf.loadjson("savedata/"..v,defaultjson)
    if cuj.lastpull then
      cuj.lastpull = -24
    end
    dpf.savejson("savedata/"..v,cuj)
  end
end
--really cool and good code goes here
--variable = "string" .. nilvalue

_G['texttofn'] = function (x)
  local cfn = nametofn(x)
  if cfn == nil then
    cfn = fntoname(x)
    if cfn ~= nil then
      cfn = string.lower(x)
    end
  end
  return cfn
end
_G['medalnametofn'] = function (x)
  for k,v in pairs(medaldb) do
    if string.lower(v.name) == string.lower(x) then
      local match = k
      return k
    end
  end
end
_G['medalfntoname'] = function (x)
  print("finding "..x)
  for k,v in pairs(medaldb) do
    if string.lower(k) == string.lower(x) then
      local match = v.name
      print(x.." = "..v.name)
      return v.name
    end
  end
  
end

_G['medaltexttofn'] = function (x)
  local cfn = medalnametofn(x)
  if cfn == nil then
    cfn = medalfntoname(x)
    if cfn ~= nil then
      cfn = string.lower(x)
    end
  end
  return cfn
end


-- Lua implementation of PHP scandir function
_G['scandir'] = function (directory)
  return fs.readdirSync(directory)
end

_G['usernametojson'] = function (x)
  for i,v in ipairs(scandir("savedata")) do
    cuj = dpf.loadjson("savedata/"..v,defaultjson)
    if cuj.name == x then
      return "savedata/"..v
    end
  end
end

_G['addreacts'] = function (x)
  x:addReaction("✅")
  x:addReaction("❌")
end

client:on('ready', function()
	print('Logged in as '.. client.user.username)
end)
print("yay got past load ready")
client:on('messageCreate', function(message)
  if message.author.id ~= "767445265871142933" then --failsafe to avoid recursion
    
    local status, err = pcall(function ()
      if string.sub(message.content, 0, 4+3) == prefix.. 'ping' then 
        local mt = string.split(string.sub(message.content, 4+4),"/")
        local nmt = {}
        for i,v in ipairs(mt) do
          v = trim(v)
          nmt[i]=v
        end
        cmd.ping.run(message,mt)
      elseif string.sub(message.content, 0, 4+3) == prefix.. 'help' then 
        print("this is a call for help")
        local mt = string.split(string.sub(message.content, 4+4),"/")
        local nmt = {}
        for i,v in ipairs(mt) do
          v = trim(v)
          nmt[i]=v
        end
        cmd.help.run(message,mt)
      elseif string.sub(message.content, 0, 10+3) == prefix.. 'resetclock' then 
        print("hee hoo clocks go reset")
        local mt = string.split(string.sub(message.content, 10+4),"/")
        local nmt = {}
        for i,v in ipairs(mt) do
          v = trim(v)
          nmt[i]=v
        end
        cmd.resetclock.run(message,mt)
      elseif string.sub(message.content, 0, 6+3) == prefix.. 'uptime' then 
        local mt = string.split(string.sub(message.content, 6+4),"/")
        local nmt = {}
        for i,v in ipairs(mt) do
          v = trim(v)
          nmt[i]=v
        end
        cmd.uptime.run(message,mt)
      elseif string.sub(message.content, 0, 9+3) == prefix.. 'testcards' then 
        local mt = string.split(string.sub(message.content, 9+4),"/")
        local nmt = {}
        for i,v in ipairs(mt) do
          v = trim(v)
          nmt[i]=v
        end
        cmd.testcards.run(message,mt)
      elseif string.sub(message.content, 0, 4+3) == prefix.. 'pull' then 
        local mt = string.split(string.sub(message.content, 4+4),"/")
        local nmt = {}
        for i,v in ipairs(mt) do
          v = trim(v)
          nmt[i]=v
        end
        cmd.pull.run(message,mt)      
      elseif string.sub(message.content, 0, 9+2) == prefix.. 'inventory' then 
        print("wow its inventory")
        local mt = string.split(string.sub(message.content, 9+4),"/")
        local nmt = {}
        for i,v in ipairs(mt) do
          v = trim(v)
          nmt[i]=v
        end
        print(inspect(nmt))
        cmd.inventory.run(message,nmt)
      elseif string.sub(message.content, 0, 3+2) == prefix.. 'inv' then 
        print("wow its inv")
        local mt = string.split(string.sub(message.content, 3+4),"/")
        local nmt = {}
        for i,v in ipairs(mt) do
          v = trim(v)
          nmt[i]=v
        end
        print(inspect(nmt))
        cmd.inventory.run(message,nmt)
      elseif string.sub(message.content, 0, 4+3) == prefix.. 'show ' then 
        local mt = string.split(string.sub(message.content, 4+4),"/")
        local nmt = {}
        for i,v in ipairs(mt) do
          v = trim(v)
          nmt[i]=v
        end
        cmd.show.run(message,nmt)      
      elseif string.sub(message.content, 0, 4+3) == prefix.. 'give ' then 
        local mt = string.split(string.sub(message.content, 4+4),"/")
        local nmt = {}
        for i,v in ipairs(mt) do
          v = trim(v)
          nmt[i]=v
        end
        cmd.give.run(message,nmt)      
      elseif string.sub(message.content, 0, 5+3) == prefix.. 'trade ' then 
        local mt = string.split(string.sub(message.content, 5+4),"/")
        local nmt = {}
        for i,v in ipairs(mt) do
          v = trim(v)
          nmt[i]=v
        end
        cmd.trade.run(message,nmt)      
      elseif string.sub(message.content, 0, 5+3) == prefix.. 'store ' then 
        local mt = string.split(string.sub(message.content, 5+4),"/")
        local nmt = {}
        for i,v in ipairs(mt) do
          v = trim(v)
          nmt[i]=v
        end
        cmd.store.run(message,nmt)      
      elseif string.sub(message.content, 0, 7+3) == prefix.. 'storage' then 
        local mt = string.split(string.sub(message.content, 7+4),"/")
        local nmt = {}
        for i,v in ipairs(mt) do
          v = trim(v)
          nmt[i]=v
        end
        cmd.storage.run(message,mt)
      elseif string.sub(message.content, 0, 8+3) == prefix.. 'reloaddb' then 
        local mt = string.split(string.sub(message.content, 8+4),"/")
        local nmt = {}
        for i,v in ipairs(mt) do
          v = trim(v)
          nmt[i]=v
        end
        cmd.reloaddb.run(message,mt)
      elseif string.sub(message.content, 0, 6+2) == prefix.. 'medals' then 
        print("wow its medals")
        local mt = string.split(string.sub(message.content, 6+4),"/")
        local nmt = {}
        for i,v in ipairs(mt) do
          v = trim(v)
          nmt[i]=v
        end
        print(inspect(nmt))
        cmd.medals.run(message,nmt)
      elseif string.sub(message.content, 0, 5+3) == prefix.. 'crash' then 
        print("this is a call for crash")
        local mt = string.split(string.sub(message.content, 5+4),"/")
        local nmt = {}
        for i,v in ipairs(mt) do
          v = trim(v)
          nmt[i]=v
        end
        cmd.crash.run(message,mt)
      elseif string.sub(message.content, 0, 9+3) == prefix.. 'showmedal ' then 
        local mt = string.split(string.sub(message.content, 9+4),"/")
        local nmt = {}
        for i,v in ipairs(mt) do
          v = trim(v)
          nmt[i]=v
        end
        cmd.showmedal.run(message,nmt)      
      end
    end)
    if not status then
      print("uh oh")
      message.channel:send("Oops! An error has occured! Error message: ```" .. err .. "``` (<@290582109750427648> please fix this thanks)")
    end
  end



end)
print("ok commands loaded, doing reactions")

client:on('reactionAdd', function(reaction, userid)
  if userid ~= "767445265871142933" then
    local ef = dpf.loadjson("savedata/events.json",{})
    print('a reaction with an emoji named '.. reaction.emojiName .. ' was added to a message with the id of ' .. reaction.message.id ..' by a user with the id of' .. userid)
    eom = ef[reaction.message.id]
    if eom then
      print('it is an event message being reacted to')
      if eom.etype == "trade" then
        cmdre.trade.run(ef, eom, reaction, userid)
      elseif eom.etype == "store" then
        print('it is a storage message being reacted to')
        cmdre.store.run(ef, eom, reaction, userid)
      end
      
      
      
      
    end
  end


end)
print("resettingclocks")
resetclocks()



client:run(privatestuff.botid)