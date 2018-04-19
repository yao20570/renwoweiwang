----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-15 09:45:00
-- Description: 城池战科技商品
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local TacticsGoods = class("TacticsGoods", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function TacticsGoods:ctor(  )
	--解析文件
	parseView("layout_tactics_goods", handler(self, self.onParseViewCallback))
end

--解析界面回调
function TacticsGoods:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("TacticsGoods", handler(self, self.onTacticsGoodsDestroy))
end

-- 析构方法
function TacticsGoods:onTacticsGoodsDestroy(  )
    self:onPause()
end

function TacticsGoods:regMsgs(  )
end

function TacticsGoods:unregMsgs(  )
end

function TacticsGoods:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function TacticsGoods:onPause(  )
	self:unregMsgs()
end

function TacticsGoods:setupViews(  )
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pTxtCd = self:findViewByName("txt_cd")
	local pLayBtnBuy = self:findViewByName("lay_btn_buy")
	self.pLayBtnBuy = pLayBtnBuy
	local pBtnBuy = getCommonButtonOfContainer(pLayBtnBuy,TypeCommonBtn.XL_BLUE2, "")
	self.pBtnBuy = pBtnBuy
	setMCommonBtnScale(self.pLayBtnBuy, self.pBtnBuy, 0.9)
	local tBtnTable = {}
	tBtnTable.img = getCostResImg(e_resdata_ids.ybao)
	--文本
	tBtnTable.tLabel = {
		{"",getC3B(_cc.white)},
	}
	tBtnTable.awayH = -35 -- 扩展内容层离存放按钮的父层 的高度 (默认self.nAwayH 的高度)
	pBtnBuy:setBtnExText(tBtnTable, false)
	pBtnBuy:onCommonBtnClicked(handler(self, self.onBuyClicked))

	--层点击
	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:setIsPressedNeedColor(false)
	self:onMViewClicked(handler(self, self.onBuyClicked))
end

function TacticsGoods:updateViews(  )
	if not self.tData then
		return
	end
	self.pTechIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.HADMORE, type_icongoods_show.tech, self.tData, TypeIconGoodsSize.M)
	self.pTechIcon:setMoreTextSize(24)
	self.pTechIcon:setIconIsCanTouched(false)
	self.pBtnBuy:setExTextLbCnCr(1, self.tData.nCost)

	--文本颜色
	local nId = self.tData.sTid
	if nId == e_tech_type.addHurt or
		nId == e_tech_type.subHurt or
		nId == e_tech_type.attack then
		setTextCCColor(self.pTxtCd, _cc.green)
		self.pTxtCd:setString(getConvertedStr(3, 10916))
	elseif nId == e_tech_type.fire or
		nId == e_tech_type.rain then
		setTextCCColor(self.pTxtCd, _cc.red)
	end
	
	--战争Vo
	local tImperialWarVo = self.tImperialWarVo
	if tImperialWarVo then
		if nId == e_tech_type.addHurt or
			nId == e_tech_type.subHurt or
			nId == e_tech_type.attack then
			--设置是否有效
			local bIsEffect = tImperialWarVo:getTechIsEffect(nId)
			self:setIsEffect(bIsEffect)
		elseif nId == e_tech_type.fire or
			nId == e_tech_type.rain then
			--更新cd
			self:updateCd()
		end
		-- self:updateUsed() --更新买的数据
	end
end

function TacticsGoods:setData( tData, tImperialWarVo)
	self.tData = tData
	self.tImperialWarVo = tImperialWarVo
	self.nLimit = nil
	self.nCanUse = 0
	if self.tData then
		self.nLimit = self.tData.nLimit
	end
	self:updateViews()
end

--更新cd
function TacticsGoods:updateCd( )
	if not self.tData then
		return
	end
	if not self.tImperialWarVo then
		return
	end

	local nCd = nil
	local nId = self.tData.sTid
	if nId == e_tech_type.fire then
		--当玩家为防守方时，火攻战术下方显示“进攻方可使用”
		if self.nDefCountry == Player:getPlayerInfo().nInfluence then
			self.pBtnBuy:setExTextVisiable(false)
			self.pLayBtnBuy:setVisible(false)
			self.pTxtCd:setVisible(true)
			self.pTxtCd:setString(getConvertedStr(3, 10955))
			return
		else
			nCd = self.tImperialWarVo:getFireCd()
		end
	elseif nId == e_tech_type.rain then
		--当玩家为进攻方时，祈雨战术下方显示“防守方可使用”
		if self.nDefCountry ~= Player:getPlayerInfo().nInfluence then
			self.pBtnBuy:setExTextVisiable(false)
			self.pLayBtnBuy:setVisible(false)
			self.pTxtCd:setVisible(true)
			self.pTxtCd:setString(getConvertedStr(3, 10956))
			return
		else
			nCd = self.tImperialWarVo:getPRainCd()
		end
	end
	if nCd then
		if nCd > 0 then
			self.pBtnBuy:setExTextVisiable(false)
			self.pLayBtnBuy:setVisible(false)
			self.pTxtCd:setVisible(true)
			self.pTxtCd:setString(getTimeLongStr(nCd,false,false))
		else
			self.pBtnBuy:setExTextVisiable(true)
			self.pLayBtnBuy:setVisible(true)
			self.pTxtCd:setVisible(false)
		end
	end
end

--更新是否有效
function TacticsGoods:setIsEffect( bIsEffect )
	if bIsEffect then
		self.pBtnBuy:setExTextVisiable(false)
		self.pLayBtnBuy:setVisible(false)
		self.pTxtCd:setVisible(true)
	else
		self.pBtnBuy:setExTextVisiable(true)
		self.pLayBtnBuy:setVisible(true)
		self.pTxtCd:setVisible(false)
	end
end

--更新使用次数
function TacticsGoods:updateUsed(  )
	if not self.tData or not self.tImperialWarVo or not self.nLimit then
		return
	end
	--有购买次数
	local nId = self.tData.sTid
	local nUsed = self.tImperialWarVo:getTechBuyed(nId)
	self.nCanUse = math.max(self.nLimit - nUsed, 0)
	self.pTechIcon:setTechUsedStr(string.format("%s/%s", self.nCanUse, self.nLimit))
end

--设置是否次数
function TacticsGoods:onBuyClicked(  )
	if not self.pLayBtnBuy:isVisible() then
		return
	end

	if not self.tData then
		return
	end

	local DlgAlert = require("app.common.dialog.DlgAlert")
    local pDlg = getDlgByType(e_dlg_index.alert)
    if(not pDlg) then
        pDlg = DlgAlert.new(e_dlg_index.alert)
    end
    pDlg:setTitle(getConvertedStr(3, 10933))
    local TacticsBuyLayer = require("app.layer.imperialwar.TacticsBuyLayer")
    local pTactcsLayer = TacticsBuyLayer.new(self.tData.sTid, self.tImperialWarVo)
    pDlg:addContentView(pTactcsLayer)
    pDlg:setBtnLayHeight(0)
    local pBtn = pDlg:getOnlyConfirmButton(TypeCommonBtn.L_YELLOW, getConvertedStr(3, 10933))
    local tConTable = {}
	tConTable.img = getCostResImg(e_type_resdata.money)
	--文本
	local tLabel = {
	 {self.tData.nCost,getC3B(_cc.white)},
	}
	tConTable.tLabel = tLabel
	pBtn:setBtnExText(tConTable)
	
    pDlg:setRightHandler(function (  )
        --先关闭当前框
        pDlg:closeDlg(false)
        
        if Player:getPlayerInfo().nMoney >= tonumber(self.tData.nCost or 0) then
        	local nSysCityId = Player:getImperWarData():getCurrImperialWarId()
            SocketManager:sendMsg("reqImperWarTech", {self.tData.sTid, nSysCityId}, nil)
        else
            TOAST(getConvertedStr(1, 10160))--黄金不足        
            local pDlg, bNew = getDlgByType(e_dlg_index.alert)
            if(not pDlg) then
                pDlg = DlgAlert.new(e_dlg_index.alert)
            end
            pDlg:setTitle(getConvertedStr(3, 10091))
            pDlg:setContent(getConvertedStr(6, 10081))
            local btn = pDlg:getRightButton()
            btn:updateBtnText(getConvertedStr(6, 10291))
            btn:updateBtnType(TypeCommonBtn.L_YELLOW)
            pDlg:setRightHandler(function (  )            
                local tObject = {}
                tObject.nType = e_dlg_index.dlgrecharge --dlg类型
                sendMsg(ghd_show_dlg_by_type,tObject)   
            end)
            pDlg:showDlg(bNew)   
        end

    end)
    pDlg:showDlg(bNew)
end

--设置当前防守方
function TacticsGoods:setDefCountry( nCountry )
	self.nDefCountry = nCountry
	self:updateCd()
end

return TacticsGoods


