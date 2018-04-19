-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-04-18 15:12:23 星期二
-- Description: 王宫界面功能项 主城保护 建筑队列 
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local MBtnExText = require("app.common.button.MBtnExText")

local ItemPalaceFunc = class("ItemPalaceFunc", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemPalaceFunc:ctor(type)
	-- body
	self:myInit(type)

	parseView("item_funcpanel", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemPalaceFunc",handler(self, self.onItemPalaceFuncDestroy))
	
end

--初始化参数
function ItemPalaceFunc:myInit(_type)
	-- body
	self._nType = _type or 1	
end

--解析布局回调事件
function ItemPalaceFunc:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:onResume()
end

--初始化控件
function ItemPalaceFunc:setupViews( )
	self.pLayRoot = self:findViewByName("root")
	self.pLayKuang = self:findViewByName("img_kuang") 
	self.pImg = MUI.MImage.new("ui/daitu.png", {scale9=false})
	self.pLayKuang:addView(self.pImg)
	centerInView(self.pLayKuang, self.pImg)
	--ly             	
	self.pLybtn =  self:findViewByName("lay_btn")--规则按钮层	
	--lb
	self.pLbTitle = self:findViewByName("lb_title")--标题
	self.pLbTitle:setString(getConvertedStr(6, 10096))

	self.pLbTip = self:findViewByName("lb_tip")--状态提示
	self.pLbTip:setString(getConvertedStr(6, 10092))
	setTextCCColor(self.pLbTip, _cc.red)	
	--img
	self.pImgTitleBg = self:findViewByName("img_title_bg")--标题背景	

	self.pbtn = getCommonButtonOfContainer(self.pLybtn, TypeCommonBtn.M_YELLOW, getConvertedStr(6, 10090), false)	
	self.pbtn:onCommonBtnClicked(handler(self, self.onBtnClicked))
	setMCommonBtnScale(self.pLybtn, self.pbtn, 0.8)

end

-- 修改控件内容或者是刷新控件数据
function ItemPalaceFunc:updateViews(  )
	-- body
	local nleftTime = 0 --剩余时间
	if self._nType == 1 then--主城保护剩余时间
		local buffvo = Player:getBuffData():getBuffVo(e_buff_ids.cityprotect)
		--dump(buffvo, "buffvo", 100)
		if buffvo then
			nleftTime = buffvo:getRemainCd()
		else
			nleftTime = 0
		end		
		local playerinfo = Player:getPlayerInfo()
		local sImg = getPlayerCityIcon(Player:getBuildData():getBuildById(e_build_ids.palace).nLv, playerinfo.nInfluence)
		if sImg then
			self.pImg:setCurrentImage(sImg)
		end
		self.pImg:setPosition(150/2, 110/2)
		self.pImg:setScale(150/self.pImg:getContentSize().width)
	elseif self._nType == 2 then--建造队列剩余时间
		local builddata = Player:getBuildData() 
		if builddata then
			nleftTime = builddata:getBuildBuyFinalLeftTime()
		else
			nleftTime = 0
		end
		self.pImg:setCurrentImage("#i100099.png")		
		self.pImg:setPosition(self.pImg:getWidth()/2, self.pImg:getHeight()/2)
		self.pImg:setScale(1)
	end
	
	if nleftTime == 0 then--当前未雇用建筑队列
		self.pLbTip:setString(getConvertedStr(6, 10086))
		self.pbtn:updateBtnText(getConvertedStr(6, 10090))--按钮文字 开启
		unregUpdateControl(self)--停止计时刷新
	elseif nleftTime > 0 then--当前雇用建筑队列
		self.pbtn:updateBtnText(getConvertedStr(6, 10091))--按钮文字 增加时间
		--时间计时
		unregUpdateControl(self)--停止计时刷新
		regUpdateControl(self, handler(self, self.onUpdateTime))
	end
end

--析构方法
function ItemPalaceFunc:onItemPalaceFuncDestroy(  )
	self:onPause()
end
-- _bReshow(bool): 是否是在后台切回来而已
function ItemPalaceFunc:onResume( _bReshow )
	self:updateViews()
end
function ItemPalaceFunc:onPause(  )
	--取消秒刷新
	unregUpdateControl(self)
end

--按钮事件
function ItemPalaceFunc:onBtnClicked(pView)
	--body
	if self._nType == 1 then
		local tObject = {}
		tObject.nType = e_dlg_index.getcityprotect --dlg类型
		tObject.nIndex = 1
		sendMsg(ghd_show_dlg_by_type,tObject)
	elseif self._nType == 2 then--建筑队列
		local tObject = {}
		tObject.nType = e_dlg_index.buildbuyteam --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)
	end
end

--设置标题
function ItemPalaceFunc:setTitle(_stitle)
	-- body
	if not _stitle then
		return
	end
	self.pLbTitle:setString(_stitle)	
end

function ItemPalaceFunc:setType( _type )
	-- body
	self._nType = _type or self._nType
	self:updateViews()
end
--计时刷新
function ItemPalaceFunc:onUpdateTime()
	-- body
	local nleftTime = 0
	if self._nType == 1 then--主城保护剩余时间
		local buffvo = Player:getBuffData():getBuffVo(e_buff_ids.cityprotect)
		--dump(buffvo, "buffvo", 100)
		if buffvo then
			nleftTime = buffvo:getRemainCd()
		else
			nleftTime = 0
		end		
	elseif self._nType == 2 then--建造队列剩余时间
		local builddata = Player:getBuildData() 
		if builddata then
			nleftTime = builddata:getBuildBuyFinalLeftTime()
		else
			nleftTime = 0
		end
	end
	if nleftTime > 0 then
		self.pLbTip:setString(formatTimeToHms(nleftTime))
	else
		unregUpdateControl(self)--停止计时刷新
		self:updateViews()--停止刷新倒计时后立即刷新界面一次
	end
end
return ItemPalaceFunc