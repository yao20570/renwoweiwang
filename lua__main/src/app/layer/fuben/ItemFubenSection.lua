--
-- Author: liangzhaowei
-- Date: 2017-03-30 16:51:47
-- 副本章节item
local ItemFubenSpecialLevel = require("app.layer.fuben.ItemFubenSpecialLevel")
local MCommonView = require("app.common.MCommonView")
local ItemFubenSection = class("ItemFubenSection", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_index
function ItemFubenSection:ctor(_index)
	-- body
	self:myInit()

	self.nIndex = _index or self.nIndex

	parseView("item_fuben_section", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemFubenSection",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemFubenSection:myInit()
	-- body
	self.nIndex = 1

	self.pData = {} --章节数据
	self.tSpecialItem = {} --特殊入口列表

end

--解析布局回调事件
function ItemFubenSection:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)


	self:setupViews()
end

--初始化控件
function ItemFubenSection:setupViews( )

	--ly
	self.pLyShowReward = self:findViewByName("ly_show_reward")
	self.pLyShowReward:setZOrder(100)
	self.pLyAcross = self:findViewByName("ly_across")

	--lb
	self.pLbTitle = self:findViewByName("lb_title")
	self.pLbSectionPlan = self:findViewByName("lb_seciton_plan")
	self.pLbSectionPlan:setZOrder(99)

	--img
	self.pImgAcross = self:findViewByName("img_across")
	self.pImgRewardBg = self:findViewByName("img_reward_bg")
	self.pImgBanner= self:findViewByName("img_banner")



	self.tImgStart = {}
	for i=1,3 do
		self.tImgStart[i] = self:findViewByName("img_start_"..i)
	end
end

-- 修改控件内容或者是刷新控件数据
function ItemFubenSection:updateViews(  )

	if not self.pData then
		return
	end


	if self.pData.sName then
		self.pLbTitle:setString(self.pData.sName)
	end

	--设置banner图
	if self.pData.sBackPic then
		self.pImgBanner:setCurrentImage(self.pData.sBackPic)
	end

	if self.pData.nS and self.pData.nS > 0 then
		self.pLyAcross:setVisible(true)
		for k,v in pairs(self.tImgStart) do
			if k > self.pData.nS then
				v:setCurrentImage("#v1_img_starb.png")
			else
				v:setCurrentImage("#v1_img_stara.png")
			end
		end
	else
		self.pLyAcross:setVisible(false)
	end

	--攻打进度
	if self.pData.nX and self.pData.nY then
		self.pLbSectionPlan:setString(getConvertedStr(5, 10014)..self.pData.nX.."/"..self.pData.nY)
	end



	self.pData.tSo = Player:getFuben():getSpecialLevelBySectionId(self.pData.nId) 


	-- 特殊关卡入口
	if self.pData.tSo and table.nums(self.pData.tSo) > 0  then
		self.pLyShowReward:setVisible(true)

		for k,v in pairs(self.pData.tSo) do
			if self.tSpecialItem[k] and  self.tSpecialItem[k].setCurData then
				self.tSpecialItem[k]:setCurData(v)
			else
				self.tSpecialItem[k] = ItemFubenSpecialLevel.new()
				self.tSpecialItem[k]:setCurData(v)
				self.tSpecialItem[k]:setPosition(15*k + (k-1)*self.tSpecialItem[k]:getWidth(),
					self.tSpecialItem[k]:getHeight()/2 - self.pImgRewardBg:getHeight()/2 )
				self.pLyShowReward:addView(self.tSpecialItem[k],100)
			end
		end
	else
		self.pLyShowReward:setVisible(false)
	end

	--移除多余的特殊入口
	if table.nums(self.tSpecialItem)> table.nums(self.pData.tSo)  then
		for k,v in pairs(self.tSpecialItem) do
			if not self.pData.tSo[k] then
				if not tolua.isnull(v) then
					v:removeFromParent(true)
					v = nil
				end
			end
		end
	end


end

--析构方法
function ItemFubenSection:onDestroy(  )
	-- body
end

--设置数据 _data
function ItemFubenSection:setCurData(_data)
	if not _data then
		return
	end

	self.pData = _data or {}

	self:updateViews()

end


--获取章节数据
function ItemFubenSection:getData()
	return self.pData
end


return ItemFubenSection