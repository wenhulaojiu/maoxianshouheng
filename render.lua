NVG_ALIGN_CENTER=1;NVG_ALIGN_MIDDLE=2;NVG_CW=1;NVG_ROUND=1
local commands={}
function nvgRGBA(r,g,b,a) return {r,g,b,a or 255} end
for _,name in ipairs({'BeginPath','ClosePath','MoveTo','LineTo','BezierTo','Arc','Circle','Ellipse','Rect','RoundedRect','Fill','FillColor','FillPaint','Stroke','StrokeColor','StrokeWidth','Save','Restore','Translate','Rotate','Scale','IntersectScissor','GlobalAlpha','LineCap','Text','TextAlign','FontFace','FontSize'}) do
 _G['nvg'..name]=function(_,...) commands[#commands+1]={name,...} end
end
for _,name in ipairs({'LinearGradient','RadialGradient','BoxGradient'}) do
 _G['nvg'..name]=function(_,...) return {kind=name,args={...}} end
end
local Art=require('CampaignArt')
function renderOriginal(w,h)
 commands={}
 local layout={x=0,y=0,w=w,h=h}
 local metrics=Art.Metrics(game,layout,{zoom=1,Offset=function()return 0,0 end},false)
 Art.Scene(1,game,layout,metrics)
 return encode(commands)
end
