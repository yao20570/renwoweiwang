----------------------------------------------------- 
-- author: maheng
-- updatetime: 201710-17 17:42:53
-- Description: 铁匠铺 材料显示
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ItemSmithMaterial = class("ItemSmithMaterial", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--nKind 类型
function ItemSmithMaterial:ctor( _tPosParam )
	self.tPosParam = _tPosParam
	--解析文件
	parseView("item_smith_material", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemSmithMaterial:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemSmithMaterial", handler(self, self.onItemSmithMaterialDestroy))
end

-- 析构方法
function ItemSmithMaterial:onItemSmithMaterialDestroy(  )
    self:onPause()
end

function ItemSmithMaterial:regMsgs(  )
end

function ItemSmithMaterial:unregMsgs(  )
end

function ItemSmithMaterial:onResume(  )
	self:regMsgs()
end

function ItemSmithMaterial:onPause(  )
	self:unregMsgs()
end

function ItemSmithMaterial:setupViews(  )	
	self.pLayRoot = self:findViewByName("lay_smith_material")
	self.pImgLine = self:findViewByName("img_line")
	self.pLayBot = self:findViewByName("lay_bot")
	self.pLbName = self:findViewByName("lb_name")
	setTextCCColor(self.pLbName, _cc.white)
	self.pLayIcon = self:findViewByName("lay_icon")
end

function ItemSmithMaterial:updateViews(  )
	if not self.tData then
		return
	end
	local pGood = getGoodsByTidFromDB(self.tData.nId)
	self.tShopData = getShopDataById(self.tData.nId)
	if not self.pIcon then
		self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.item, pGood, 0.8)	
		self.pIcon:setIsShowBgQualityTx(false)
	else
		self.pIcon:setCurData(pGood)
	end
	--如果该物品不能在商店购买, 弹默认提示
	if not self.tShopData then
		self.pIcon:setIconClickedCallBack(nil)
	else
		self.pIcon:setIconClickedCallBack(handler(self, self.onIconClick))
	end
	self.pLbName:setString(pGood.sName, false)

	--超出名字背景的宽时，重新设置背景宽
	
	if self.pLbName:getWidth()>self.pLayBot:getWidth() then
		local nNewWidth=self.pLbName:getWidth()+20
		local nNewPosX=self.pLayBot:getPositionX()-((nNewWidth - self.pLayBot:getWidth())/2)

		self.pLayBot:setLayoutSize(nNewWidth, self.pLayBot:getHeight())
		self.pLayBot:setPositionX(nNewPosX)
		self.pLayBot:setContentSize(cc.size(self.pLbName:getWidth()+20, self.pLayBot:getHeight()))

		self.pLbName:setPositionX(self.pLayBot:getWidth()/2)
	end


	local nId = self.tData.nId
	local nNum = self.tData.nNum
	if pGood then
		local nGoodCnt = getMyGoodsCnt(nId)
		local sColor = nil
		local tLb = nil
		if nGoodCnt >= nNum then
			sColor = _cc.green
		else
			sColor = _cc.red
		end
		local tLb = {
			{text = getResourcesStr(nGoodCnt), color = getC3B(sColor)},
			{text = "/"..getResourcesStr(nNum), color = getC3B(_cc.pwhite)},
		}
		self.pIcon:setCostStr(tLb)
	end

end

function ItemSmithMaterial:onIconClick()
	-- body
	--如果是基础资源 弹出购买资源对话框
	if self.tData.nId >= e_type_resdata.food and self.tData.nId <= e_type_resdata.iron then
		local tResData = {}
		tResData[self.tData.nId] = self.tData.nNum
		goToBuyRes(self.tData.nId,tResData)
	else
		if self.tShopData then
			--批量购买窗口				
			local tObject = {
			    nType = e_dlg_index.shopbatchbuy, --dlg类型
			    tShopBase = self.tShopData,
			}
			sendMsg(ghd_show_dlg_by_type, tObject)
		end
	end
end

--tEquipData：装备数据
function ItemSmithMaterial:setData( _tData )
	self.tData = _tData
	self:updateViews()
end

--设置位参数
function ItemSmithMaterial:setPosParam( tParam )
	-- body
	--dump(tParam, "tParam", 100)
	local nRotation = tParam[1] or 0
	
	local nX = tParam[2]
	local nY = tParam[3]

	local nLineLong = 50
	if nRotation == 0 or nRotation == 180 then
		nLineLong = 80
	end
	self.pImgLine:setLayoutSize(nLineLong, 4)
	self.pImgLine:setRotation(nRotation)--线旋转
	if nRotation ~= 90 then
		nX = nX - math.cos(math.rad(nRotation))*nLineLong
		nY = nY + math.sin(math.rad(nRotation))*nLineLong
	else
		nY = nY + 50
	end
	local noffx = 0
	local noffy = 0
	local tLinePos = nil
	if nRotation > 90 and nRotation < 270 then
		tLinePos = cc.p(0, 44)

	else
		tLinePos = cc.p(86, 44)		
	end
	if tLinePos then
		self.pImgLine:setVisible(true)
		self.pImgLine:setPosition(tLinePos)
	else
		self.pImgLine:setVisible(false)
	end

	if nRotation ~= 90 then
		nX = nX-tLinePos.x
		nY = nY-tLinePos.y
	else
		nX = nX - 44
		nY = nY - 44
	end
	self.pImgLine:setVisible(nRotation ~= 90)

	self:setPosition(cc.p(nX, nY))
end

return ItemSmithMaterial


