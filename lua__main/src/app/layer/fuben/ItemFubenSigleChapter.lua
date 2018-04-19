------------------------------------------------------
-- ItemFubenSigleChapter.lua
-- Author: dengshulan
-- Date: 2017-09-01 18:16:53
-- 副本章节item
------------------------------------------------------
local ItemFubenChapterReward = require("app.layer.fuben.ItemFubenChapterReward")
local MCommonView = require("app.common.MCommonView")
local ItemFubenSigleChapter = class("ItemFubenSigleChapter", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

local tPos = {
	[1] = {{143,87}},
	[2] = {{95,87},{191,87}},
	[3] = {{53,87}, {143,87} ,{233,87}}
}

--创建函数
function ItemFubenSigleChapter:ctor(_type)
	-- body
	self:myInit(_type)

	parseView("item_fuben_chapter", handler(self, self.onParseViewCallback))


	--注册析构方法
	self:setDestroyHandler("ItemFubenSigleChapter",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemFubenSigleChapter:myInit(_type)
	self.pData = {} --数据
	self.nType = _type
	self.tSpecialItem = {} --奖励显示item
end

--解析布局回调事件
function ItemFubenSigleChapter:onParseViewCallback( pView )
    self.pMaimView = pView
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	

	self:setupViews()
end

--初始化控件
function ItemFubenSigleChapter:setupViews( )

    self.pLayBox = self.pMaimView:getChildByName("lay_star")
	-- self.pImgBox = self.pLayBox:getChildByName("img_bx")                --箱子
    self.tImgStar = {}
	for i=1,3 do                            
		self.tImgStar[i] = self.pLayBox:getChildByName("img_star_"..i)  --星星
	end

    self.pLayUnlock = self.pMaimView:getChildByName("lay_unlock")
    self.pImgBg = self.pLayUnlock:getChildByName("img_bg")              --背景
    -- self.pImgLight = self.pLayUnlock:getChildByName("img_light_kuang")  --加亮的边框
    -- self.pLbChapter = self.pLayUnlock:getChildByName("lb_chapter")      --章节序号
    self.pLbChapName = self.pLayUnlock:getChildByName("lb_chap_name")   --章节名称
    -- local pImgKuang = self.pLayUnlock:getChildByName("img_biankuang_r")
	-- pImgKuang:setFlippedX(true)

	self.pLayLocked = self.pMaimView:getChildByName("lay_locked")
 --    self.pLbLocked = self.pLayLocked:getChildByName("lb_locked")
	-- self.pLbLocked:setString(getConvertedStr(7, 10138))
	-- setTextCCColor(self.pLbLocked, _cc.red)

	self.pImgPass = self.pMaimView:getChildByName("img_pass")           --通关

	self.pLyChallenge = self.pLayUnlock:getChildByName("lay_challenge")   --获取条件图标显示层级
	self.pLyRewards = self.pLayUnlock:getChildByName("ly_rewards")        --奖励展示层
	-- ly_rewards

	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:onMViewClicked(handler(self, self.onViewClick))

end

-- 修改控件内容或者是刷新控件数据
function ItemFubenSigleChapter:updateViews(  )


	
	-- body	

	-- if self.pData.sBackPic then
	-- 	self.pImgBg:setCurrentImage(self.pData.sBackPic)
	-- end

	
	--进度
	-- if not self.pLbProgress then
	-- 	self.pLbProgress = MUI.MLabel.new({text = "", size = 20})
	-- 	self.pLayBox:addView(self.pLbProgress, 2)
	-- 	self.pLbProgress:setPosition(self.pLayBox:getWidth()/2, -10)
	-- end
	
	--已通关
	self.pImgPass:setVisible(false)

	self.pLayLocked:setVisible(not self.pData.bOpen)
	-- self.pLbChapter:setString(self.pData.nId)
	self.pLbChapName:setString(self.pData.sName)
	local tFubenData = Player:getFuben()
	if self.pData.bOpen then
		-- self.pLbProgress:setString(self.pData.nX.."/"..self.pData.nY)
		--通关
		if self.pData.nX >= self.pData.nY then
			self.pImgPass:setVisible(true)
			self.pLyRewards:setVisible(true)
			self.pLyChallenge:setVisible(false)

		else
			self.pLyChallenge:setVisible(true)
			self.pLyRewards:setVisible(false)
			self.pImgPass:setVisible(false)
		end
		self.pImgPass:setVisible(self.pData.nX >= self.pData.nY)
		self.pLyChallenge:setVisible(self.pData.nX < self.pData.nY)

		for i=1,3 do
			self.tImgStar[i]:setVisible(self.pData.nX >= 6)
		end
		if self.pData.nS then
			for k,v in pairs(self.tImgStar) do
				if k > self.pData.nS then
					v:setCurrentImage("#v2_img_star5b.png")
				else
					v:setCurrentImage("#v1_img_star5.png")
				end
			end
		end
		--是否有已开启的补给关
		local bOpenSupply = tFubenData:getHasOpenedSupply(self.pData.nId)
		-- if bOpenSupply then
		-- 	self.pImgBox:setVisible(true)
		-- else
		-- 	self.pImgBox:setVisible(false)
		-- end
		-- self.pLayUnlock:setToGray(false)
		setTextCCColor(self.pLbChapName, _cc.pwhite)
		self.pLayBox:setVisible(true)
	else
		-- self.pLayUnlock:setToGray(true)
		setTextCCColor(self.pLbChapName, _cc.gray)
		self.pLayBox:setVisible(false)
		self.pImgPass:setVisible(false)
		self.pLyRewards:setVisible(false)
		self.pLyChallenge:setVisible(false)
	end

	local tSo = Player:getFuben():getSpecialLevelBySectionId(self.pData.nId) or {}
	local nNum = table.nums(tSo)
	if  nNum > 0  then
		for k,v in ipairs(tSo) do
			local tSpecialData = v
			if self.tSpecialItem[k] and self.tSpecialItem[k].setCurData then
				self.tSpecialItem[k]:setVisible(true)
				self.tSpecialItem[k]:setCurData(tSpecialData)
				self.tSpecialItem[k]:setPosition(tPos[nNum][k][1],tPos[nNum][k][2])
			else
				self.tSpecialItem[k] = ItemFubenChapterReward.new()
				self.tSpecialItem[k]:setAnchorPoint(cc.p(0.5,0.5))
				self.tSpecialItem[k]:setCurData(tSpecialData)
				self.tSpecialItem[k]:setPosition(tPos[nNum][k][1],tPos[nNum][k][2])
				self.pLyRewards:addView(self.tSpecialItem[k])
			end
		end
	end

	--移除多余的特殊入口
	if table.nums(self.tSpecialItem) > table.nums(tSo)  then
		for k,v in pairs(self.tSpecialItem) do
			if not tSo[k] then
				if not tolua.isnull(v) then
					v:setVisible(false)
				end
			end
		end
	end

end

--点击回调
function ItemFubenSigleChapter:onViewClick(pView)
	-- body
	if not pView then
		return
	end

	
	if self.pData and self.pData.nId and self.pData.bOpen then
		if self.nType then
			self.pCircleList:jumpToNearly(self.nIndex)
		else
			local dlg = getDlgByType(e_dlg_index.fubenlayer)
			if dlg then
				closeDlgByType(e_dlg_index.fubenlayer, false)
			end
			local tObject = {}
			-- tObject.tData = self.pData.nId --章节id
			-- tObject.nType = e_dlg_index.fubenmap --dlg类型
			-- sendMsg(ghd_show_dlg_by_type,tObject)
			tObject.tData = Player:getFuben():getSectionById(self.pData.nId)
			sendMsg(ghd_refresh_fuben_level, tObject) --通知刷新界面
		end
	else
		local str = Player:getFuben():getLockedTip(self.pData.nId-1, self.pData.nOpen)
		TOAST(str)
	end
end

--析构方法
function ItemFubenSigleChapter:onDestroy(  )
	-- body
end

--设置数据 _data
function ItemFubenSigleChapter:setCurData(_tData, _nIndex, _pCircleList)
	self.pData = _tData or {}
	self.nIndex = _nIndex
	self.pCircleList = _pCircleList
	self:updateViews()

end

return ItemFubenSigleChapter