-- Author: liangzhaowei
-- Date: 2017-06-30 15:05:22
-- 英雄属性item

local MCommonView = require("app.common.MCommonView")
local IconGoods = require("app.common.iconview.IconGoods")

local ItemUpdatePlace = class("ItemUpdatePlace", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function ItemUpdatePlace:ctor()
	-- body
	self:myInit()

	parseView("item_update_palace", handler(self, self.onParseViewCallback))


	--注册析构方法
	self:setDestroyHandler("ItemUpdatePlace",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemUpdatePlace:myInit()
	self.pData = {} --数据
	self.tShowAwardData = {} --可以显示物品
	self.nGetState = 1 --领取状态
	self.tShowInfo = {}--获取显示信息
end

--解析布局回调事件
function ItemUpdatePlace:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)


	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemUpdatePlace:setupViews( )

	--ly     
	self.pLyList = self:findViewByName("ly_list")
	self.pLyBtn = self:findViewByName("ly_btn")


	--lb
	self.pLbTitle = self:findViewByName("lb_title")
	self.pLbName  = self:findViewByName("lb_name")
	setTextCCColor(self.pLbName,_cc.yellow)
	local pLbDesc = self:findViewByName("lb_desc")
	local pLayDesc = self:findViewByName("lay_desc")

	self.pLbDesc = MUI.MLabel.new({text = "", size = 18,
		anchorpoint = cc.p(0.5, 0.5),
		dimensions = cc.size(176, 0)
		})
	pLayDesc:addView(self.pLbDesc, 10)
	self.pLbDesc:setPosition(pLbDesc:getPosition())
	setTextCCColor(self.pLbDesc, _cc.pwhite)

	--img
	self.pImgIcon = self:findViewByName("img_icon")
	self.pImgHaveGet = self:findViewByName("img_have_get")

	self.pImgIconDi = self:findViewByName("img_icon_di")
	self.pImgIconDi:setFlippedY(true)


	self.pBtn = getCommonButtonOfContainer(self.pLyBtn,TypeCommonBtn.M_BLUE, getConvertedStr(5, 10220))
	self.pBtn:onCommonBtnClicked(handler(self, self.onGetClicked))

end

-- 修改控件内容或者是刷新控件数据
function ItemUpdatePlace:updateViews(  )
	-- body
	if not self.pData then
       return
	end

	--显示奖励数据
	if self.pData.award then
		self.tShowAwardData = getRewardItemsFromSever(self.pData.award) 
	end
    -- 刷新列表内容
    gRefreshHorizontalList(self.pLyList, self.tShowAwardData)

    --标题文字
    if self.pData.lv then
	    local tStr = {
	    {text= getConvertedStr(5, 10221),color= _cc.white},
	    {text= self.pData.lv..getConvertedStr(5, 10061) ,color= _cc.blue},
	    {text= getConvertedStr(5, 10222),color= _cc.white},
		}
    	self.pLbTitle:setString(tStr)
    end

    --开放对象
    if self.tShowInfo and self.tShowInfo[1] then
    	self.pLbName:setString(getConvertedStr(5, 10223 )..self.tShowInfo[1])
    end

    --描述语
    if self.tShowInfo and self.tShowInfo[2] then
    	self.pLbDesc:setString(self.tShowInfo[2])
    end

    --icon
    if self.tShowInfo and self.tShowInfo[3] then
		self.pImgIcon:setCurrentImage("#"..self.tShowInfo[3])
    end 

    --领取状态
    if self.nGetState then
       	if self.nGetState == en_get_state_type.cannotget then
       		self.pBtn:setBtnEnable(true)
       		self.pBtn:setVisible(false)
       		self.pImgHaveGet:setCurrentImage("#v2_fonts_weidadao.png")
       		self.pImgHaveGet:setVisible(true)
       		self.pBtn:setButton(TypeCommonBtn.M_BLUE, getConvertedStr(5, 10220))--未达到
    	elseif self.nGetState == en_get_state_type.canget then
       		self.pBtn:setBtnEnable(true)
       		self.pBtn:setVisible(true)
       		self.pImgHaveGet:setVisible(false)
    		self.pBtn:setButton(TypeCommonBtn.M_YELLOW, getConvertedStr(5, 10208))--领取
    	elseif self.nGetState == en_get_state_type.haveget then--已领取
    		self.pBtn:setBtnEnable(false)
    		self.pBtn:setVisible(false)
       		self.pImgHaveGet:setCurrentImage("#v2_fonts_yilingqu.png")
       		self.pImgHaveGet:setVisible(true)
    	end
    end
    


end

--设置回调
function ItemUpdatePlace:setHandler(_hander)
	if _hander then
		self.pHandler = _hander
	end
end

--点击回调
function ItemUpdatePlace:onGetClicked()

    --领取状态
    if self.nGetState then
    	if self.nGetState == en_get_state_type.canget then
			if self.pHandler then
				self.pHandler(self.pData.lv)
			end
    	else
    		TOAST(getConvertedStr(5, 10220))
    	end
    end

end

--析构方法
function ItemUpdatePlace:onDestroy(  )
	-- body
end

--设置数据 _data 活动数据 _nIndex 列表中的排列顺序
function ItemUpdatePlace:setCurData(_tData,_nIndex)
	if not _tData then
		return
	end

	local nIndex = _nIndex

	self.pActData = _tData--活动数据


    if nIndex and self.pActData.tConf[nIndex] and self.pActData.tConf[nIndex].lv then
    	self.pData  = self.pActData.tConf[nIndex]
    	self.nGetState = self.pActData:getStateByItemLv(self.pData.lv) 
    	-- if self.pActData.tConf[nIndex].tShowInfo then
    	-- 	self.tShowInfo = self.pActData.tConf[nIndex].tShowInfo
    	-- end

    	self.tShowInfo = self.pData.tShowInfo
    end


 --    local tStrSp = luaSplitMuilt(self.pActData.sRule,";",":")  --获取显示信息
    
	-- if tStrSp and nIndex and tStrSp[nIndex] then
	-- 	self.tShowInfo = tStrSp[nIndex]
	-- end

	self:updateViews()
	
end


return ItemUpdatePlace
