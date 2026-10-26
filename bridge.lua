local data={unlockedLevel=1,tools={},campaignV2={saveVersion=2,unlockedLevel=1,completedLevels={},levelBestUnits={},bestStars={},toolUnlocks={},hiddenUnlocked=false,hiddenBadge=false,endingGallery={},clearRecords={},checkpoints={},nextAttemptId=0,migratedFromLegacy=true}}
package.preload.SaveStore=function() return {Load=function() return data end,Save=function(v) data=v;return true end,GetSetting=function(k) return ({lang='zh',textScale=1,followCamera=true,sound=80,music=80,effects=80,sfx=true,haptic=true})[k] end} end
package.preload.FX=function() return setmetatable({},{__index=function() return function() end end}) end
package.preload.InputState=function() return setmetatable({},{__index=function() return function(x) return ({interact='E',action='S',meow='Q',undo='U',restart='R'})[x] or tostring(x or '') end end}) end
function encode(v,seen)
 if type(v)=='nil' then return 'null' end
 if type(v)=='boolean' then return tostring(v) end
 if type(v)=='number' then return v==v and math.abs(v)<math.huge and tostring(v) or 'null' end
 if type(v)=='string' then return '"'..v:gsub('[%z\1-\31\\"]',function(c) return string.format('\\u%04x',string.byte(c)) end)..'"' end
 if type(v)~='table' then return 'null' end
 seen=seen or {};if seen[v] then return 'null' end;seen[v]=true
 local a={};local n=#v
 if n>0 then for i=1,n do a[#a+1]=encode(v[i],seen) end else for k,x in pairs(v) do if type(x)~='function' then a[#a+1]=encode(tostring(k))..':'..encode(x,seen) end end end
 seen[v]=nil;return (n>0 and '[' or '{')..table.concat(a,',')..(n>0 and ']' or '}')
end
local Game=require('WoolGame')
function startLevel(n) game=Game.NewCampaign(n) end
function action(name,arg)
 if name=='select' then game:Select(arg)
 elseif name=='jump' then game:Jump()
 elseif name=='carry' then game:ToggleCarry(game.active)
 elseif name=='interact' then game:Interact()
 elseif name=='undo' then game:Undo()
 elseif name=='reset' then game:Reset()
 elseif name=='meow' then game:Meow()
 elseif name=='laser' then game:ToggleLaser()
 elseif name=='gather' then game:Gather() end
end
function tick(dt,dir)
 game:Update(dt,dir)
 if game.won and not game.h5Committed then
  local net=game.level==11 and 0 or (game.campaign.secretCollected and 6 or 0)-game.campaign.lossUnits
  local _,ok=require('CampaignProgress').CommitClear(game.level,net,game:Stars(),game.campaign.attemptId)
  game.h5Committed=ok
 end
end
local function literal(v)
 if type(v)=='string' then return string.format('%q',v) end
 if type(v)~='table' then return tostring(v) end
 local t={};for k,x in pairs(v) do t[#t+1]='['..literal(k)..']='..literal(x) end
 return '{'..table.concat(t,',')..'}'
end
function saveBrowser() return encode(data) end
function restoreBrowser(v)
 if type(v)=='table' and type(v.campaignV2)=='table' then data=v end
end
function snapshot()
 local label,enabled,id=game:GetContextAction()
 return encode({level=game.level,def=game.def,cats=game.sheep,balls=game.balls,campaign=game.campaign,active=game.active,won=game.won,stars=game:Stars(),hint=game:Hint(3),context=label,contextId=id,yarn=game:YarnAmount(),platforms=game.def.platforms})
end
function exportLevels() return encode(require('CampaignLevels').DEFS) end
