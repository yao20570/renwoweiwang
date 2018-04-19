----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-02 14:50:50
-- Description: 洗炼铺 属性
-----------------------------------------------------
local nHiddenIndex = 4
local nBlueIndex = 2
local nPurpleIndex = 3

local MCommonView = require("app.common.MCommonView")
local MImgLabel = require("app.common.button.MImgLabel")
local ItemRefineAttr = class("ItemRefineAttr", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--nAttrIndex 属性下标
function ItemRefineAttr:ctor( nAttrIndex )
	self.nAttrIndex = nAttrIndex
	--解析文件
	parseView("item_refine_attr", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemRefineAttr:onParseViewCallback( pView )
	self.pView = pView
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemRefineAttr", handler(self, self.onItemRefineAttrDestroy))
end

-- 析构方法
function ItemRefineAttr:onItemRefineAttrDestroy(  )
    self:onPause()
end

function ItemRefineAttr:regMsgs(  )
end

function ItemRefineAttr:unregMsgs(  )
end

function ItemRefineAttr:onResume(  )
	self:regMsgs()
end

function ItemRefineAttr:onPause(  )
	self:unregMsgs()
end

function ItemRefineAttr:setupViews(  )
	self.pLayBg = self:findViewByName("lay_bg")
	self.pLayIcon = self:findViewByName("lay_icon")
	-- self.pTxtNull = self:findViewByName("lay_null")
	-- setTextCCColor(self.pTxtNull, _cc.red)
	-- self.pTxtNull:setString(getConvertedStr(3, 10290))
	self.pTxtLock = self:findViewByName("txt_lock")
	self.pImgLock = self:findViewByName("img_lock")

	local tConTable = {}
	local tLabel = {
	 {"0",getC3B(_cc.white)},
	 {"+0",getC3B(_cc.green)},
	}
	tConTable.tLabel = tLabel
	self.pGroupTxtAttr = createGroupText(tConTable)
	self.pGroupTxtAttr:setAnchorPoint(0.5, 1)
	self.pGroupTxtAttr:setPosition(45, -40)
	self.pView:addView(self.pGroupTxtAttr)

	self.pLayStarLv = self:findViewByName("lay_star_lv")
	self.pImgLabel = MImgLabel.new({text="", size = 20, parent = self.pLayStarLv})
	self.pImgLabel:setImg("#v1_img_stara2.png", 1, "left")
	self.pImgLabel:followPos("center", self.pLayStarLv:getWidth()/2, self.pLayStarLv:getHeight()/2, 0)

end

function ItemRefineAttr:updateViews(  )
	--有数据
	if self.tTrainAtbVo then
		self.pLayBg:setBackgroundImage("#v1_img_touxiangkuanglan.png")
		self.pLayIcon:setVisible(true)
		self.pImgLabel:setVisible(true)
		self.pImgLabel:showImg()
		-- self.pTxtNull:setVisible(false)
		self.pTxtLock:setVisible(false)
		self.pImgLock:setVisible(false)

		local tHeroAttData = self.tTrainAtbVo:getConfigData()
		if tHeroAttData then
			self.pGroupTxtAttr:setLabelCnCr(1, tHeroAttData.sName)
			self.pGroupTxtAttr:setLabelCnCr(2, "+" .. self.tTrainAtbVo.nAttrValue)
			self.pLayIcon:setBackgroundImage(tHeroAttData.sIcon)
			self.pLayIcon:setScale(0.8)
		end
		
		if self.tTrainAtbVo:getIsLvMax() then
			self.pImgLabel:setImg("#v1_img_stara2.png")
			self.pImgLabel:setString(getLvString(self.tTrainAtbVo.nLv) .. getConvertedStr(3, 10293))
		else
			self.pImgLabel:setImg("#v1_img_stara2b.png")
			self.pImgLabel:setString(getLvString(self.tTrainAtbVo.nLv))
		end
		self.pGroupTxtAttr:setVisible(true)

		--播放洗炼成功特效
		if self.bIsTrainSuccess then
			playUpDefenseArm(self.pLayIcon, 1.5)
		end
	--没有数据
	else
		self.pLayBg:setBackgroundImage("#v1_img_touxiangkuanghui.png")
		self.pGroupTxtAttr:setVisible(false)
		self.pImgLabel:setVisible(false)
		self.pImgLabel:hideImg()
		self.pLayIcon:setVisible(false)
		self.pImgLock:setVisible(true)
		--隐藏属性
		if self.nAttrIndex == nHiddenIndex then
			-- self.pTxtNull:setVisible(true)
			self.pTxtLock:setVisible(false)
		--非隐藏属性
		else
			-- self.pTxtNull:setVisible(false)
			self.pTxtLock:setVisible(true)

			if self.nAttrIndex == nBlueIndex then
				self.pTxtLock:setString(getConvertedStr(3, 10291))
			elseif self.nAttrIndex == nPurpleIndex then
				self.pTxtLock:setString(getConvertedStr(3, 10292))
			end
		end
	end

	--隐藏的特殊处理
	if self.nAttrIndex == nHiddenIndex then
		if self.tTrainAtbVo then
			self.pLayBg:setViewTouched(false)
		else
			self.pLayBg:setViewTouched(true)
			self.pLayBg:setIsPressedNeedScale(false)
			self.pLayBg:onMViewClicked(function ( _pView )			    
					local tObject = {
					    nType = e_dlg_index.hiddenattropendesc, --dlg类型
					}
					sendMsg(ghd_show_dlg_by_type, tObject)
			end)
		end
	end
end

--tTrainAtbVo: 属性数据
--bIsTrainSuccess：是否洗炼成功
function ItemRefineAttr:setData( tTrainAtbVo, bIsTrainSuccess)
	self.tTrainAtbVo = tTrainAtbVo
	self.bIsTrainSuccess = bIsTrainSuccess or false
	self:updateViews()
end

--点击图标回调
function ItemRefineAttr:setIconClickedHandler( nHandler )
	self.nIconClickedHandler = nHandler
end


return ItemRefineAttr


