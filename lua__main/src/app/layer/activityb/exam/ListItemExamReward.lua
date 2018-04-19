-- endregion
-----------------------------------------------------
-- author: zhangnianfeng
-- updatetime: 2018-1-22 22:21:20
-- Description: 每日抢答排行奖励列表子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local IconGoods = require("app.common.iconview.IconGoods")
local ItemFarmPlanAward = require("app.layer.activityb.farmtroopsplan.ItemFarmPlanAward")
local ListItemExamReward = class("ListItemExamReward", function()
    return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end )

function ListItemExamReward:ctor()
    -- 解析文件
    parseView("item_reward_list_item", handler(self, self.onParseViewCallback))
end

-- 解析界面回调
function ListItemExamReward:onParseViewCallback(pView)
    self:setContentSize(pView:getContentSize())
    self:addView(pView)
    centerInView(self, pView)

    self:setupViews()

    -- 注册析构方法
    self:setDestroyHandler("ListItemExamReward", handler(self, self.onItemActGetRewardDestroy))
end

-- 析构方法
function ListItemExamReward:onItemActGetRewardDestroy()
end

function ListItemExamReward:setupViews()
    self.pLayGoods = self:findViewByName("lay_icons")
    self.pTxtBanner = self:findViewByName("txt_banner")
    self.pLayGetReward = self:findViewByName("lay_get_reward")

    -- 领取按钮(奖励使用)
    self.pBtnGet = getCommonButtonOfContainer(self.pLayGetReward, TypeCommonBtn.L_YELLOW, getConvertedStr(10, 10007))
	self.pBtnGet:onCommonBtnClicked(handler(self, self.onBtnGet)) 
    self.pBtnGet:updateBtnText(getConvertedStr(10, 10007))  
    setMCommonBtnScale(self.pLayGetReward, self.pBtnGet, 0.8)


    self.pImgGetFlag = self:findViewByName("img_get_flag")
end


-------------------------------------------------

-- 设置数据
-- tDropList:List<Pair<Integer,Long>>
-- sStr:排名描述
function ListItemExamReward:setData(tDropList, sStr)
    if not tDropList then
        return
    end
        
    -- 我的排名
    local nMyRank = Player:getExamRankInfo().nMyRank

    -- 能否领取奖励
    local tExamData = Player:getExamData()
    
    -- 排名范围
    local s = ""
    local tAry = string.split(sStr, "-")
    if tAry[1] == tAry[2] then
        s = string.format(getConvertedStr(10, 10019), tAry[1])
    else
        s = string.format(getConvertedStr(10, 10019), sStr)
    end

    -- 标题
    self.pTxtBanner:setString(s)

    -- 排名范围
    local isShow = false    
    if tonumber(tAry[1]) <= nMyRank and nMyRank <= tonumber(tAry[2]) then
        isShow = true
    end
    
    self.pBtnGet:setVisible(isShow 
        and tExamData:isActivityInOpen() == false 
        and tExamData.nRankRewardState == e_exam_reward_state.not_get)

    self.pImgGetFlag:setVisible(isShow 
        and tExamData:isActivityInOpen() == false 
        and tExamData.nRankRewardState == e_exam_reward_state.has_got)


    -- 奖励Icon
    self.tDropList = tDropList
    local nCurrCount = #self.tDropList
    -- 容错
    if not self.pListView then
        local pLayGoods = self.pLayGoods
        local tSize = pLayGoods:getContentSize()
        self.pListView = MUI.MListView.new {
            viewRect = cc.rect(0,0,tSize.width,tSize.height),
            direction = MUI.MScrollView.DIRECTION_HORIZONTAL,
            itemMargin =
            {
                left = 10,
                right = 0,
                top = 0,
                bottom = 0
            },
        }
        pLayGoods:addView(self.pListView)
        centerInView(pLayGoods, self.pListView)
        self.pListView:setPositionY(self.pListView:getPositionY())
        self.pListView:setItemCallback(handler(self, self.onGoodsListViewCallBack))
        self.pListView:setItemCount(nCurrCount)
        self.pListView:reload(true)
    else
        self.pListView:notifyDataSetChange(true, nCurrCount)
        local oldY = self.pListView.container:getPositionY()
        self.pListView:scrollTo(0, oldY, false)
    end

end

-- 列表项回调
function ListItemExamReward:onGoodsListViewCallBack(_index, _pView)
    -- body
    local tTempData = self.tDropList[_index]
    local pTempView = _pView

    if pTempView == nil then
        pTempView = ItemFarmPlanAward.new()
        pIconView = IconGoods.new(TypeIconGoods.NORAML)
        pIconView:setIconIsCanTouched(true)
        pTempView:addView(pIconView, 2)
        pIconView:setTag(999)
    end

    local pIconView = pTempView:getChildByTag(999)
    if pIconView then
        local nGoodsId = tTempData.k
        local nCt = tTempData.v
        local pGoods = getGoodsByTidFromDB(nGoodsId)
        pIconView:setCurData(pGoods)
        pIconView:setMoreTextColor(getColorByQuality(pGoods.nQuality))
        pIconView:setNumber(nCt)
        pIconView:setScale(0.8)
    end


    return pTempView
end

function ListItemExamReward:onBtnGet()
    SocketManager:sendMsg("reqExamReward", {})
end

return ListItemExamReward


