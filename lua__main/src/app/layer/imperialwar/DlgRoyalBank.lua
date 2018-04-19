----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-17 15:55:00
-- Description: 皇城秘库
-----------------------------------------------------
local MDialog = require("app.common.dialog.MDialog")
local ItemRoyalBankGoods = require("app.layer.imperialwar.ItemRoyalBankGoods")

local DlgRoyalBank = class("DlgRoyalBank", function()
	return MDialog.new(e_dlg_index.royalbank)
end)


function DlgRoyalBank:ctor(  )
	parseView("dlg_royal_bank", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgRoyalBank:onParseViewCallback( pView )
	self:setContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgRoyalBank",handler(self, self.onDlgRoyalBankDestroy))
end

-- 析构方法
function DlgRoyalBank:onDlgRoyalBankDestroy(  )
    self:onPause()
end

function DlgRoyalBank:regMsgs(  )
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateScore))
end

function DlgRoyalBank:unregMsgs(  )
	unregMsg(self, gud_refresh_playerinfo)
end

function DlgRoyalBank:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function DlgRoyalBank:onPause(  )
	self:unregMsgs()
end

function DlgRoyalBank:setupViews(  )
	local pTxtTitle = self:findViewByName("txt_title")
	pTxtTitle:setString(getConvertedStr(3, 10947))
	local pImgClose = self:findViewByName("img_close")
	--层点击
	pImgClose:setViewTouched(true)
	pImgClose:setIsPressedNeedScale(false)
	pImgClose:setIsPressedNeedColor(true)
	pImgClose:onMViewClicked(function ( _pView )
	    self:closeDlg(false)
	end)

	self.pTxtMyScore = self:findViewByName("txt_score")
	local pTxtDesc = self:findViewByName("txt_desc")
	pTxtDesc:setString(getTextColorByConfigure(getTipsByIndex(20155)))
	local pLayView = self:findViewByName("view")

	local tRoyalShop = getAllRoyalShopData()
	local tDataList = {}
	for k,v in pairs(tRoyalShop) do
		table.insert(tDataList, v)
	end
	table.sort(tDataList, function(a, b)
		return a.id < b.id
	end)

	local nBeginX, nBeginY, nOffsetX, nOffsetY = 25, 445, 209 - 25, 200 - 445
	local nX, nY = nBeginX, nBeginY
	for i=1,#tDataList do
		local tData = tDataList[i]
		local pUi = ItemRoyalBankGoods.new()
		pUi:setData(tData)
		pLayView:addView(pUi)
		pUi:setPosition(nX, nY)
		if i%3 == 0 then
			nY = nY + nOffsetY
			nX = nBeginX
		else
			nX = nX + nOffsetX
		end
	end
end

function DlgRoyalBank:updateViews(  )
	self:updateScore()
end

function DlgRoyalBank:updateScore(  )
	local nScore = getMyGoodsCnt(e_type_resdata.royalscore)
	self.pTxtMyScore:setString(string.format("%s：<font color='#%s'>%s</font>", getCostResName(e_type_resdata.royalscore), _cc.green, nScore))
end



return DlgRoyalBank