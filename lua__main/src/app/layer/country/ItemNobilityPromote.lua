----------------------------------------------------- 
-- author: maheng
-- updatetime: 2017-06-12 11:20:14
-- Description:爵位升级资源
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local ItemNobilityPromote = class("ItemNobilityPromote", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function ItemNobilityPromote:ctor(  )
	-- body
	self:myInit()
	parseView("item_nobility_promote", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemNobilityPromote:myInit(  )
	-- body
	self.nNum = 0
	self.pCurData = nil
	self.isEnough = false
end

--解析布局回调事件
function ItemNobilityPromote:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemNobilityPromote",handler(self, self.onItemNobilityPromoteDestroy))
end

--初始化控件
function ItemNobilityPromote:setupViews( )
	-- body
	self.pImgRes = self:findViewByName("img_res")
	self.pImgRes:setScale(0.3)
	self.pImgLine = self:findViewByName("img_line")

	self.pLbResInfo = self:findViewByName("lb_resinfo")

	self.pImgFlag = self:findViewByName("img_flag")
	self.pLayBtn = self:findViewByName("lay_btn")
	self.pBtn =	getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.M_BLUE, getConvertedStr(6, 10397))
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))
end

-- 修改控件内容或者是刷新控件数据
function ItemNobilityPromote:updateViews( )
	-- body
	if self.pCurData then
		local myCnt = getMyGoodsCnt(self.pCurData.sTid)
		local str = {
			{color = _cc.pwhite, text=self.pCurData.sName.."  "},
			{color = _cc.pwhite, text=getResourcesStr(myCnt)},
			{color = _cc.pwhite, text="/"..getResourcesStr(self.nNum)},
		}		
		if self.nNum > myCnt then
			self.pImgFlag:setCurrentImage("#v1_img_zybz.png")
			self.isEnough = false
			self.pBtn:setVisible(true)
			str[2].color = _cc.red
		else
			self.pImgFlag:setCurrentImage("#v1_img_zycz.png")
			self.isEnough = true
			self.pBtn:setVisible(false)
			str[2].color = _cc.green
		end			
		self.pLbResInfo:setString(str, false)
		self.pImgRes:setCurrentImage(self.pCurData.sIcon)
	
	end
end

-- 析构方法
function ItemNobilityPromote:onItemNobilityPromoteDestroy(  )
	-- body
end
--
function ItemNobilityPromote:setCurData( _id, _num )
	-- body
	self.nNum = _num or self.nNum
	--print(_id)
	local tgood = getGoodsByTidFromDB(_id)	
	--dump(tgood, "tgood", 10)
	self.pCurData = tgood or self.pCurData
	self:updateViews()
end

function ItemNobilityPromote:isResEnough(  )
	-- body
	return self.isEnough
end

function ItemNobilityPromote:onBtnClicked( pView )
	-- body
	if self.pCurData then 
		local resid = self.pCurData.sTid
		if resid == e_resdata_ids.lc or resid == e_resdata_ids.yb or
			resid == e_resdata_ids.mc or resid == e_resdata_ids.bt then
			local tResList = {}
			tResList[e_resdata_ids.yb] =self.nNum
			tResList[e_resdata_ids.mc] = 0
			tResList[e_resdata_ids.lc] = 0
			tResList[e_resdata_ids.bt] = 0
			local tObject = {}	
			tObject.nType = e_dlg_index.getresource --dlg类型
			tObject.nIndex = 1
			tObject.tValue = tResList
			sendMsg(ghd_show_dlg_by_type,tObject)
		else
			local data = getShopDataById(resid)	
			--dump(data, "data", 100)
			if not data then
				TOAST(getConvertedStr(6, 10438))
				return 
			end					
			local tObject = {
			    nType = e_dlg_index.shopbatchbuy, --dlg类型
			    tShopBase = data,
			}
			sendMsg(ghd_show_dlg_by_type, tObject)
		end
	end

end
return ItemNobilityPromote


