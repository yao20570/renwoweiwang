----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-16 14:15:00
-- Description: 战斗战场武将
-----------------------------------------------------

local MDialog = require("app.common.dialog.MDialog")
local ItemImperialWarHero = require("app.layer.imperialwar.ItemImperialWarHero")
local DlgImperialWarHero = class("DlgImperialWarHero", function()
	return MDialog.new(e_dlg_index.imperialwarhero)
end)

function DlgImperialWarHero:ctor(  )
	parseView("dlg_imperial_war_hero", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgImperialWarHero:onParseViewCallback( pView )
	self:setContentView(pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgImperialWarHero",handler(self, self.onDlgImperialWarHeroDestroy))
end

-- 析构方法
function DlgImperialWarHero:onDlgImperialWarHeroDestroy(  )
    self:onPause()
end

function DlgImperialWarHero:regMsgs(  )
	-- -- 大地图视图移动
	-- regMsg(self, ghd_world_view_pos_msg, handler(self, self.onWorldViewPosMsg))

	-- -- 区域视图点刷新
	-- regMsg(self, gud_world_block_dots_msg, handler(self, self.onWorldBlockDotsMsg))
end

function DlgImperialWarHero:unregMsgs(  )
	-- unregMsg(self, ghd_world_view_pos_msg)
	-- unregMsg(self, gud_world_block_dots_msg)
end

function DlgImperialWarHero:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function DlgImperialWarHero:onPause(  )
	self:unregMsgs()
end

function DlgImperialWarHero:setData( tHeroList )
	self.tHeroList = tHeroList
	self:updateViews()
end

function DlgImperialWarHero:setupViews(  )
	local pTxtTitle = self:findViewByName("txt_title")
	pTxtTitle:setString(getConvertedStr(3, 10923))
	local pImgClose = self:findViewByName("img_close")
	--层点击
	pImgClose:setViewTouched(true)
	pImgClose:setIsPressedNeedScale(false)
	pImgClose:setIsPressedNeedColor(true)
	pImgClose:onMViewClicked(function ( _pView )
	    self:closeDlg(false)
	end)

	local pLayTop = self:findViewByName("lay_top")
	local HomeBuffsLayer = require("app.layer.home.HomeBuffsLayer")
	--增益buffs显示
    local pHomeBuffsLayer = HomeBuffsLayer.new()
    pHomeBuffsLayer:setPosition(20, 12)
    pLayTop:addView(pHomeBuffsLayer)

    self.pLayMiddle = self:findViewByName("lay_middle")
    local pLayResur = self:findViewByName("lay_btn_resur")
    local pBtnSubmit = getCommonButtonOfContainer(pLayResur,TypeCommonBtn.L_BLUE, getConvertedStr(3, 10381))
	pBtnSubmit:onCommonBtnClicked(handler(self, self.onSubmitClicked))
end

function DlgImperialWarHero:updateViews(  )
	if not self.tHeroList then
		return
	end

	if not self.pListView then
	    self:createListView(#self.tHeroList)
	else
	    self.pListView:notifyDataSetChange(true, #tHeroList)
	end
end

--创建listView
function DlgImperialWarHero:createListView(_count)
	local pSize = self.pLayMiddle:getContentSize()
    self.pListView = MUI.MListView.new {
        viewRect   = cc.rect(0, 0, pSize.width, pSize.height),
        direction  = MUI.MScrollView.DIRECTION_VERTICAL,
    }
    
    local pContentLayer = self.pLayMiddle
    pContentLayer:addView(self.pListView)
    centerInView(pContentLayer, self.pListView )

    --列表数据
    self.pListView:setItemCount(_count)
    self.pListView:setItemCallback(function ( _index, _pView ) 
        local pItemData = self.tHeroList[_index]
        local pTempView = _pView
        if pTempView == nil then
            pTempView   = ItemImperialWarHero.new()
        end
        pTempView:setData(pItemData, self.nCurrTab)
        return pTempView
    end)
    self.pListView:reload()
end

function DlgImperialWarHero:onSubmitClicked( )
	closeDlgByType(e_dlg_index.imperialwarhero, false)
end

return DlgImperialWarHero