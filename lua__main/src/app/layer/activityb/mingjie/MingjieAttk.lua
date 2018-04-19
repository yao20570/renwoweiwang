----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2018-02-26 16:09:57
-- Description: 冥界入侵玩法说明tab
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local MingjieAttk = class("MingjieAttk", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function MingjieAttk:ctor( _tSize )
    self:setContentSize(_tSize)
	--解析文件
	parseView("lay_mingjie_attk", handler(self, self.onParseViewCallback))
end

--解析界面回调
function MingjieAttk:onParseViewCallback( pView )
	-- pView:setContentSize(self:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("MingjieAttk", handler(self, self.onMingjieAttkDestroy))
end

-- 析构方法
function MingjieAttk:onMingjieAttkDestroy(  )
    self:onPause()
end

function MingjieAttk:regMsgs(  )
end

function MingjieAttk:unregMsgs(  )
end

function MingjieAttk:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function MingjieAttk:onPause(  )
	self:unregMsgs()

end

function MingjieAttk:setupViews(  )
	-- local pTxtDesc = self:findViewByName("txt_desc")
	-- pTxtDesc:setString(getTipsByIndex(20033))

	self.pLayBtn = self:findViewByName("lay_btn")
	self.pGoBtn = getCommonButtonOfContainer(self.pLayBtn ,TypeCommonBtn.L_BLUE, getConvertedStr(9, 10153))
	self.pGoBtn:onCommonBtnClicked(handler(self, self.onGoClicked))

	--文本
	self.pTxtTip = self:findViewByName("txt_tip")
	self.pTxtTip:setString(getConvertedStr(9,10183))
	setTextCCColor(self.pTxtTip,_cc.pwhite)

	self.pLbCd1 = self:findViewByName("lb_cd1")
	self.pLbCd2 = self:findViewByName("lb_cd2")
	self.pLbDesc1 = self:findViewByName("lb_desc1")
	self.pLbDesc2 = self:findViewByName("lb_desc2")
	self.pLbDesc1:setString(getTextColorByConfigure(getTipsByIndex(20150)))
	self.pLbDesc2:setString(getTextColorByConfigure(getTipsByIndex(20151)))
	-- local tConTable = {}
	-- --文本
	-- local tLabel = {
	-- 	{getConvertedStr(3, 10479),getC3B(_cc.white)},
	-- }
	-- tConTable.tLabel = tLabel
	-- pGoBtn:setBtnExText(tConTable)
	-- self.pLayContent = self:findViewByName("lay_content")
	-- --创建
	-- self.bIsCanGetItem = true
	-- self.pLayMoBingHelp = AttackMoBingHelp.new(self)		
	-- self.pLayContent:addView(self.pLayMoBingHelp, 1)
	-- self.pLayMoBingHelp:setPosition(60, 220)
end

function MingjieAttk:updateViews(  )

	local tData = Player:getActById(e_id_activity.mingjie)
	if tData then
		local nTime=tData:getStageLeftTime()
		if nTime > 0 and tData.nS ~= 0 then
			regUpdateControl(self,handler(self,self.onUpdateTime))
		else
			if tData.nS == 1 then
				self.pLbCd2:setString(string.format(getConvertedStr(9,10155),getConvertedStr(9,10156)),false)
				setTextCCColor(self.pLbCd2,_cc.white)
				self.pLbCd1:setString(string.format(getConvertedStr(9,10154), getConvertedStr(9,10156)),false)
				setTextCCColor(self.pLbCd1,_cc.white)
			elseif tData.nS == 2 then
				self.pLbCd2:setString(string.format(getConvertedStr(9,10155),getConvertedStr(9,10157)),false)
				setTextCCColor(self.pLbCd2,_cc.white)
				self.pLbCd1:setString(string.format(getConvertedStr(9,10154), getConvertedStr(9,10157)),false)
				setTextCCColor(self.pLbCd1,_cc.white)
			else
				self.pLbCd2:setString(string.format(getConvertedStr(9,10155),getConvertedStr(9,10156)),false)
				setTextCCColor(self.pLbCd2,_cc.white)
				self.pLbCd1:setString(string.format(getConvertedStr(9,10154), getConvertedStr(9,10156)),false)
				setTextCCColor(self.pLbCd1,_cc.white)
			end
		end
		if tData.nS == 2  then
			self.pGoBtn:updateBtnText(getConvertedStr(9,10010))
			self.pLayBtn:setVisible(true)
			self.pTxtTip:setVisible(false)
		elseif tData.nS == 0 then
			self.pLayBtn:setVisible(false)
			self.pTxtTip:setVisible(false)
		else
			self.pLayBtn:setVisible(true)
			self.pTxtTip:setVisible(true)
		end 
	else
		self.pLayBtn:setVisible(false)
		self.pTxtTip:setVisible(false)
	end
end


function MingjieAttk:onUpdateTime( )
	-- body
	local tData = Player:getActById(e_id_activity.mingjie)
	if not tData then
		self:closeDlg(false)
		return
	end
	local nTime=tData:getStageLeftTime()
	if nTime >0 and tData.nS ~= 0 then
		if tData.nS == 1 then
			self.pLbCd1:setString(string.format(getConvertedStr(9,10154), formatTimeToHms(nTime)),false)
			setTextCCColor(self.pLbCd1,_cc.blue)
			self.pLbCd2:setString(string.format(getConvertedStr(9,10155),getConvertedStr(9,10156)),false)
			setTextCCColor(self.pLbCd2,_cc.white)
		elseif tData.nS == 2 then
			self.pLbCd1:setString(string.format(getConvertedStr(9,10154), getConvertedStr(9,10157)),false)
			setTextCCColor(self.pLbCd1,_cc.white)
			self.pLbCd2:setString(string.format(getConvertedStr(9,10155), formatTimeToHms(nTime)),false)
			setTextCCColor(self.pLbCd2,_cc.blue)

		end
	else

		self:updateViews()
		unregUpdateControl(self)--停止计时刷新
	end
end

function MingjieAttk:onGoClicked( )
	local tData = Player:getActById(e_id_activity.mingjie)
	if not tData then
		self:closeDlg(false)
		return
	end
	if tData.nS == 2 then
		local nBlockId = Player:getWorldData():getMyCityBlockId()
		local tBlockData = getWorldMapDataById(nBlockId)
		if not tBlockData then
			return
		end
		local tCityData = getWorldCityDataById(tBlockData.maincity)
		if tCityData then
			closeDlgByType(e_dlg_index.mingjie)
			closeDlgByType(e_dlg_index.dlgwarhall)
			closeDlgByType(e_dlg_index.actmodelb)

			local fX,fY = tCityData.tMapPos.x, tCityData.tMapPos.y
			sendMsg(ghd_world_location_mappos_msg, {fX = fX, fY = fY, isClick = true})
		end


	elseif tData.nS == 1 then
		closeDlgByType(e_dlg_index.mingjie)
		closeDlgByType(e_dlg_index.actmodelb)
		closeDlgByType(e_dlg_index.dlgwarhall)
		sendMsg(ghd_home_show_base_or_world, 2)
	end 

	


end

return MingjieAttk



