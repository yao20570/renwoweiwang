----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-18 17:31:20
-- Description: 城池驻防 子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local DlgCityGarrisonCall = require("app.layer.world.DlgCityGarrisonCall")
local ItemCityGarrison = class("ItemCityGarrison", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--bIsMine:是否是自己的武将(查看别人的驻守)
function ItemCityGarrison:ctor( bIsMine )
	self.bIsMine = bIsMine or false
	--解析文件
	parseView("item_city_garrison", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemCityGarrison:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemCityGarrison",handler(self, self.onItemCityGarrisonDestroy))
end

-- 析构方法
function ItemCityGarrison:onItemCityGarrisonDestroy(  )
    self:onPause()
end

function ItemCityGarrison:regMsgs(  )
end

function ItemCityGarrison:unregMsgs(  )
end

function ItemCityGarrison:onResume(  )
	self:regMsgs()
end

function ItemCityGarrison:onPause(  )
	self:unregMsgs()
end

function ItemCityGarrison:setupViews(  )
	self.pTxtLevel = self:findViewByName("txt_level")
	self.pTxtName = self:findViewByName("txt_name")
	self.pTxtHeroName = self:findViewByName("txt_hero_name")
	self.pTxtTroops = self:findViewByName("txt_troops")
	local pLayBtnCancel = self:findViewByName("lay_btn_cancel")
	self.pLayBtnCancel = pLayBtnCancel
	self.pBtnCancel = getCommonButtonOfContainer(pLayBtnCancel,TypeCommonBtn.M_BLUE, getConvertedStr(3, 10048))
	self.pBtnCancel:onCommonBtnClicked(handler(self, self.onCancelClicked))
	setMCommonBtnScale(self.pLayBtnCancel, self.pBtnCancel, 0.8)
end

function ItemCityGarrison:updateViews(  )
	if not self.tData then
		return
	end

	self.pTxtLevel:setString(self.tData.nLv)
	self.pTxtName:setString(self.tData.sName)
	self.pTxtHeroName:setString(self.sHeroName)
	self.pTxtTroops:setString(self.tData.nTroops)
	self.pLayBtnCancel:setVisible(self.tData.bIsMine)
	--
	local pColor = _cc.white
	if self.tData.bIsMine then
		pColor = _cc.blue
	end
	setTextCCColor(self.pTxtLevel, pColor)
	setTextCCColor(self.pTxtName, pColor)
	setTextCCColor(self.pTxtHeroName, pColor)
	setTextCCColor(self.pTxtTroops, pColor)
end

--
--tData:  HelpMsg类型
function ItemCityGarrison:setData( tData)
	self.tData = tData
	self.sHeroName = ""
	local tHero = getHeroDataById(self.tData.nHeroId)
	if tHero then
		self.sHeroName = tHero.sName
	end
	self:updateViews()
end

function ItemCityGarrison:onCancelClicked( pView )
	-- --如果是操作自己的武将撤离,且该武将不是驻守状态就提示xxx，且重新请求信息
	-- if self.bIsMine then
	-- 	local nState = Player:getWorldData():getHeroState(self.tData.nHeroId)
	-- 	if nState ~= e_type_task_state.garrison then
	-- 		TOAST(getConvertedStr(3, 10437))			
 --        	--相关界面重新请求数据
 --        	sendMsg(gud_city_garrisonInfo_req)
	-- 		return
	-- 	end
	-- end

	--弹出二次确认框
	local pDlg, bNew = getDlgByType(e_dlg_index.citygarrisoncall)
	if(not pDlg) then
	    pDlg = DlgCityGarrisonCall.new(e_dlg_index.citygarrisoncall)
	end
	pDlg:setTitle(getConvertedStr(3, 10070))
	pDlg:setData(self.tData)
	pDlg:setRightHandler(function (  )
		if self.bIsMine then
			SocketManager:sendMsg("reqWorldTaskInput", {self.tData.sTid, e_type_task_input.call, nil}, handler(self, self.onWorldTaskInput))
		else
			SocketManager:sendMsg("reqWorldGarrisonBack", {self.tData.sTid}, handler(self, self.onWorldTaskInput))
		end
		pDlg:closeDlg(false)
	end)
	pDlg:showDlg(bNew)
end

--发送返回
function ItemCityGarrison:onWorldTaskInput( __msg, __oldMsg)
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqWorldTaskInput.id or __msg.head.type == MsgType.reqWorldGarrisonBack.id  then
        	local sTid = __oldMsg[1]
        	sendMsg(ghd_world_city_garrison_call_msg, sTid)
        end
    else
        if self.bIsMine then
        	--相关界面重新请求数据
        	sendMsg(gud_city_garrisonInfo_req)
        end
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end

return ItemCityGarrison


