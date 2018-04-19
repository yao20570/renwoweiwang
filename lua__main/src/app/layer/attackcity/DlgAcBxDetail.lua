-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2018-01-22 15:55:17 星期一
-- Description: 攻城掠地宝箱详情对话框
-----------------------------------------------------
local DlgAlert = require("app.common.dialog.DlgAlert")
local MImgLabel = require("app.common.button.MImgLabel")
local IconGoods = require("app.common.iconview.IconGoods")
local DlgAcBxDetail = class("DlgAcBxDetail", function ()
	return DlgAlert.new(e_dlg_index.acbxdetail, 270, 130)
end)

--构造
function DlgAcBxDetail:ctor(_tData)
	-- body
	self:myInit(_tData)
	parseView("dlg_ac_bx_detail", handler(self, self.onParseViewCallback))
end
  
--解析布局回调事件
function DlgAcBxDetail:onParseViewCallback( pView )
	-- body
	
	self:addContentView(pView, false)
	self:setupViews()
	self:updateViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgAcBxDetail",handler(self, self.onDestroy))
    self:setLocalZOrder(100)

end

function DlgAcBxDetail:myInit( _tData )
	-- body
	self.tData = self.tData or _tData
	self.nState = 0
end

--初始化控件
function DlgAcBxDetail:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(9, 10116))
	local default=self:findViewByName("default")
	-- self.pTxtRewardTitle2=self:findViewByName("txt_reward_title2")
	self. pLayBtn=self:findViewByName("lay_btn")
	self.pBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.M_YELLOW, getConvertedStr(5, 10208), false)
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))

	self.pTxtTip = self:findViewByName("txt_tip")

	self.pLayReward = self:findViewByName("lay_reward")

	self.pImgState = self:findViewByName("img_state")

	self:addList()

end

-- 修改控件内容或者是刷新控件数据
function DlgAcBxDetail:updateViews()
	-- body
	

	-- local tTemp=luaSplit(self.tData.item,":")
	-- if tTemp then
	-- 	local tGood = getGoodsByTidFromDB(tTemp[1])
	-- 	if tGood then
	-- 		local pTempView = IconGoods.new(TypeIconGoods.HADMORE)
	-- 		local nWidth = pTempView:getWidth()
	-- 		pTempView:setScale(0.8)
 --         	pTempView:setCurData(tGood)
 --            pTempView:setMoreText(tGood.sName)
 --            pTempView:setMoreTextColor(getColorByQuality(tGood.nQuality))
 --            pTempView:setNumber(tonumber(tTemp[2]))
 --            self.pLayReward:addView(pTempView)
	-- 		centerInView(self.pLayReward,pTempView)
	-- 		pTempView:setPositionX(pTempView:getPositionX() + (nWidth - nWidth * 0.8) / 2)
	-- 	end
	-- end
	local tStr = getTextColorByConfigure(string.format(getConvertedStr(9,10121),self.tData.cost))
	self.pTxtTip:setString(tStr)

	local tActData=Player:getActById(e_id_activity.attackcity)
	self.nState = tActData:getBxState(self.tData.id,self.tData.cost)

	if self.nState == 1 then --未达到
		self.pLayBtn:setVisible(false)
		self.pImgState:setCurrentImage("#v2_fonts_weidadao.png")
		self.pImgState:setVisible(true)
	elseif self.nState == 2 then  --可领取
		self.pLayBtn:setVisible(true)
		self.pImgState:setVisible(false)
	else --已领取
		self.pLayBtn:setVisible(false)
		self.pImgState:setCurrentImage("#v2_fonts_yilingqu.png")
		self.pImgState:setVisible(true)
	end

end

function DlgAcBxDetail:addList(  )
	-- body
	local tTemp=luaSplit(self.tData.item,";")
	local nX=0
	if #tTemp == 1 then
		nX=190
	elseif #tTemp == 2 then
		nX=135
	elseif #tTemp == 3 then
		--todo
		nX= 70

	elseif #tTemp>=4 then
		--todo
		nX= 0
	end
	if not self.pListView then
		local nCurrCount = #tTemp
		local pLayGoods = self.pLayReward
		self.pListView = MUI.MListView.new {
		    viewRect   = cc.rect(0, 0, pLayGoods:getContentSize().width, pLayGoods:getContentSize().height),
		    direction  = MUI.MScrollView.DIRECTION_HORIZONTAL,
		    itemMargin = {left = 12,
		        right =  0,
		        top = 15,
		        bottom = 5},
		}
		pLayGoods:addView(self.pListView)
		centerInView(pLayGoods, self.pListView)

		self.pListView:setPositionY(self.pListView:getPositionY() - 20)
		self.pListView:setPositionX(self.pListView:getPositionX() + nX)
		self.pListView:setItemCallback(function ( _index, _pView )
			local tItemData = luaSplit(tTemp[_index],":")
            local pItemData = getGoodsByTidFromDB(tItemData[1])
                local pTempView = _pView
                if pTempView == nil then
                    pTempView = IconGoods.new(TypeIconGoods.HADMORE)
                end
                pTempView:setScale(0.8)
                pTempView:setCurData(pItemData)
                pTempView:setMoreText(pItemData.sName)
				pTempView:setMoreTextColor(getColorByQuality(pItemData.nQuality))	
				pTempView:setNumber(tonumber(tItemData[2]))
                return pTempView
            end)
		self.pListView:setItemCount(nCurrCount)
		self.pListView:reload(true)
	else
		self.pListView:notifyDataSetChange(true)
	end

end
function DlgAcBxDetail:onBtnClicked(  )
	-- body
	if self.nState == 2 then
		
		SocketManager:sendMsg("getAttkCityBxReward", {self.tData.id}, function(__msg)
			-- body

			if __msg.body and __msg.body.ob then
				--奖励领取表现(包含有武将的情况走获得武将流程)
				local tActData=Player:getActById(e_id_activity.attackcity)
				showGetItemsAction(__msg.body.ob)	
				tActData:refreshDatasByServer(__msg.body)
				self:updateViews()
				sendMsg(gud_refresh_activity)
				self:closeDlg(false)

			end
		end)
	end


end


--析构方法
function DlgAcBxDetail:onDestroy()
	self:onPause()
end

-- 注册消息
function DlgAcBxDetail:regMsgs( )
	-- body


end

-- 注销消息
function DlgAcBxDetail:unregMsgs(  )
	-- body
	
end


--暂停方法
function DlgAcBxDetail:onPause( )
	-- body
	self:unregMsgs()

end

--继续方法
function DlgAcBxDetail:onResume( )
	-- body
	self:regMsgs()

end

return DlgAcBxDetail
