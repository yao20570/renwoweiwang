-----------------------------------------------------
-- author: wenzongyao
-- updatetime: 2018-01-12 14:11:20
-- Description: 每日答题问题子项
-----------------------------------------------------

local ItemExamAnswer = require("app.layer.activityb.exam.ItemExamAnswer")
local MCommonView = require("app.common.MCommonView")
local ItemExamQuestion = class("ItemExamQuestion", function()
    return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end )

function ItemExamQuestion:ctor(_tSize)
    self:setContentSize(_tSize)
    -- 解析文件
    parseView("layout_exam_question", handler(self, self.onParseViewCallback))
end

-- 解析界面回调
function ItemExamQuestion:onParseViewCallback(pView)
    self:addView(pView)
    centerInView(self, pView)

    self:init()
    self:setupViews()
    self:onResume()

    -- 注册析构方法
    self:setDestroyHandler("ItemExamQuestion", handler(self, self.onItemExamQuestionDestroy))
end

-- 析构方法
function ItemExamQuestion:onItemExamQuestionDestroy()
    self.tAnswerNodes = nil
    self:onPause()
end

function ItemExamQuestion:regMsgs()
	regUpdateControl(self, handler(self, self.updateCd))
    regMsg(self, gud_exam_info_refresh_msg, handler(self, self.updateViews))  
    regMsg(self, gud_refresh_rankinfo, handler(self, self.updateViews))  
    
end

function ItemExamQuestion:unregMsgs()
	unregUpdateControl(self)
    unregMsg(self, gud_exam_info_refresh_msg)
    unregMsg(self, gud_refresh_rankinfo)  
    
end

function ItemExamQuestion:onResume()
    self:regMsgs()
    self:updateViews()
end

function ItemExamQuestion:onPause()
    self:unregMsgs()
end

function ItemExamQuestion:init()
    self.tAnswerNodes = {}
    self.nextReqTimeStamp = 0
end

function ItemExamQuestion:updateCd()
    self:setAnswerTimeLeft()

    self:setStartTimeOrQuestionIndex()

    local tExamData = Player:getExamData()
    if tExamData:isHasAnswer() and tExamData:getExamState() == e_exam_state.question then
        if self.nextReqTimeStamp == 0 then
            local cd = tExamData.nRefreshTime
            self.nextReqTimeStamp = getSystemTime(true) + cd
            SocketManager:sendMsg("reqAnswerPlayers")
        else
            if getSystemTime(true) >= self.nextReqTimeStamp then
                self.nextReqTimeStamp = 0
            end
        end
    else
        self.nextReqTimeStamp = 0
    end
end

function ItemExamQuestion:setupViews()
    -- 第几题
    self.pTxtIndex          = self:findViewByName("lab_index")
    -- 剩余时间
    self.pTxtRemianingTime  = self:findViewByName("lab_remaining_time")
    -- 积分
    self.pTxtScore          = self:findViewByName("lab_score")
    -- 题目
    self.pTxtQuestion       = self:findViewByName("lab_question")
    -- 分享
    self.pLayShare          = self:findViewByName("lay_share")
    self.pLayShare:setViewTouched(true)
    self.pLayShare:setIsPressedNeedScale(true)
    self.pLayShare:setIsPressedNeedColor(true)
    self.pLayShare:onMViewClicked(handler(self, self.onBtnShare))    
    self.pTxtShare          = self:findViewByName("lab_share")
    self.pTxtShare:setString(getConvertedStr(10, 10042))
    -- 上期抢答信息
    self.pLayPreExamInfo    = self:findViewByName("lab_pre_exam_info")
    -- 答题状态提示
    self.pLayExamStateTip   = self:findViewByName("lab_exam_state_tip")

    -- 结果面板
    self.pLayContent        = self:findViewByName("lay_content")
    local space             = 32        -- ItemExamAnswer的间隔
    local x = 0                         -- 
    for i = 1, 3 do
        x = x + space
        local pItemExamAnswer = ItemExamAnswer.new(i)
        print(x)
        pItemExamAnswer:setPositionX(x)
        self.pLayContent:addView(pItemExamAnswer)
        self.tAnswerNodes[i] = pItemExamAnswer
        x = x + pItemExamAnswer:getWidth()
    end
    

end

function ItemExamQuestion:updateViews()
    -- 每日抢答数据
    local tExamData = Player:getExamData()
    local bIsActivityInOpen = tExamData:isActivityInOpen()
       
    -- 设置活动开始时间或第几题 
    self:setStartTimeOrQuestionIndex()

    -- 剩余的答题时间
    self:setAnswerTimeLeft() 

    -- 获得积分    
    local sTempStr = nil 
    local nScore = 0
    if bIsActivityInOpen then
        sTempStr = getConvertedStr(10, 10011)
        nScore = tExamData:getScore()
    else
        sTempStr = getConvertedStr(10, 10021)
        local myRankInfo = Player:getExamRankInfo().tMyInfo
        if myRankInfo then
            nScore = myRankInfo.dt
        end
    end 
    local s = {
		{text = sTempStr, color = _cc.white},
		{text = nScore, color = _cc.blue}
	}
	self.pTxtScore:setString(s)
    self.pTxtScore:setVisible(bIsActivityInOpen)    

    -- 上期答题信息
    if bIsActivityInOpen then
        self.pLayPreExamInfo:setVisible(false)
    else
        local s = {
	    	{text = getConvertedStr(10, 10031), color = _cc.white},
	    	{text = tExamData.nCorrectCount, color = _cc.green},
	    	{text = getConvertedStr(10, 10032), color = _cc.white},
	    	{text = tExamData.nWrongCount, color = _cc.green},
	    	{text = getConvertedStr(10, 10033), color = _cc.white},
	    	{text = tExamData.nMaxCount - tExamData.nCorrectCount - tExamData.nWrongCount, color = _cc.green},
	    	{text = getConvertedStr(10, 10034), color = _cc.white}
	    }
        self.pLayPreExamInfo:setString(s)
        self.pLayPreExamInfo:setVisible(true)
    end
    
    -- 未开始tip
    if bIsActivityInOpen then
        self.pLayExamStateTip:setVisible(false)
    else
        if tExamData:getExamState() == e_exam_state.ready then
            self.pLayExamStateTip:setString(getTipsByIndex(20099))
        else
            self.pLayExamStateTip:setString(getTipsByIndex(20098))
        end
        setTextCCColor(self.pLayExamStateTip, _cc.pwhite)
        self.pLayExamStateTip:setVisible(true)
    end

    -- 题目    
    if bIsActivityInOpen then
        local nCurQuestionId = tExamData.nQuestionId
        local tQuestionData = getQuestionConfig(nCurQuestionId)
        self.pTxtQuestion:setString(tQuestionData.question)        
        setTextCCColor(self.pTxtQuestion, _cc.blue)
        self.pTxtQuestion:setVisible(true)
    else        
        self.pTxtQuestion:setVisible(false)
    end

    -- 活动开启的状态则隐藏分享按钮
    self.pLayShare:setVisible(not bIsActivityInOpen)
end

-- 设置抢答剩余时间
function ItemExamQuestion:setAnswerTimeLeft()
    local tExamData = Player:getExamData()
    local nExamState = tExamData:getExamState()
    if tExamData:isActivityInOpen() then
        -- 答题阶段显示倒计时
        local nCurLocalTimeStamp = getSystemTime(true)
        local nTimeLeft = 0
        local sTimeLeft = ""
        if nExamState == e_exam_state.question then
            local nEndLocalTimeStamp = tExamData:getAnswerEndLocalTimeStamp()            
            local nMaxAnswerTime = tExamData.nAnTime
            nTimeLeft = math.min(math.max(nEndLocalTimeStamp - nCurLocalTimeStamp, 0), nMaxAnswerTime)
            if nTimeLeft == 0 then
                if nExamState == e_exam_state.question then
                    -- 玩家在答题结束前没选答案，服务端不会推[-8552每次答题结算推送]
                    -- 所以得自己设置状态和请求玩家答题列表
                    tExamData:setExamState(e_exam_state.result)
                    SocketManager:sendMsg("reqAnswerPlayers")
                    SocketManager:sendMsg("getRankData", { e_rank_type.exam, 1, 20 })
                end
            end
            sTimeLeft = string.format(getConvertedStr(10, 10010), nTimeLeft)
        elseif nExamState == e_exam_state.result then
            local nEndLocalTimeStamp = tExamData:getResultEndLocalTimeStamp()
            local nMaxCDTime = tExamData.nCDTime
            nTimeLeft = math.min(math.max(nEndLocalTimeStamp - nCurLocalTimeStamp, 0), nMaxCDTime)
            sTimeLeft = string.format(getConvertedStr(10, 10018), nTimeLeft)
        end                
        self.pTxtRemianingTime:setString(sTimeLeft)
        
    else
        -- 非答题阶段显示上期积分
        local sTempStr = getConvertedStr(10, 10021)
        local nScore = 0
        local myRankInfo = Player:getExamRankInfo().tMyInfo
        if myRankInfo then
            nScore = myRankInfo.dt
        end
        local s = {
	    	{text = sTempStr, color = _cc.white},
	    	{text = nScore, color = _cc.blue}
	    }
	    self.pTxtRemianingTime:setString(s) 
    end
end

-- 设置活动开始时间或第几题
function ItemExamQuestion:setStartTimeOrQuestionIndex()
    local tExamData = Player:getExamData()
    local bIsActivityInOpen = tExamData:isActivityInOpen()        
    if bIsActivityInOpen then
        -- 第几题
        local s = {
	    	{text = getConvertedStr(10, 10008), color = _cc.white},
	    	{text = tExamData.nQuestionIndex, color = _cc.blue},
	    	{text = getConvertedStr(10, 10009), color = _cc.white}
	    }
	    self.pTxtIndex:setString(s)
    else
        -- 活动开启本地时间戳
        local nOpenLocalTimeStamp = tExamData:getActivityOpenLocalTimeStamp() 
        -- 当前本地时间戳
        local nCurrLocalTimeStamp = getSystemTime(true)
        -- 距离开启的时间
        --myprint("===============>ItemExamQuestion:setStartTimeOrQuestionIndex()",nOpenLocalTimeStamp , nCurrLocalTimeStamp, nOpenLocalTimeStamp - nCurrLocalTimeStamp)
        local nOpenTimeLeft = nOpenLocalTimeStamp - nCurrLocalTimeStamp
        if 0 < nOpenTimeLeft and nOpenTimeLeft < 60 * 10 then             
            local s = string.format(getConvertedStr(10, 10020), formatTimeToHms(nOpenTimeLeft, true, true))
	        self.pTxtIndex:setString(s)
        else            
            local s = string.format(getConvertedStr(10, 10012), tExamData.sActivityOpenTime)
	        self.pTxtIndex:setString(s)
        end
    end    
end

function ItemExamQuestion:onBtnShare()    
    local tExamData = Player:getExamData()
    if tExamData == nil then
        myprint("ItemExamScore:onBtnShare() ==> ExamData is nil")
        return
    end

    local nMaxCount = tExamData.nMaxCount
    local nCorrectCount = tExamData:getCorrectCount()
    local nWrongCount = tExamData:getWrongCount()
    local nNotAnswerCount = nMaxCount - nCorrectCount - nWrongCount

    openShare(self.pLayShare, e_share_id.exam , { nCorrectCount, nWrongCount, nNotAnswerCount })
end

return ItemExamQuestion


