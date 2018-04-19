-----------------------------------------------------
-- author: wenzongyao
-- updatetime: 2018-01-12 14:11:20
-- Description: 每日答题奖励规则子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemExamRule = class("ItemExamRule", function()
    return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end )

function ItemExamRule:ctor(_tSize)
    self:setContentSize(_tSize)
    -- 解析文件
    parseView("layout_exam_rule", handler(self, self.onParseViewCallback))
    --self:onParseViewCallback()

end

-- 解析界面回调
function ItemExamRule:onParseViewCallback(pView)
--    self:setContentSize(pView:getContentSize())
    self:addView(pView)
    centerInView(self, pView)

    self:setupViews()
    self:onResume()

    -- 注册析构方法
    self:setDestroyHandler("ItemExamRule", handler(self, self.onItemExamRuleDestroy))
end

-- 析构方法
function ItemExamRule:onItemExamRuleDestroy()
    self:onPause()
end

function ItemExamRule:regMsgs()
    --regMsg(self, gud_exam_info_refresh_msg, handler(self, self.updateViews))  
    --regMsg(self, gud_exam_activity_state_msg, handler(self, self.updateViews))
end

function ItemExamRule:unregMsgs()
    --unregMsg(self, gud_exam_info_refresh_msg)
    --unregMsg(self, gud_exam_activity_state_msg)
end

function ItemExamRule:onResume()
    self:regMsgs()
    self:updateViews()
end

function ItemExamRule:onPause()
    self:unregMsgs()
end

function ItemExamRule:setupViews()



    self.pLayMain = self:findViewByName("lay_main")


    local nSpaceY = 30
    local nSpaceX = 20
    local h = self.pLayMain:getHeight()
    
    -- 添加一个h:30的间隔，因为lay_main是个fill_layout
    self.pLaySpace =  MUI.MLayer.new()
    self.pLaySpace:setContentSize(640, 30)
    self.pLaySpace:setPosition(0, h)
    self.pLayMain:addView(self.pLaySpace, 11)

    -- 规则说明
    self.pTxtRule = MUI.MLabel.new({
	    text = "",
	    size = 22,
	    anchorpoint = cc.p(0, 0),
	    align = cc.ui.TEXT_ALIGN_LEFT,
	    valign = cc.ui.TEXT_VALIGN_TOP,
	    -- color = cc.c3b(255, 255, 255),
	    dimensions = cc.size(610, 0),
	})
	--self.pTxtRule:setString(getTextColorByConfigure(getTipsByIndex(20113)))
    self.pTxtRule:setString(getTipsByIndex(20113))
    h = h - self.pTxtRule:getHeight() - nSpaceY
	self.pTxtRule:setPosition(nSpaceX, h)
	self.pLayMain:addView(self.pTxtRule, 11)
end

function ItemExamRule:updateViews()

end

return ItemExamRule


