
local command = {}
function command.run(message, mt)
  print("lmao someone did c!yeetalltokens")
  local cmember = message.guild:getMember(message.author)
  if cmember:hasRole(privatestuff.modroleid) then
    for i,v in ipairs(scandir("savedata")) do
      local cuj = dpf.loadjson("savedata/"..v,defaultjson)
      if cuj.lastpull then
        cuj.lastpull = -24
        cuj.lastprayer = -24
        cuj.lastequip = -24
        cuj.tokens = 0
      end
      cuj.tokens = 0
      dpf.savejson("savedata/"..v,cuj)
    end
    message.channel:send("Bruh you just deleted everyone's tokens")
  else
    message.channel:send('Sorry, but only moderators can use this command!')
  end
end
return command
  