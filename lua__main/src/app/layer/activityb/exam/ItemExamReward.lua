-----------------------------------------------------
-- author: wenzongyao
-- updatetime: 2018-01-12 14:11:20
-- Description: 每日答题奖励列表子项
-----------------------------------------------------

local ItemExamScore = require("app.layer.activityb.exam.ItemExamScore")
local ListItemExamReward = require("app.layer.activityb.exam.ListItemExamReward")

local MCommonView = require("app.common.MCommonView")
local ItemExamReward = class("ItemExamReward", function()
    return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end )

function ItemExamReward:ctor(_tSize)
    self:setContentSize(_tSize)
    -- 解析文件
    parseView("layout_exam_reward", handler(self, self.onParseViewCallback))
    --self:onParseViewCallback()
    --self:setBackgroundImage("#v1_bg_kelashen.png",{scale9 = true,capInsets=cc.rect(22,22, 1, 1)})
end

-- 解析界面回调
function ItemExamReward:onParseViewCallback(pView)
--    self:setContentSize(pView:getContentSize())
    self:addView(pView)
    centerInView(self, pView)

    self:init()
    self:setupViews()
    self:onResume()
    -- 注册析构方法
    self:setDestroyHandler("ItemExamReward", handler(self, self.onItemExamRewardDestroy))
end

-- 析构方法
function ItemExamReward:onItemExamRewardDestroy()
    self:onPause()
end

function ItemExamReward:regMsgs()
    regMsg(self, gud_refresh_rankinfo, handler(self, self.updateViews))	
    regMsg(self, gud_exam_info_refresh_msg, handler(self, self.updateViews))	
end

function ItemExamReward:unregMsgs()
    unregMsg(self, gud_refresh_rankinfo)
    unregMsg(self, gud_exam_info_refresh_msg)
end

function ItemExamReward:onResume()
    self:regMsgs()
    self:updateViews()
end

function ItemExamReward:onPause()
    self:unregMsgs()
end

function ItemExamReward:init()
end

function ItemExamReward:setupViews()
    self.pLayMain = self:findViewByName("lay_main")
    self.pLayBottom = self:findViewByName("lay_bottom")
end

function ItemExamReward:updateViews()    
    local tRewardList = Player:getExamData():getRewardList()

    --添加列表
	if not self.pListView then
        local pSize = self:getContentSize()
	    self.pListView = MUI.MListView.new{
	   	 	viewRect   = cc.rect(0, 0, pSize.width, pSize.height),
	   	 	direction  = MUI.MScrollView.DIRECTION_VERTICAL,
	   	 	itemMargin = {left = 0,
	             right =  0,
	             top =  0,
	             bottom =  0},
		}	
		self.pLayMain:addView(self.pListView)

		self.pListView:setItemCount(#tRewardList)
		self.pListView:setItemCallback(handler(self, self.setListItem))

	  	--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
        self.pListView:reload()
    else
    	self.pListView:notifyDataSetChange(true)
	end

    if not self.pScore then
        self.pScore = ItemExamScore.new(e_exam_score_type.reward)
        self.pLayBottom:addView(self.pScore)
    end
end

function ItemExamReward:setListItem(_index, _pView)
    local tRewardList = Player:getExamData():getRewardList()
    local tRewardData = tRewardList[_index]
    local pTempView = _pView
    if pTempView == nil then
        pTempView = ListItemExamReward.new()
    end

--    local s = ""
--    local tAry = string.split(tRewardData.stage, "-")
--    if tAry[1] == tAry[2] then
--        s = string.format(getConvertedStr(10, 10019), tAry[1])
--    else
--        s = string.format(getConvertedStr(10, 10019), tRewardData.stage)
--    end

    pTempView:setData(tRewardData.aw, tRewardData.stage)
    return pTempView
end


return ItemExamReward


