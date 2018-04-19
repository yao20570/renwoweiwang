----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-17 19:59:21
-- Description: 邮件详细物品集打横显示
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local IconGoods = require("app.common.iconview.IconGoods")
local MailDetailGetItems = class("MailDetailGetItems", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--tItemList 收获物品列表 ntype 1 侦查邮件 2 采集邮件
function MailDetailGetItems:ctor( tItemList ,_nType)
	self.tItemList = tItemList
    self.nType=_nType or 1
	--解析文件
	parseView("lay_mail_get_items", handler(self, self.onParseViewCallback))
end

--解析界面回调
function MailDetailGetItems:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("MailDetailGetItems",handler(self, self.onMailDetailGetItemsDestroy))
end

-- 析构方法
function MailDetailGetItems:onMailDetailGetItemsDestroy(  )
    self:onPause()
end

function MailDetailGetItems:regMsgs(  )
end

function MailDetailGetItems:unregMsgs(  )
end

function MailDetailGetItems:onResume(  )
	self:regMsgs()
end

function MailDetailGetItems:onPause(  )
	self:unregMsgs()
end

function MailDetailGetItems:setupViews(  )
    local nIconMarginLeft = 17 --左间隔
    local nIconMarginRight = 17 --右间隔
    self.nIconWidth = 108 + nIconMarginLeft + nIconMarginRight--图标大小
	local pLayGoods = self:findViewByName("lay_content")
    self.pLbDef = self:findViewByName("lb_def")
    self.pLbDef:setVisible(false)
    setTextCCColor(self.pLbDef, _cc.pwhite)
    local sTip=""
    if self.nType==1 then 
        sTip=getConvertedStr(9, 10029)
    elseif self.nType==2 then
        sTip=getConvertedStr(9, 10030)
    elseif self.nType==3 then
        sTip=getConvertedStr(9, 10045)
    end
    self.pLbDef:setString(sTip, false)

    self.pListView=self:findViewByName("lay_item")

	-- self.pListView = MUI.MListView.new {
	-- 	viewRect   = cc.rect(0, 0, pLayGoods:getContentSize().width, 148), --148先写死
	-- 	direction  = MUI.MScrollView.DIRECTION_HORIZONTAL,
 --        itemMargin = {left =  nIconMarginLeft,
 --             right =  nIconMarginRight,
 --             top =  0,
 --             bottom =  0},
 --    }
 --    pLayGoods:addView(self.pListView)
 self.tItemPosList={}      --存放物品的位置
    for i=1,5 do
        local pLayItem=self:findViewByName("lay_item_"..i)
        pLayItem:setVisible(false)
        table.insert(self.tItemPosList,pLayItem)
    end

    -- self.tDropList = {}
end

function MailDetailGetItems:updateViews(  )
	--掉落物品
	-- local tDropList = self.tItemList or {}
    --dump(tDropList, "tDropList", 100)
    local bHad = true
    for k, v in pairs(self.tItemList) do
        if v.v > 0 then
            bHad = false 
        end
    end 
    --按品质排序
    -- table.sort( tDropList,function(a,b )
    -- -- body
    --     local tGoodA=getGoodsByTidFromDB(a.k)
    --     local tGoodB=getGoodsByTidFromDB(b.k)
    --     if tGoodA and tGoodB then
    --         return tGoodA.nQuality>tGoodB.nQuality
    --     end
    -- end )
    self.pLbDef:setVisible(bHad)
    self.pListView:setVisible(not bHad)
    if not bHad then
        local nBeginIndex=1
        local nTotalNum=5       --一行最多显示5个
        if #self.tItemList <=5 then
            nTotalNum=#self.tItemList       --少于5个时取物品总数 大于5个时就取5
        end
        if nTotalNum % 2 ==1 then
            nBeginIndex= 3 - math.floor(nTotalNum/2)
        end
        local nIndex=1
        for i=nBeginIndex,#self.tItemPosList do
            if self.tItemList[nIndex] then
                self.tItemPosList[i]:setVisible(true)
                local pTempView = self.tItemPosList[i]:findViewByName("my_item")
                if not pTempView then
                    pTempView = IconGoods.new(TypeIconGoods.HADMORE)
                    
                    pTempView:setName("my_item")
                    self.tItemPosList[i]:addView(pTempView)
                    -- centerInView(self.tItemPosList[i],pTempView)
                    pTempView:setIconScale(0.7)
                end
                local pItemData = getGoodsByTidFromDB(self.tItemList[nIndex].k)
                if pItemData then
                    pTempView:setCurData(pItemData)
                    pTempView:setMoreText(pItemData.sName)
                    pTempView:setMoreTextColor(_cc.pwhite)
                end
                pTempView:setNumber(self.tItemList[nIndex].v)
                nIndex=nIndex+1
            end
            
        end

        self.pListView:setPositionY(self.pListView:getPositionY()-25)

        if nTotalNum % 2 == 0 then       --个数为双数的时候才需要重新调整位置
             local nBegin=nTotalNum/2
             local nLeftPos=self.tItemPosList[nBegin]:getPositionX()
             local nRightPos=self.tItemPosList[nBegin +1]:getPositionX() + self.tItemPosList[nBegin +1 ]:getWidth()
             local nCenterPos=(nLeftPos + nRightPos)/2
             local nMove=self.pListView:getWidth()/2 -nCenterPos
             self.pListView:setPositionX(self.pListView:getPositionX() + nMove)

        end
    	-- local nPrevCount = #self.tDropList
    	-- self.tDropList = tDropList
    	-- if #self.tDropList <= 0 then --经测试，self.pListView:notifyDataSetChange(true)，数据为0时会出错
     --        self.pListView:removeAllItems()
     --    else        
     --        if nPrevCount ~= #tDropList then
     --            self.pListView:removeAllItems()
     --            self.pListView:setItemCount(#self.tDropList)
     --            self.pListView:setItemCallback(function ( _index, _pView )
     --                local pTempView = _pView 
     --                if pTempView == nil then
     --                    pTempView = IconGoods.new(TypeIconGoods.HADMORE)
     --                    pTempView:setScale(0.7)
     --                end
                   
     --                local pItemData = getGoodsByTidFromDB(self.tDropList[_index].k)
     --                if pItemData then
     --                    pTempView:setCurData(pItemData)
     --                    pTempView:setMoreText(pItemData.sName)
     --    				pTempView:setMoreTextColor(_cc.pwhite)
     --                end
     --                pTempView:setNumber(self.tDropList[_index].v)
     --                return pTempView
     --            end)
     --            -- 载入所有展示的item
     --            self.pListView:reload()
     --        else
     --            self.pListView:notifyDataSetChange(true)
     --        end
     --    end
     --    --小于4个时居中
     --    local nCount = #self.tDropList
     --    if nCount <= 4 then
     --    	self.pListView:setPositionX((self.pListView:getContentSize().width - self.nIconWidth * nCount) /2)
     --    else
     --    	self.pListView:setPositionX(0)
     --    end
    end
end

return MailDetailGetItems


