--
-- Author: tanqian
-- Date: 2017-07-25 14:52:24
--滚屏内容层
local MCommonView = require("app.common.MCommonView")
local RichTextEx = require("app.common.richview.RichTextEx")

local SystemNotice = class("SystemNotice", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function SystemNotice:ctor()
	self:myInit()

	parseView("layout_notice", handler(self, self.onParseViewCallback))

end
function SystemNotice:myInit()
	
	self.moveSpeed = 0.01--文本每个像素移动时间
	self.isShowNotice = false--当前是否在显示公告
	self.nUpHandler = nil--定时器

	self.dataOneSeq = {} --只滚动一次的公告队列
	self.curOneRunIndex = 0 --当前显示的公告index

	self.dataMultiSeq = {} --滚动多次的公告队列
	
end
--解析布局回调事件
function SystemNotice:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("SystemNotice",handler(self, self.onSystemNoticeDestroy))
end
--初始化控件
function SystemNotice:setupViews()
	self:setVisible(false)

	self.pLayBg = self:findViewByName("lay_content")

	--内容层
	self.pLayContent = self:findViewByName("lay_scroll")

	--装公告文本的层
	self.pLayMove = self:findViewByName("lay_move")
	--层点击
	self.pLayMove:setViewTouched(true)
	self.pLayMove:setIsPressedNeedScale(false)
	self.pLayMove:setIsPressedNeedColor(false)
	self.pLayMove:onMViewClicked(handler(self, self.onClickNotice))

	--公告文本层
	local pOldTxtNotice = self:findViewByName("txt_show")
    self.pTxtNotice = RichTextEx.new({width = 10000, autow = true})
	self.pTxtNotice:setAnchorPoint(0, 0.5)
    self.pTxtNotice:setPosition(pOldTxtNotice:getPosition())
    pOldTxtNotice:getParent():addView(self.pTxtNotice)
end

function SystemNotice:updateViews()
	self:noticeRunAction(self.pData)
end
--设置文本右边以外（看不见的地方）
function SystemNotice:setTextToRight()
	self.pLayMove:setPositionX(self.pLayContent:getWidth())
end


-- 析构方法
function SystemNotice:onSystemNoticeDestroy(  )
	
	self:onPause()
end
--注册消息
function SystemNotice:regMsgs(  )
	
end
--注销消息
function SystemNotice:unregMsgs(  )
	
end

-- 暂停方法
function SystemNotice:onPause()
	-- 注销定时器
	if self.nUpHandler then
	    MUI.scheduler.unscheduleGlobal(self.nUpHandler)
	    self.nUpHandler = nil
	end
	self:unregMsgs()	
end

--继续方法
function SystemNotice:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--_data: ChatData
function SystemNotice:setCurData( _data )
	if (not _data) or (self:isHadNoticeData(_data) == true) then
		return  
	end

	-- dump(_data,"SystemNotice",20)
	
	if _data.nRollTime > 1 then --对于显示多次的，也可能有多条 ，需要定时器来判断
		local data = {}
		data.type = 1 --用来区分
		-- local sSender = {}
		-- if  _data.nTmsg == 3 then  --喇叭
		-- 	sSender ={text = _data.sn .. ":"}
		-- 	-- data.sContent =  _data.sCnt 
		-- elseif _data.nTmsg == 2 then --系统消息
		-- 	sSender ={text = getConvertedStr(5,10218) .. ":"}
		-- end
		data.sContent = self:getContent(_data)
		-- table.insert(data.sContent,sSender)
		-- for k,v in pairs(_data.sCnt) do
		-- 	table.insert(data.sContent,sSender)
		-- end
		-- data.sContent = _data.sCnt 
		data.gapTime = 0
		data.endStopTime = 0
		data.rollTime = 1
		data.id = _data.nId

		data.isNeedShowNotice = true
		data.totalCoerceCount = _data.nRollTime --滚屏次数
		data.curCoerceIndex = 1
		self.dataMultiSeq[#self.dataMultiSeq+1] = data
		data.curTime = 0
		
		data.coerceGapTime = _data.nGapTime or 300 --如果没有的话默认五分钟
		data.tChatData = _data

		if(not self.nUpHandler) then
			 self.nUpHandler = MUI.scheduler.scheduleGlobal(
	   	 handler(self, self.updateCoerce), 1)
		end
	else--对于只显示一次的，可能有多条
		local data = {}
		data.id = _data.nId
		data.type = 2 --用来区分
		data.rollTime = _data.nRollTime
		
		data.sContent = self:getContent(_data)
		data.endStopTime = 0
		data.index = #self.dataOneSeq + 1
		self.dataOneSeq[#self.dataOneSeq+1] = data

		data.tChatData = _data
		if not self.isShowNotice then
			self:noticeRunAction(data)
		end
	end
end
function SystemNotice:getContent( _data )
	-- body
	local sSender = {}
	local tContent = {}
	if  _data.nTmsg == 3 then  --喇叭
		sSender ={text = _data.sSn .. ":"}
		-- data.sContent =  _data.sCnt 
	else  -- if _data.nTmsg == 2 or _data.nTmsg == 4 then --系统消息
		sSender ={text = getConvertedStr(5,10218) .. ":"}
	end
	table.insert(tContent ,sSender)
    --dump(_data.sCnt, "_data.sCnt", 100000)
	for k,v in pairs(_data.sCnt) do
        local tClone = clone(v)
        if tClone.text then
            --print("tClone.text", string.find(tClone.text, "\\n"));
            tClone.text = string.gsub(tClone.text, "\\n", "")
        end
		table.insert(tContent, tClone)
	end
	return tContent

end
--创建并执行动作
function SystemNotice:noticeRunAction(_data)
	if not _data then
		self.tChatData = nil
		return 
	end
	
	self.tChatData = _data.tChatData
	--红包要加图片
	if self.tChatData and self.tChatData:getIsRedPacket() then
		if self.pImgHonBao then
			self.pImgHonBao:setVisible(true)
		else
		 	self.pImgHonBao = MUI.MImage.new("#v2_img_honbaotub.png")
		 	self.pLayBg:addView(self.pImgHonBao, 1)
		 	self.pImgHonBao:setPosition(125, 36)

		 	self.pImgHonBao:setViewTouched(true)
			self.pImgHonBao:setIsPressedNeedScale(false)
			self.pImgHonBao:setIsPressedNeedColor(false)
			self.pImgHonBao:onMViewClicked(handler(self, self.onClickNotice))
		end
	else
		if self.pImgHonBao then
			self.pImgHonBao:setVisible(false)
		end
	end
		

	if _data.type == 2 then  --只显示一次的
		self.curOneRunIndex = _data.index
	end
	self:setVisible(true)
	self.isShowNotice = true--当前是否在显示公告

    local tNewStr = clone(_data.sContent) --为了不影响原数据
	-- tStr = removeSysEmoInTable(tNewStr)
	strRich = getTableParseEmo(tNewStr)
	self.pTxtNotice:setString(strRich,false)

	self:setTextToRight(self.pTxtNotice:getPosition())
	
	local length = self.pTxtNotice:getContentSize().width
	self.pLayMove:setContentSize(cc.size(length, self.pLayMove:getHeight()))
	local index = 1
	local actionList = {}
	for i=1,_data.rollTime do
		actionList[index] = cc.MoveTo:create(self.moveSpeed*length+4,cc.p(-length, 0))
		index = index + 1
		if i == _data.rollTime then
			actionList[index] = cc.DelayTime:create(_data.endStopTime)
		else
			actionList[index] = cc.DelayTime:create(_data.gapTime-self.moveSpeed*length)
			index = index + 1
			actionList[index] = cc.CallFunc:create(handler(self, self.setTextToRight))
			index = index + 1
		end
	end
	local sequence = transition.sequence(actionList)
	--创建动作参数
	local _params = {}
	--设置动作结束回调
	_params.onComplete = function (  )
		self.tChatData = nil
		self:onActionFinish(_data)
	end
	--执行动作
	transition.execute(self.pLayMove, sequence, _params)


end
function SystemNotice:updateCoerce( )
	if self.dataMultiSeq and type(self.dataMultiSeq) == "table" then
		for i,v in ipairs(self.dataMultiSeq) do
			v.curTime = v.curTime + 1
			if v.curCoerceIndex == 1  then
				if not self.isShowNotice then
					v.curCoerceIndex = v.curCoerceIndex + 1
					v.isNeedShowCoerce = true
					self:noticeRunAction(v)
					break
				end
				
			end
			if  v.curCoerceIndex > 1 and  v.curTime >= (v.curCoerceIndex -1)*v.coerceGapTime then
				v.isNeedShowCoerce = true
				if  not self.isShowNotice and v.curCoerceIndex <= v.totalCoerceCount then
					v.curCoerceIndex = v.curCoerceIndex + 1
					self:noticeRunAction(v)	
				end
			end
	
		end
	end
end
function SystemNotice:onActionFinish(_data)
	
	for i,v in ipairs(self.dataMultiSeq) do
		if v.isNeedShowCoerce == true and v.curCoerceIndex <= v.totalCoerceCount and (v.curTime >= (v.curCoerceIndex -1)*v.coerceGapTime) then
			v.curCoerceIndex = v.curCoerceIndex + 1
			self:noticeRunAction(v)
			return
		end
	end
	if self.curOneRunIndex == #self.dataOneSeq then
		self:setVisible(false)
		self.isShowNotice = false
		Player.tRollChatInfos[_data.id] = _data
	else
	
		self:noticeRunAction(self.dataOneSeq[self.curOneRunIndex+1])
	end
end

--判断滚屏队列中是否已经包含了这条消息
function SystemNotice:isHadNoticeData( tData )
	-- body
	if not tData then
		return false
	end
	for k, v in pairs(self.dataMultiSeq) do
		if v.id == tData.nId then
			return true
		end
	end
	for k, v in pairs(self.dataOneSeq) do
		if v.id == tData.nId then
			return true
		end
	end
	return false
end

function SystemNotice:onClickNotice( )
	local tChatData = self.tChatData
	if not tChatData then
		return
	end
	if tChatData:getIsRedPacket() then--红包
		showDlgRedPacket(tChatData)
		return
	end

    --系统公告跳转
	onSysNoticeJump(tChatData)

end

return SystemNotice