-----------------------------------------------------
-- author: wenzongyao
-- updatetime: 2018-01-12 14:11:20
-- Description: 每日答题积分子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemExamScore = class("ItemExamScore", function()
    return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end )

e_exam_score_type = {
    rank = 1,       --排行榜
    reward = 2,     --奖励
}

-- type:控件类型e_exam_score_type
function ItemExamScore:ctor(_nType)
    assert(_nType ~= nil)
    self.nType = _nType
    -- 解析文件
    parseView("layout_exam_score", handler(self, self.onParseViewCallback))
end

-- 解析界面回调
function ItemExamScore:onParseViewCallback(pView)
    self:setContentSize(pView:getContentSize())
    self:addView(pView)
    centerInView(self, pView)

    self:setupViews()
    self:onResume()

    -- 注册析构方法
    self:setDestroyHandler("ItemExamScore", handler(self, self.onItemExamScoreDestroy))
end

-- 析构方法
function ItemExamScore:onItemExamScoreDestroy()
    self:onPause()
end

function ItemExamScore:regMsgs()
    regMsg(self, gud_refresh_rankinfo, handler(self, self.updateRankInfo))	
    regMsg(self, gud_exam_info_refresh_msg, handler(self, self.updateViews))  	
end

function ItemExamScore:unregMsgs()
    unregMsg(self, gud_refresh_rankinfo)
    unregMsg(self, gud_exam_info_refresh_msg)
end

function ItemExamScore:onResume()
    self:regMsgs()
    self:updateViews()
end

function ItemExamScore:onPause()
    self:unregMsgs()
end

function ItemExamScore:setupViews()
    -- 我的积分
    self.pTxtScore = self:findViewByName("lab_score")
    -- 我的排名
    self.pTxtMyRank = self:findViewByName("lab_my_rank")
    -- 提示
    self.pTxtTip = self:findViewByName("lab_tip")
    self.pTxtTip:setString(getTextColorByConfigure(getTipsByIndex(20114)))
    setTextCCColor(self.pTxtTip, _cc.lgray)

    -- 分享按钮(排行榜使用)
    local pLayShare = self:findViewByName("lay_share")
    self.pBtnShare = getCommonButtonOfContainer(pLayShare, TypeCommonBtn.L_BLUE, getConvertedStr(10, 10006))
	self.pBtnShare:onCommonBtnClicked(handler(self, self.onBtnShare))
    setMCommonBtnScale(pLayShare, self.pBtnShare, 0.8)

end

function ItemExamScore:updateViews()  
    self:updateScore()
    self:updateRankInfo()
end

function ItemExamScore:updateScore()
    local tExamData = Player:getExamData()
    if tExamData == nil then
        return
    end

    local sTempStr = nil 
    local nScore = 0
    if tExamData:isActivityInOpen() then
        -- 当前积分
        sTempStr = getConvertedStr(10, 10014)
        nScore = tExamData:getScore()
    else
        -- 上期积分
        sTempStr = getConvertedStr(10, 10021)
        local myRankInfo = Player:getExamRankInfo().tMyInfo
        if myRankInfo then
            nScore = myRankInfo.dt
        end
    end
    
    local sScore = {
		{text = sTempStr, color = _cc.pwhite},
		{text = nScore, color = _cc.blue}
	}
	self.pTxtScore:setString(sScore)
end

function ItemExamScore:updateRankInfo()
--    if Player:getRankInfo().nRankType ~= e_rank_type.exam then
--        return
--    end
        
    self:updateScore()

    local str = ""
    if Player:getExamRankInfo().nMyRank == 0 then
		str = getConvertedStr(6, 10426)
	else
		str = Player:getExamRankInfo().nMyRank
	end	
    local nRank = {
		{text = getConvertedStr(10, 10015), color = _cc.pwhite},
		{text = str, color = _cc.blue}
	}
	self.pTxtMyRank:setString(nRank)
end

function ItemExamScore:onBtnShare()    
    local tExamData = Player:getExamData()
    if tExamData == nil then
        myprint("ItemExamScore:onBtnShare() ==> ExamData is nil")
        return
    end

    local nMaxCount = tExamData.nMaxCount
    local nCorrectCount = tExamData:getCorrectCount()
    local nWrongCount = tExamData:getWrongCount()
    local nNotAnswerCount = nMaxCount - nCorrectCount - nWrongCount

    openShare(self.pBtnShare, e_share_id.exam , { nCorrectCount, nWrongCount, nNotAnswerCount })
end

function ItemExamScore:onBtnGet()
    myprint("==> ItemExamScore:onBtnGet()")
    SocketManager:sendMsg("reqExamReward", {})
end


return ItemExamScore


