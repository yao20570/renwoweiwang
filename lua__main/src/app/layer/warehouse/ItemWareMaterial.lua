-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-04-18 15:12:23 星期二
-- Description: 仓库资源项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local MRichProgressBar = require("app.common.progressbar.MRichProgressBar")
local MRichLabel = require("app.common.richview.MRichLabel")
local ItemWareMaterial = class("ItemWareMaterial", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function ItemWareMaterial:ctor(_idx)
	-- body
	self:myInit(_idx)

	parseView("item_warematerial", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemWareMaterial",handler(self, self.onItemWareMaterialDestroy))
	
end

--初始化参数
function ItemWareMaterial:myInit(_idx)
	-- body
	local tIdx = {e_resdata_ids.yb,e_resdata_ids.mc,e_resdata_ids.lc, e_resdata_ids.bt}
	self._nResId = tIdx[_idx] or nil
	self.nIdx = _idx or 1
	self.pData = {} --仓库资源数据
end

--解析布局回调事件
function ItemWareMaterial:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemWareMaterial:setupViews( )

	--ly
	self.pLyKuang =  self:findViewByName("lay_kuang")--头像层  	                
	self.pLyProgress = self:findViewByName("lay_progress_bg")--进度条层	
	self.pLyBtnPlus = self:findViewByName("lay_btn")--按钮层
	--lb
	self.pLbResName = self:findViewByName("lb_resname")--资源名字
	self.pLbResName:setString(getConvertedStr(6, 10107))
	setTextCCColor(self.pLbResName, _cc.blue)
	self.pLbResStatus = self:findViewByName("lb_res_status")--资源状态
	self.pLbResStatus:setString(getConvertedStr(6, 10118))
	setTextCCColor(self.pLbResStatus, _cc.blue)
	--进度条
	-- self.pProgressBar = MCommonProgressBar.new({bar = "v1_bar_lan_15.png",barWidth = 358, barHeight = 20})
	-- self.pLyProgress:addView(self.pProgressBar, 10)
	-- centerInView(self.pLyProgress, self.pProgressBar)
	self.pProgressBar = MRichProgressBar.new({barL = "v1_bar_lan_15.png", barR = "v1_bar_yellow_15.png",barWidth = 355, barHeight = 20})
	self.pLyProgress:addView(self.pProgressBar, 10)
	self.pProgressBar:setPosition(2, 2)
	--centerInView(self.pLyProgress, self.pProgressBar)
	--touxiang
	self.pIconRes = getIconGoodsByType(self.pLyKuang, TypeIconGoods.NORMAL, type_icongoods_show.item, data, TypeIconGoodsSize.M)
	self.pIconRes:setIconIsCanTouched(false)
    --按钮
	self.pBtnPlus = getSepButtonOfContainer(self.pLyBtnPlus, TypeSepBtn.PLUS)	
	self.pBtnPlus:onMViewClicked(handler(self, self.onPlusBtnClicked))
end

-- 修改控件内容或者是刷新控件数据
function ItemWareMaterial:updateViews(  )
	-- body
	if not self._nResId then
		return
	end
	local tresdata = getItemResourceData(self._nResId)
	if tresdata then
		local warehousedata = Player:getBuildData():getBuildById(e_build_ids.store)
		local playerinfo = Player:getPlayerInfo()		
		local nNum = Player:getBuildData():getSuburbNumById(self._nResId)
		self.pLbResName:setString(tresdata.sName..string.format(getConvertedStr(6, 10750), nNum))

		self.pIconRes:setCurData(tresdata)
		setLbTextColorByQuality(self.pLbResName, tresdata.nQuality)
		setBgQuality(self.pIconRes.pLayBgQuality,tresdata.nQuality)
		if warehousedata and playerinfo then
			local lPro = warehousedata:getBaseResProNum(self._nResId)--对应资源的保护量
			local lresnum = playerinfo:getBaseResNum(self._nResId)--对应资源量
			if self._nResId == e_resdata_ids.bt then		
				--self.pProgressBar:setBarImage("ui/bar/v1_bar_lan_15.png")
				self.pLbResStatus:setString(getConvertedStr(6, 10453))
				setTextCCColor(self.pLbResStatus, _cc.pwhite)
				self.pProgressBar:setPercent(100)
				self.pProgressBar:setProgressBarText(getResourcesStr(lresnum))
			else
				if lresnum > lPro then --资源量大于保护量
					self.pLbResStatus:setString(getConvertedStr(6, 10118))
					setTextCCColor(self.pLbResStatus, _cc.yellow)
					local nLeftP = lPro/lresnum*100
					local nRightP = (1-lPro/lresnum)*100
					self.pProgressBar:setPercent(nLeftP, nRightP)
					--self.pProgressBar:setBarImage("ui/bar/v1_bar_yellow_15.png")
					
				else
					self.pLbResStatus:setString(getConvertedStr(6, 10449))
					setTextCCColor(self.pLbResStatus, _cc.green)
					self.pProgressBar:setPercent(lresnum/lPro*100, 0)					
					--self.pProgressBar:setBarImage("ui/bar/v1_bar_lan_15.png")
				end
				self.pProgressBar:setProgressBarText(getResourcesStr(lPro).."/"..getResourcesStr(lresnum))			
			end
			
		end	
	end
end

--析构方法
function ItemWareMaterial:onItemWareMaterialDestroy(  )
	-- body
end

--增加按钮回调
function ItemWareMaterial:onPlusBtnClicked()
	--body
	local tObject = {}
	tObject.nType = e_dlg_index.getresource --dlg类型
	tObject.nIndex = self.nIdx
	sendMsg(ghd_show_dlg_by_type,tObject)
end

--绑定资源ID
function ItemWareMaterial:bindResId( _resId )
	-- body	
	self._nResId = _resId or nil
end

return ItemWareMaterial