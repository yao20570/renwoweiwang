local tTable = {}

tTable["texturesPng"] = {"ui/p2_commmon2_sep.plist","ui/p1_commonse1.plist","icon/p1_icon_font.plist","ui/p1_commmon3_sep.plist"}
tTable["index_1"] = {
lay_arena_main={classname="Panel",name="lay_arena_main@fill_layout",parName="root",childCount="3",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="1000",width="640",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="7",anchorPointX="0",anchorPointY="0",},
}
tTable["index_2"] = {
lay_top_info={classname="Panel",name="lay_top_info",parName="lay_arena_main",childCount="12",ZOrder="1",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",backGroundImage="#v2_btn_zjm_zhanbtou.png",height="147",width="640",x="0",y="852",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="22",anchorPointX="0",anchorPointY="0",},
lay_list={classname="Panel",name="lay_list@fill_layout",parName="lay_arena_main",ZOrder="1",useMergedTexture="false",clipAble="false",backGroundScale9Enable="true",backGroundImage="#v1_bg_kelashen.png",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="22",capInsetsY="22",height="733",width="640",x="0",y="119",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="21",anchorPointX="0",anchorPointY="0",},
lay_bot={classname="Panel",name="lay_bot",parName="lay_arena_main",childCount="2",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="120",width="640",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="18",anchorPointX="0",anchorPointY="0",},
}
tTable["index_3"] = {
img_res={classname="ImageView",name="img_res",parName="lay_top_info",ZOrder="5",fileName="#v1_img_jiangzhang.png",scale9Enable="false",scale9Height="36",scale9Width="36",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="36",width="36",x="206",y="36",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="24",anchorPointX="0",anchorPointY="0.5",},
lb_res_num={classname="Label",name="lb_res_num",parName="lay_top_info",ZOrder="5",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="238",y="36",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="25",anchorPointX="0",anchorPointY="0.5",},
lb_my_rank={classname="Label",name="lb_my_rank",parName="lay_top_info",ZOrder="5",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="126",y="110",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="26",anchorPointX="0",anchorPointY="0.5",},
lb_challenge={classname="Label",name="lb_challenge",parName="lay_top_info",ZOrder="5",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="340",y="110",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="28",anchorPointX="0",anchorPointY="0.5",},
lay_icon={classname="Panel",name="lay_icon",parName="lay_top_info",ZOrder="5",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="86",width="86",x="20",y="32",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="909",anchorPointX="0",anchorPointY="0",},
img_country={classname="ImageView",name="img_country",parName="lay_top_info",ZOrder="10",fileName="#v1_img_qun.png",scale9Enable="false",scale9Height="64",scale9Width="51",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="64",width="51",x="32",y="105",visible="true",touchAble="false",flipX="false",scaleX="0.6",scaleY="0.6",opacity="255",rotation="0",tag="910",anchorPointX="0.5",anchorPointY="0.5",},
lb_level={classname="Label",name="lb_level",parName="lay_top_info",ZOrder="5",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="126",y="110",visible="false",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="911",anchorPointX="0",anchorPointY="0.5",},
lb_combat={classname="Label",name="lb_combat",parName="lay_top_info",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="126",y="73",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="912",anchorPointX="0",anchorPointY="0.5",},
lb_par={classname="Label",name="lb_par",parName="lay_top_info",ZOrder="5",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="当前拥有:",fontName="微软雅黑",fontSize="20",height="27",width="85",x="126",y="36",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="913",anchorPointX="0",anchorPointY="0.5",},
lb_cd={classname="Label",name="lb_cd",parName="lay_top_info",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="340",y="36",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="914",anchorPointX="0",anchorPointY="0.5",},
lay_increase={classname="Panel",name="lay_increase",parName="lay_top_info",ZOrder="5",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="40",width="40",x="577",y="90",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="1487",anchorPointX="0",anchorPointY="0",},
lay_close_cd={classname="Panel",name="lay_close_cd",parName="lay_top_info",ZOrder="5",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="40",width="40",x="577",y="14",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="1488",anchorPointX="0",anchorPointY="0",},
lay_btn_left={classname="Panel",name="lay_btn_left",parName="lay_bot",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="62",width="155",x="30",y="30",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="19",anchorPointX="0",anchorPointY="0",},
lay_btn_right={classname="Panel",name="lay_btn_right",parName="lay_bot",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="62",width="155",x="455",y="30",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="20",anchorPointX="0",anchorPointY="0",},
}

return tTable