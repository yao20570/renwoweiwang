-----------------------------------------------------
-- author: wenzongyao
-- updatetime: 2018-1-11 19:37:12
-- Description: 每日抢答
-----------------------------------------------------
require("app.data.dbmrg.DBUtils")
local DataExam = require("app.layer.activityb.exam.DataExam")
local DlgBase = require("app.common.dialog.DlgBase")
local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")
local ActorVo = require("app.layer.playerinfo.ActorVo")

local e_type_tab = {
    main = 1,
    rank = 2,
    reward = 3,
    rule = 4,
}

local DlgExam = class("DlgExam", function()
    return DlgBase.new(e_dlg_index.dlgactivityexam)
end )

function DlgExam:ctor()
    parseView("dlg_act_exam", handler(self, self.onParseViewCallback))

end

-- 解析界面回调
function DlgExam:onParseViewCallback(pView)
    self:addContentView(pView)
    -- 加入内容层

    self:init()
    self:setupViews()
    self:onResume()

    -- 注册析构方法
    self:setDestroyHandler("DlgExam", handler(self, self.onDlgExamDestroy))
    SocketManager:sendMsg("getRankData", { e_rank_type.exam, 1, 20 })
    SocketManager:sendMsg("reqExamState", { e_exam_join_state.join })
end

-- 析构方法
function DlgExam:onDlgExamDestroy()
    self:onPause()

    SocketManager:sendMsg("reqExamState", { e_exam_join_state.exit })
end

function DlgExam:regMsgs()
    regMsg(self, gud_exam_info_refresh_msg, handler(self, self.updateViews))
    regMsg(self, gud_refresh_rankinfo, handler(self, self.updateZhuangYuanInfo))
end

function DlgExam:unregMsgs()
    unregMsg(self, gud_exam_info_refresh_msg)
    unregMsg(self, gud_refresh_rankinfo)
end

function DlgExam:onResume()
    self:regMsgs()
    self:updateViews()
end

function DlgExam:onPause()
    self:unregMsgs()
end

function DlgExam:init()
end

function DlgExam:setupViews()
    
	--设置标题
    self.tActData = Player:getActById(e_id_activity.exam)
	self:setTitle(self.tActData.sName)

    self.pLayTop = self:findViewByName("lay_top")

    self.pImgFont = self:findViewByName("img_font")
    self.pImgFont:setVisible(false)
    self.pImgTipBg = self:findViewByName("img_tip_bg")
    self.pImgTipBg:setVisible(false)
    self.pLayIcon = self:findViewByName("lay_icon")
    self.pLayIcon:setVisible(false)
    self.pTxtScore = self:findViewByName("lab_score")
    self.pTxtScore:setVisible(false)
    self.pTxtPlayerName = self:findViewByName("lab_player_name")
    self.pTxtPlayerName:setVisible(false)
    self.pTxtAnswerTip = self:findViewByName("lab_answer_tip")
    self.pTxtAnswerTip:setVisible(false)
    self.pTxtAnswerTip:setString(getTipsByIndex(20134))
    
    -- banner
    self.pLayBannerBg = self:findViewByName("lay_bannerbg")
    setMBannerImage(self.pLayBannerBg, TypeBannerUsed.fl_mrqd)

    -- 切换卡层
    self.tTitles = {
        getConvertedStr(10,10000),
        getConvertedStr(10,10001),
        getConvertedStr(10,10002),
        getConvertedStr(10,10003)
    }
    self.pLayContent = self:findViewByName("lay_content")
    self.pTabHost = FCommonTabHost.new(self.pLayContent, 1, 1, self.tTitles, handler(self, self.getLayerByKey), 1)
    self.pTabHost:removeLayTmp1()
    self.pTabHost:removeLayTmp2()
    self.pTabHost:setTabChangedHandler(handler(self, self.onChangeClickTab))
    self.pTabHost:setDefaultIndex(1)
    self.pTabHost:setLayoutSize(self.pLayContent:getLayoutSize())
    self.pLayContent:addView(self.pTabHost)

    local pTabItem =  self.pTabHost:getTabItems()
    local tExamData = Player:getExamData()
    if tExamData:isCanGetRankReward() then
        self.pTabHost:setDefaultIndex(3)
        showRedTips(pTabItem[3]:getRedNumLayer(), 0, 1, 2)
    else
        self.pTabHost:setDefaultIndex(1)
        showRedTips(pTabItem[3]:getRedNumLayer(), 0, 0, 2)
    end
end

-- 控件刷新
function DlgExam:updateViews()
    self:updateZhuangYuanInfo()

    self:showZhuangYuan()

    self:showAnswerTip()

    -- 标签红点
    local pTabItem =  self.pTabHost:getTabItems()
    local tExamData = Player:getExamData()
    if tExamData:isCanGetRankReward() then
        showRedTips(pTabItem[3]:getRedNumLayer(), 0, 1, 2)
    else
        showRedTips(pTabItem[3]:getRedNumLayer(), 0, 0, 2)
    end
end

function DlgExam:showAnswerTip()
    local tExamData = Player:getExamData()
    local bIsActivityInOpen = tExamData:isActivityInOpen()
    self.pTxtAnswerTip:setVisible(bIsActivityInOpen)
    self.pImgTipBg:setVisible(bIsActivityInOpen)
end

function DlgExam:showZhuangYuan()
    local tExamData = Player:getExamData()
    local bIsActivityInOpen = tExamData:isActivityInOpen()

    local tFirstData = self:getExamFristRankInfo()
    local bIsShow = tFirstData ~= nil and bIsActivityInOpen == false

    self.pLayIcon:setVisible(bIsShow)
    self.pTxtScore:setVisible(bIsShow)
    self.pTxtPlayerName:setVisible(bIsShow)
    self.pImgFont:setVisible(bIsShow)
end

-- 更新状元数据
function DlgExam:updateZhuangYuanInfo()
    
    self:showZhuangYuan()

    local tFirstData = self:getExamFristRankInfo()
    if tFirstData then
        -- 玩家头像
        local pActorVo = ActorVo.new()
        pActorVo:initData(tFirstData.p, tFirstData.box, nil)
        local pIcon = getIconGoodsByType(self.pLayIcon, TypeIconHero.NORMAL, type_icongoods_show.header, pActorVo, TypeIconHeroSize.M)
        pIcon:setIconIsCanTouched(false)
        

        -- 积分
        local sScore = {
            { text = getConvertedStr(10, 10016), color = _cc.pwhite },
            { text = tFirstData.dt, color = _cc.blue }
        }        
        self.pTxtScore:setString(sScore)

        -- 名称 
        self.pTxtPlayerName:setString(tFirstData.n)
    end
end



function DlgExam:getExamFristRankInfo()
--    local tExamData = Player:getExamData()
--    if tExamData:isActivityInOpen() then
--        return
--    end

--    local rankInfo = Player:getExamRankInfo()
--    if rankInfo.nRankType ~= e_rank_type.exam then
--        return
--    end

--    local tListData = rankInfo:getRankDataList()
--    return tListData[1]
    return Player:getExamFristRankInfo()
end

-- 下标选择回调事件
function DlgExam:getLayerByKey(_sKey, _tKeyTabLt)
    local tSize = self.pTabHost:getCurContentSize()
    local pLayer = nil
    if (_sKey == _tKeyTabLt[1]) then
        local ItemExamQuestion = require("app.layer.activityb.exam.ItemExamQuestion")
        pLayer = ItemExamQuestion.new(tSize)
        self.pItemExamQuestion = pLayer
    elseif (_sKey == _tKeyTabLt[2]) then
        local ItemExamRank = require("app.layer.activityb.exam.ItemExamRank")
        pLayer = ItemExamRank.new(tSize)
        self.pItemExamRank = pLayer
    elseif (_sKey == _tKeyTabLt[3]) then
        local ItemExamReward = require("app.layer.activityb.exam.ItemExamReward")
        pLayer = ItemExamReward.new(tSize)
        self.pItemExamReward = pLayer
    elseif (_sKey == _tKeyTabLt[4]) then
        local ItemExamRule = require("app.layer.activityb.exam.ItemExamRule")
        pLayer = ItemExamRule.new(tSize)
        self.pItemExamRule = pLayer
    end
    return pLayer
end

function DlgExam:onChangeClickTab(_key, _nType)
    if _key == "tabhost_key_1" then
    elseif _key == "tabhost_key_2" then        
        SocketManager:sendMsg("getRankData", { e_rank_type.exam, 1, 20 })
    elseif _key == "tabhost_key_3" then
        SocketManager:sendMsg("getRankData", { e_rank_type.exam, 1, 20 })
    elseif _key == "tabhost_key_4" then

    end
end


return DlgExam