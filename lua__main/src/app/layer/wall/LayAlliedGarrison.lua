
-----------------------------------------------------
-- author: maheng
-- Date: 2018-03-29 15:30:10
-- Description: 城墙友军驻防分页
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local DlgAlert = require("app.common.dialog.DlgAlert")
local ItemAlliedGarrison = require("app.layer.wall.ItemAlliedGarrison")
local LayAlliedGarrison = class("LayAlliedGarrison", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function LayAlliedGarrison:ctor(_tSize)
	-- body
	self:setContentSize(_tSize)
	self:myInit()
	--self:refreshData() --刷新数据
	parseView("dlg_allied_garrison", handler(self, self.onParseViewCallback))
	

end

--初始化成员变量
function LayAlliedGarrison:myInit()
	-- body

end

--解析布局回调事件
function LayAlliedGarrison:onParseViewCallback( pView )
	-- body
	-- self.pView = pView
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("LayAlliedGarrison",handler(self, self.onDestroy))	
end

--初始化控件
function LayAlliedGarrison:setupViews( )

	self.pLayRoot = self:findViewByName("lay_default")

	self.pLayBanner = self:findViewByName("lay_banner_bg")
	self.pLayDesc = self:findViewByName("lay_desc")
	self.pLayList = self:findViewByName("lay_list")


	self.pLayTitle1 = self:findViewByName("lb_title_1")
	self.pLayTitle2 = self:findViewByName("lb_title_2")
	self.pLayTitle3 = self:findViewByName("lb_title_3")
	self.pLayBtn = self:findViewByName("ly_btn")
  
    setMBannerImage(self.pLayBanner,TypeBannerUsed.cm)   
	self.pLayTitle2:setString(getTextColorByConfigure(getTipsByIndex(20154)), false)

	self.pBtn =  getCommonButtonOfContainer(self.pLayBtn,TypeCommonBtn.L_BLUE,getConvertedStr(6,10754))
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))

	self.tPos = {64, 192, 320, 448, 576}	
	self.tTitles = {
			getConvertedStr(3, 10181),
			getConvertedStr(3, 10180),
			getConvertedStr(3, 10182),
			getConvertedStr(3, 10183),
			getConvertedStr(3, 10184),
		}
	for i=1,#self.tPos do
		local pLabel = MUI.MLabel.new({
	        text=self.tTitles[i],
	        size=20,
	        anchorpoint=cc.p(0.5, 0.5)
    	})
		pLabel:setPosition(self.tPos[i], self.pLayDesc:getHeight()/2)		
		self.pLayDesc:addView(pLabel, 10)
	end		
	
end

-- 修改控件内容或者是刷新控件数据
function LayAlliedGarrison:updateViews()
	local pData = Player:getWorldData():getHelpMsgs()
	if not pData then
		return
	end
	self.tListData = pData
	local nItemCnt = #self.tListData
	local nNumT = 0	
	local pWall = Player:getBuildData():getBuildById(e_build_ids.gate) --城墙数据
	if pWall and pWall.nLv then
		if getWallBaseDataByLv(pWall.nLv) then
			nNumT = getWallBaseDataByLv(pWall.nLv).guardnum
		end
	end
	--城防武将熟练
	local sStr1 = {
		{color=_cc.white,text=getConvertedStr(6, 10755)},
		{color=_cc.blue,text=nItemCnt},
		{color=_cc.white,text="/"..nNumT},
	}
	self.pLayTitle1:setString(sStr1, false)

	--兵力数
	local nTroops = 0
	for i=1,#self.tListData do
		nTroops = nTroops + self.tListData[i].nTroops
	end

	local sStr2 = {
		{color=_cc.white,text=getConvertedStr(6, 10831)},
		{color=_cc.blue,text=nTroops}
	}
	self.pLayTitle3:setString(sStr2, false)

	
	
	if not self.pListView then
	    self.pListView = MUI.MListView.new {
            bgColor = cc.c4b(255, 255, 255, 250),
            viewRect = cc.rect(0, 0, self.pLayList:getWidth(), self.pLayList:getHeight()),
            itemMargin = {left = 0,
            right = 0,
            top = 0 ,
            bottom = 0 },
            direction = MUI.MScrollView.DIRECTION_VERTICAL ,--listView方向
        }
        self.pListView:setBounceable(true) --是否回弹
        self.pListView:setPosition((self.pLayList:getWidth() - self.pListView:getWidth())/2, 0)
        self.pLayList:addView(self.pListView, 10)        
        --上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
		self.pListView:setItemCount(nItemCnt)
		self.pListView:setItemCallback(handler(self, self.onEveryCallback))
		self.pListView:reload(false)	
	else        
		self.pListView:notifyDataSetChange(false, nItemCnt)
	end	

	local bShow = nItemCnt <= 0
	--没有数据提示
	local tLabel = {
	    str = getConvertedStr(6, 10832),
	}
	if not self.pNullUi then
		local pNullUi = getLayNullUiImgAndTxt(tLabel)
		pNullUi:setIgnoreOtherHeight(true)
		self.pLayList:addView(pNullUi)
		centerInView(self.pLayList, pNullUi)
		self.pNullUi = pNullUi
	end
	self.pNullUi:setVisible(bShow)		
end

function LayAlliedGarrison:onEveryCallback( _index, _pView ) 	
    local pTempView = _pView
    if pTempView == nil then
    	pTempView   = ItemAlliedGarrison.new()
	end	
	pTempView:setData(self.tListData[_index])
    return pTempView
end
--左边按钮点击事件
function LayAlliedGarrison:onBtnClicked(pView)
	if not self.tListData or #self.tListData <= 0 then
		return
	end
	local sStr = ""
	for k, v in pairs(self.tListData) do
		sStr = sStr..v.sTid..","
	end
	local pDlg, bNew = getDlgByType(e_dlg_index.alert)
	if(not pDlg) then
	    pDlg = DlgAlert.new(e_dlg_index.alert)
	end
	pDlg:setTitle(getConvertedStr(3, 10070))
	pDlg:setContent(getConvertedStr(6, 10834))
	pDlg:setRightHandler(function (  )
		SocketManager:sendMsg("reqWorldGarrisonBack", {sStr}, handler(self, self.onWorldTaskInput))
		pDlg:closeDlg(false)
	end)
	pDlg:showDlg(bNew)
end

--发送返回
function LayAlliedGarrison:onWorldTaskInput( __msg, __oldMsg)
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqWorldGarrisonBack.id  then
        	TOAST(getConvertedStr(6, 10835))
        end
    else
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end

-- 析构方法
function LayAlliedGarrison:onDestroy(  )
	-- body
	self:onPause()
end

function LayAlliedGarrison:regMsgs(  )
	regMsg(self, gud_refresh_wall, handler(self, self.updateViews))

end

function LayAlliedGarrison:unregMsgs(  )
	unregMsg(self, gud_refresh_wall)
end


--暂停方法
function LayAlliedGarrison:onPause( )

	self:unregMsgs()
end

--继续方法
function LayAlliedGarrison:onResume( )
	
	self:updateViews()
	self:regMsgs()
end

return LayAlliedGarrison