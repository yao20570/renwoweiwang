----------------------------------------------------- 
-- author: maheng
-- updatetime: 2018-03-29 17:07:20
-- Description: 友军驻防项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local DlgCityGarrisonCall = require("app.layer.world.DlgCityGarrisonCall")
local ItemAlliedGarrison = class("ItemAlliedGarrison", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--bIsMine:是否是自己的武将(查看别人的驻守)
function ItemAlliedGarrison:ctor(  )	
	--解析文件
	parseView("item_allied_garrison", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemAlliedGarrison:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemAlliedGarrison",handler(self, self.onItemCityGarrisonDestroy))
end

-- 析构方法
function ItemAlliedGarrison:onItemCityGarrisonDestroy(  )
    self:onPause()
end

function ItemAlliedGarrison:regMsgs(  )
end

function ItemAlliedGarrison:unregMsgs(  )
end

function ItemAlliedGarrison:onResume(  )
	self:regMsgs()
end

function ItemAlliedGarrison:onPause(  )
	self:unregMsgs()
end

function ItemAlliedGarrison:setupViews(  )
	self.pTxtLevel = self:findViewByName("lb_par_2")
	self.pTxtName = self:findViewByName("lb_par_1")
	self.pTxtHeroName = self:findViewByName("lb_par_3")
	self.pTxtTroops = self:findViewByName("lb_par_4")
	local pLayBtnCancel = self:findViewByName("lay_btn")
	self.pLayBtnCancel = pLayBtnCancel
	self.pBtnCancel = getCommonButtonOfContainer(pLayBtnCancel,TypeCommonBtn.M_BLUE, getConvertedStr(6, 10833))
	self.pBtnCancel:onCommonBtnClicked(handler(self, self.onCancelClicked))
	setMCommonBtnScale(self.pLayBtnCancel, self.pBtnCancel, 0.8)
end

function ItemAlliedGarrison:updateViews(  )
	if not self.tData then
		return
	end
	self.pTxtLevel:setString(self.tData.nLv)
	self.pTxtName:setString(self.tData.sName)
	self.pTxtHeroName:setString(self.sHeroName)
	self.pTxtTroops:setString(self.tData.nTroops)
	--
	local pColor = _cc.white
	setTextCCColor(self.pTxtLevel, pColor)
	setTextCCColor(self.pTxtName, pColor)
	setTextCCColor(self.pTxtHeroName, pColor)
	setTextCCColor(self.pTxtTroops, pColor)
end

--
--tData:  HelpMsg类型
function ItemAlliedGarrison:setData( tData)
	self.tData = tData
	self.sHeroName = ""
	local tHero = getHeroDataById(self.tData.nHeroId)
	if tHero then
		self.sHeroName = tHero.sName
	end
	self:updateViews()
end

function ItemAlliedGarrison:onCancelClicked( pView )
	--弹出二次确认框
	local pDlg, bNew = getDlgByType(e_dlg_index.citygarrisoncall)
	if(not pDlg) then
	    pDlg = DlgCityGarrisonCall.new(e_dlg_index.citygarrisoncall)
	end
	pDlg:setTitle(getConvertedStr(3, 10070))
	pDlg:setData(self.tData)
	pDlg:setRightHandler(function (  )
		SocketManager:sendMsg("reqWorldGarrisonBack", {self.tData.sTid}, handler(self, self.onWorldTaskInput))
		pDlg:closeDlg(false)
	end)
	pDlg:showDlg(bNew)
end

--发送返回
function ItemAlliedGarrison:onWorldTaskInput( __msg, __oldMsg)
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqWorldGarrisonBack.id  then
        	TOAST(getConvertedStr(6, 10836))
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end

return ItemAlliedGarrison


