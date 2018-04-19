-----------------------------------------------------
-- author: wenzongyao
-- updatetime: 2018-01-12 14:11:20
-- Description: 每日答题问题子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local RichText = require("app.common.richview.RichText")
local ItemExamAnswer = class("ItemExamAnswer", function()
    return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end )

local const_answer_key = {"A.","B.","C."}

function ItemExamAnswer:ctor(_answerId)    
    self.nAnswerId = _answerId
    self:setIgnoreOtherHeight(true)
    -- 解析文件
    parseView("layout_exam_answer", handler(self, self.onParseViewCallback))
end

-- 解析界面回调
function ItemExamAnswer:onParseViewCallback(pView)
    self:setContentSize(pView:getContentSize())
    self:addView(pView)
    centerInView(self, pView)

    self:init()
    self:setupViews()
    self:onResume()
    -- 注册析构方法
    self:setDestroyHandler("ItemExamAnswer", handler(self, self.onItemExamAnswerDestroy))
end

-- 析构方法
function ItemExamAnswer:onItemExamAnswerDestroy()
    self:onPause()
end

function ItemExamAnswer:regMsgs()
    regMsg(self, gud_exam_info_refresh_msg, handler(self, self.updateViews))  
    regMsg(self, gud_exam_ansewer_players_msg, handler(self, self.updateViews))  
    
end

function ItemExamAnswer:unregMsgs()
    unregMsg(self, gud_exam_info_refresh_msg)
    unregMsg(self, gud_exam_ansewer_players_msg)  
    
end

function ItemExamAnswer:onResume()
    self:regMsgs()
    self:updateViews()
end

function ItemExamAnswer:onPause()
    self:unregMsgs()
end

function ItemExamAnswer:init()

end

function ItemExamAnswer:getAnswer()
    local tExamData = Player:getExamData()    
    local tQuestionData = getQuestionConfig(tExamData.nQuestionId)
    if self.nAnswerId == 1 then
        return tQuestionData.answera  
    elseif self.nAnswerId == 2 then
        return tQuestionData.answerb  
    end
    return tQuestionData.answerc    
end

function ItemExamAnswer:setupViews()


    -- 主体
    self.pLayMain            = self:findViewByName("lay_main")
    self.pLayMain:setViewTouched(false)
    self.pLayMain:setIsPressedNeedScale(false)
    self.pLayMain:setIsPressedNeedColor(false)
    self.pLayMain:onMViewClicked(handler(self, self.onSelectAnswer))

    -- 答案
    self.pTxtAnswer            = self:findViewByName("lab_answer")
--    local pLayAnswer            = self:findViewByName("lay_answer")
--    local tSize = pLayAnswer:getContentSize()
--    pRichArea = RichText.new()    
--    pRichArea:ignoreContentAdaptWithSize( false )
--    pRichArea:setContentSize( tSize.width - 30, tSize.height - 20 )    
--    --pRichArea:setVerticalSpace( 20 )
--    pRichArea:setPosition(tSize.width/2, tSize.height/2)
--    pLayAnswer:addView( pRichArea, 1 )
--    self.pRichArea = pRichArea

    -- 答案
    self.pLaySelect             = self:findViewByName("lay_select")

    -- 开放提示
    self.pTxtTip                = self:findViewByName("lab_tip")    
    self.pTxtTip:setIgnoreOtherHeight(true)
    self.pTxtTip:setString(getConvertedStr(10,10004))
    setTextCCColor(self.pTxtTip, _cc.white)
    centerInView(self.pTxtTip:getParent(), self.pTxtTip)
    
    -- 选题提示
    self.pTxtSelectTip          = self:findViewByName("lab_select_tip")    
    self.pTxtSelectTip:setString(getConvertedStr(10,10005))
    setTextCCColor(self.pTxtSelectTip, _cc.gray)
   
    -- 对错标记
    self.pImgResult             = self:findViewByName("img_result")   

end

function ItemExamAnswer:updateViews()
    local tExamData = Player:getExamData()
    local bIsActivityInOpen = tExamData:isActivityInOpen()
    local nExamState = tExamData:getExamState()
    
    -- 点击选题
    self.pLayMain:setViewTouched(nExamState == e_exam_state.question)

    -- 每日抢答数据
    if bIsActivityInOpen == true then
        local tAnswerStrTable = {
            { text = const_answer_key[self.nAnswerId], size = 20 },
            { text = self:getAnswer(), size = 18 }
        }
        self.pTxtAnswer:setString(tAnswerStrTable)
        self.pTxtAnswer:setVisible(true)
        -- self.pRichArea:setString(tAnswerStrTable)
        -- self.pRichArea:setVisible(true)
    else
        self.pTxtAnswer:setVisible(false)
        -- self.pRichArea:setVisible(false)
    end

    -- 尚未开放提示
    self.pTxtTip:setVisible(bIsActivityInOpen == false)

    -- 选题提示
    self.pTxtSelectTip:setVisible(bIsActivityInOpen == true 
                                    and tExamData:isHasAnswer() == false 
                                    and nExamState == e_exam_state.question)

    -- 显示答题玩家列表
    self:onShowAnswerPlayers()

    -- 对错
    if nExamState == e_exam_state.result then
        if tExamData:isAnswerCorrect(self.nAnswerId) then
            self.pImgResult:setCurrentImage("#v1_img_goua.png")
        else
            self.pImgResult:setCurrentImage("#v1_img_xx.png")
        end
        self.pImgResult:setVisible(true)
    else
        self.pImgResult:setVisible(false)
    end

    -- 隐藏选择框    
    if self.pImgSelectFrame == nil then         
        self.pImgSelectFrame = MUI.MImage.new("#v1_img_truqrjfi.png", { scale9 = true, capInsets = cc.rect(67, 67, 1, 1) })        
        self.pLaySelect:addView(self.pImgSelectFrame)
    end
    local tSize = self.pLaySelect:getContentSize()
    local posX, posY = self.pLaySelect:getPosition()
    self.pImgSelectFrame:setContentSize(tSize.width + 24, tSize.height + 24)
    self.pImgSelectFrame:setIgnoreOtherHeight(true)
    self.pImgSelectFrame:setPosition(tSize.width / 2, tSize.height / 2)  

    self.pImgSelectFrame:setVisible(bIsActivityInOpen == true 
                                    and tExamData:isHasAnswer() 
                                    and tExamData:getPlayerAnswerId() == self.nAnswerId)
    

end

function ItemExamAnswer:onShowAnswerPlayers()
    local tExamData = Player:getExamData()
    local nExamState = tExamData:getExamState()
    local pAnswerPlayers = tExamData:getAnswerPlayers(self.nAnswerId)
    local nDataCount = #pAnswerPlayers

    --myprint("ItemExamAnswer:onShowAnswerPlayers()====>", self.nAnswerId, nDataCount)
    if ((nExamState == e_exam_state.question and tExamData:isHasAnswer() == true) or nExamState == e_exam_state.result) then
	    if not self.pListView then
        -- 玩家列表容器
            local pLayList = self:findViewByName("lay_list")    
            local tSize =pLayList:getContentSize()
	        self.pListView = MUI.MListView.new {
	            viewRect   = cc.rect(0, 0, tSize.width, tSize.height),
	            direction  = MUI.MScrollView.DIRECTION_VERTICAL,
	            itemMargin = {left = 0,
	                right =  0,
	                top = 0,
	                bottom = 0},
	        }
	        pLayList:addView(self.pListView)
	        centerInView(pLayList, self.pListView)
	    	self.pListView:setItemCallback(handler(self, self.onListViewCallBack))
	    	self.pListView:setItemCount(nDataCount)
	    	self.pListView:reload(false)
	    else            
	    	self.pListView:notifyDataSetChange(false, nDataCount)
	    end
        self.pListView:setVisible(true)
    else
        if self.pListView then            
            self.pListView:setVisible(false)
        end
    end
end

function ItemExamAnswer:onListViewCallBack(_index, _pView)
    local pAnswerPlayers = Player:getExamData():getAnswerPlayers(self.nAnswerId)
    local sPlayerName = pAnswerPlayers[_index]
    local pTempView = _pView

    if pTempView == nil then
        local size = cc.size(170, 40)
        pTempView = MUI.MLayer.new()
        pTempView:setContentSize(size)
        pTempView:setTag(999)

        local pTxtPlayerName = MUI.MLabel.new( {
            text = "",
            size = 20,
            anchorpoint = cc.p(0.5,0.5),
            dimensions = cc.size(size.width,size.height),
        } )
        pTxtPlayerName:setPosition(size.width / 2, size.height / 2)

        pTempView:addView(pTxtPlayerName, 2, 999)
    end

    local pTxtPlayerName = pTempView:getChildByTag(999)
    pTxtPlayerName:setString(sPlayerName)
    if Player:getPlayerInfo().sName == sPlayerName then
        setTextCCColor(pTxtPlayerName, _cc.blue)
    else
        setTextCCColor(pTxtPlayerName, _cc.pwhite)
    end
    return pTempView
end

function ItemExamAnswer:onSelectAnswer()    
    local tExamData = Player:getExamData()
    if tExamData:isHasAnswer() then    
        myprint("已选择答案")        
    else
        tExamData:setHasAnswer(true)
        tExamData:setPlayerAnswerId(self.nAnswerId)
        SocketManager:sendMsg("reqAnswerQuestion", { self.nAnswerId })
    end         
end

return ItemExamAnswer


