require("app.utils.GameUtils")
require("app.utils.Player")
require("app.utils.net.HttpManager")
require("app.utils.TestProfile")
require("app.utils.GCMgr")

local TestScene = class("TestScene", function()
    return display.newScene("TestScene")
end)

function TestScene:ctor()
    self:onUpdate(function (  )
            MArmatureUtils:updateMArmature(1)
       
   	end)
--    local scene = MUI.MLayer.new()
--    self:addChild(scene)
--    testMLabel(scene)
   self:testRichTestEx()
    --self:testArm2()
end

function TestScene:testRichTestEx()
    local RichTextEx = require("app.common.richview.RichTextEx")
    require("app.worldlan.ColorUtils")
    addTextureToCache("icon/p1_icon8", 1, true)

    local sHtml = "<font color='#31d840'>占领\n殿、宫</font><u>全国@猪头#可获得</u><font color='#31d840'>国家百姓加成</font>本国殿范\n围内进行<font color='#31d840'>采集</font>、<font color='#31d840'>击杀乱军</font>能为殿提供经"
    --local sHtml = "@猪头#"
    --local tHtml = getTextColorByConfigure(sHtml)
    --sHtml = getTableParseEmo(tHtml)

    sHtml = string.gsub(sHtml, "\n", "")


    local pRichText = RichTextEx.new({width = 170, lineoffset = 10, align = 0, maxlinecount = 2})
    pRichText:setPosition(cc.p(display.cx,display.cy))
    pRichText:setString(sHtml)
    pRichText:setAnchorPoint(0.5, 0.5)
    self:addChild(pRichText)

end




function TestScene:testArm2()
    --addTextureToCache("tx/fight/p2_fight_boss_s", 2)
	local pLayTLBossArm = MUI.MLayer.new()
	local pArm = MArmatureUtils:createMArmature(
        tFightSecArmDatas["2_5_1_1"], 
        pLayTLBossArm, 
        2, 
        cc.p(0,0),
        function ( _pArm )
        end, 1)
    if pArm then
    	pArm:play(-1)
    end
    pArm:setPosition(cc.p(display.cx,display.cy))
    self:addChild(pLayTLBossArm)
end


return TestScene
