local tTable = {}

tTable["texturesPng"] = {"ui/p1_commmon2_sep.plist","ui/p1_commmon3_sep.plist","ui/p1_commmon1_sep.plist"}
tTable["index_1"] = {
default={classname="Panel",name="default",parName="root",childCount="2",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="330",width="560",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="7",anchorPointX="0",anchorPointY="0",},
}
tTable["index_2"] = {
lay_msg={classname="Panel",name="lay_msg",parName="default",childCount="2",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="true",backGroundImage="#v1_img_kelashen7.png",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="50",capInsetsY="50",height="130",width="542",x="9",y="190",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="11",anchorPointX="0",anchorPointY="0",},
lay_cost={classname="Panel",name="lay_cost",parName="default",childCount="3",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="true",backGroundImage="#v1_bg_kelashen.png",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="22",capInsetsY="22",height="148",width="542",x="9",y="30",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="126",anchorPointX="0",anchorPointY="0",},
}
tTable["index_3"] = {
lay_icon={classname="Panel",name="lay_icon",parName="lay_msg",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="108",width="108",x="10",y="12",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="28",anchorPointX="0",anchorPointY="0",},
lay_detail={classname="Panel",name="lay_detail",parName="lay_msg",childCount="5",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="110",width="405",x="130",y="10",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="36",anchorPointX="0",anchorPointY="0",},
lay_title={classname="Panel",name="lay_title",parName="lay_cost",childCount="1",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="true",backGroundImage="#v1_img_xiaobiaoti2.png",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="166",capInsetsY="24",height="48",width="542",x="0",y="100",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="127",anchorPointX="0",anchorPointY="0",},
lay_cost_1={classname="Panel",name="lay_cost_1",parName="lay_cost",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="50",width="200",x="30",y="25",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="129",anchorPointX="0",anchorPointY="0",},
lay_cost_2={classname="Panel",name="lay_cost_2",parName="lay_cost",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="50",width="200",x="312",y="25",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="130",anchorPointX="0",anchorPointY="0",},
}
tTable["index_4"] = {
lb_name={classname="Label",name="lb_name",parName="lay_detail",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="科技名",fontName="微软雅黑",fontSize="22",height="30",width="66",x="0",y="90",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="37",anchorPointX="0",anchorPointY="0.5",},
lb_lv={classname="Label",name="lb_lv",parName="lay_detail",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Lv.5",fontName="微软雅黑",fontSize="22",height="30",width="41",x="85",y="90",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="38",anchorPointX="0",anchorPointY="0.5",},
lb_p1={classname="Label",name="lb_p1",parName="lay_detail",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="50% -",fontName="微软雅黑",fontSize="22",height="30",width="63",x="150",y="90",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="39",anchorPointX="0",anchorPointY="0.5",},
lb_p2={classname="Label",name="lb_p2",parName="lay_detail",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="60%",fontName="微软雅黑",fontSize="22",height="30",width="46",x="220",y="90",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="40",anchorPointX="0",anchorPointY="0.5",},
lb_desc={classname="Label",name="lb_desc",parName="lay_detail",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="60",areaWidth="400",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="60",width="400",x="0",y="65",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="41",anchorPointX="0",anchorPointY="1",},
lb_title_cost={classname="Label",name="lb_title_cost",parName="lay_title",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="10",y="24",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="128",anchorPointX="0",anchorPointY="0.5",},
}

return tTable