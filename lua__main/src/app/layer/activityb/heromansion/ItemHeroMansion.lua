-- Author: liangzhaowei
-- Date: 2017-08-05 17:34:24
-- 登坛拜将购买item

local MCommonView = require("app.common.MCommonView")
local MImgLabel = require("app.common.button.MImgLabel")
local ItemHeroMansion = class("ItemHeroMansion", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数 当前下标
function ItemHeroMansion:ctor(_nIndex)
	-- body
	self:myInit()
	self.nIndex = _nIndex or 1


	parseView("item_hero_mansion", handler(self, self.onParseViewCallback))


	--注册析构方法
	self:setDestroyHandler("ItemHeroMansion",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemHeroMansion:myInit()
	self.pData = {} --数据
	self.nIndex = 1 --当前下标值
	self.pHandler = nil --回调参数
	self.pActData  = {} -- 活动数据

end

--解析布局回调事件
function ItemHeroMansion:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
end

--初始化控件
function ItemHeroMansion:setupViews( )
	--ly      
	self.pLyIcon = self:findViewByName("ly_icon")
	self.pLyCover = self:findViewByName("ly_cover")
	self.pLyMain = self:findViewByName("ly_main")


	--img
	self.pImgSelect  = self:findViewByName("img_select")
	self.pImgHaveGet  = self:findViewByName("img_have_get")
	self.pImgSale  = self:findViewByName("img_sale")

	
	--lb
	self.pLbSale = self:findViewByName("lb_sale")
	self.pLbName = self:findViewByName("lb_name")


	self.pImgLabel = MImgLabel.new({text="0", size = 20, parent = self.pLyMain})
	self.pImgLabel:setAnchorPoint(0,0.5)
	self.pImgLabel:showRedLine(true,6,"img")
	self.pImgLabel:setImg("#v1_img_qianbi.png")
	self.pImgLabel:followPos("center",185,95,10)


	self.pImgLabel2 = MImgLabel.new({text="0", size = 20, parent = self.pLyMain})
	self.pImgLabel2:setAnchorPoint(0,0.5)
	self.pImgLabel2:setImg("#v1_img_qianbi.png")
	self.pImgLabel2:followPos("center",185,45,10)	


	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
    self:onMViewClicked(handler(self,self.onViewClick))


	self.pLyCover:setViewTouched(true)
	self.pLyCover:onMViewClicked(function ()
		-- dump("herolllllllllllllllll")
	end)
	self.pLyCover:setIsPressedNeedScale(false)
	self.pLyCover:setIsPressedNeedColor(false)


end

-- 修改控件内容或者是刷新控件数据
function ItemHeroMansion:updateViews(  )
	-- body
	if not self.pData then
       return
	end

	local nSale = self.pActData:getSale()
	if self.pActData and self.pActData:getSale() then

		self.pImgSale:setVisible(true)
		if nSale >0.5 then
			self.pImgSale:setCurrentImage("#v1_img_kejiman.png")
		else
			self.pImgSale:setCurrentImage("#v1_img_xinpin.png")
		end
		self.pLbSale:setString((nSale*10).."折")--折扣
	end


	--物品信息
	local pIconData = getGoodsByTidFromDB(self.pData.i)
	if pIconData then
		self.pLbName:setString(pIconData.sName)
		pIconData.nCt = self.pData.n or 0
		self.pIcon = getIconGoodsByType(self.pLyIcon, TypeIconGoods.NORMAL, type_icongoods_show.itemnum, pIconData,TypeIconGoodsSize.L)
		self.pIcon:setIconIsCanTouched(false)
	end

	--选择框
	if self.nSelect == self.nIndex then
		self.pImgSelect:setVisible(true)
	else
		self.pImgSelect:setVisible(false)
	end

	--覆盖层
	if self.pData.b and self.pData.b > 0 then
		self.pLyCover:setVisible(true)
	else
		self.pLyCover:setVisible(false)
		local tActData = Player:getActById(e_id_activity.heromansion)
		-- if self.nSelect == 6 then--第六个固定为将印
			if tActData.np and tActData.nSp and tActData.np >= tActData.nSp then--只有在将印的个数达到最多时
				if self.pData.y == 1 then--并且后端字段表明已售罄的情况下
					self.pLyCover:setVisible(true)
				end
			end
		-- end
	end

	--显示价格
	if self.pData.g then
		self.pImgLabel:setString(self.pData.g)
	end

	--打折后的价格
	if self.pData.g then
		self.pImgLabel2:setString(self.pData.g*nSale)
	end

end

--析构方法
function ItemHeroMansion:onDestroy(  )
	-- body
end

--设置数据 _data ,_nSelect 当前选择
function ItemHeroMansion:setCurData(_tData,_nSelect)
	if not _tData then
		return
	end

	self.pData = _tData or {}

	self.nSelect = _nSelect or 0

	self.pActData  = Player:getActById(e_id_activity.heromansion)


	self:updateViews()
	

end

--设置回调句柄
function ItemHeroMansion:setViewHandler(_Handler)
	self.pHandler = _Handler
end

--设置回调
function ItemHeroMansion:onViewClick(pView)

	-- buyHeroMansion

	if self.pHandler then
		self.pHandler(self.nIndex)
	end

    if self.pData and self.pData.p and self.pData.i then
    	--dump(self.pData, "self.pData", 100)
    	showMansionTip(self.pData, function (  )
    		-- body
			SocketManager:sendMsg("buyHeroMansion", {self.pData.p,self.pData.i},handler(self, self.onGetDataFunc))	    		
			closeDlgByType(e_dlg_index.mansionitemtip) 
    	end)
		-- --这个价格需要再打折?
		-- local pIconData = getGoodsByTidFromDB(self.pData.i)
		-- if pIconData then
		--     local strTips = {
		--     		{color=_cc.pwhite,text=getConvertedStr(6, 10296)},
		-- 	    	{color=_cc.blue,text=pIconData.sName},--物品
		-- 	    	{color=_cc.blue,text="*"..self.pData.n},--数量
		-- 	    	{color=_cc.pwhite,text="?"},--问号
		-- 	    }

		-- 	local nPrice = math.floor(self.pActData:getSale() * self.pData.g) 
		-- 	showBuyDlg(strTips,nPrice,function ()
	 --    		SocketManager:sendMsg("buyHeroMansion", {self.pData.p,self.pData.i},handler(self, self.onGetDataFunc))	
		-- 	end,0) --星威提bug要求改成勾选了之后不要提示购买框 bugId 15331

		-- end

	end




end

--接收服务端发回的登录回调
function ItemHeroMansion:onGetDataFunc( __msg )
	-- dump(__msg,"msg",30)
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.buyHeroMansion.id then
       		if __msg.body.o then
       			showGetAllItems(__msg.body.o)
       		end       		       	
        end
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end





return ItemHeroMansion