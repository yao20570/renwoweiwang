local tTable = {}

tTable["texturesPng"] = {"ui/p1_commmon2_sep.plist","ui/bar/v1_bar_b1.png","ui/p1_button1.plist","ui/p1_commmon1_sep.plist"}
tTable["index_1"] = {
default={classname="Panel",name="default",parName="root",childCount="6",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="400",width="560",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="46",anchorPointX="0",anchorPointY="0",},
}
tTable["index_2"] = {
lay_top={classname="Panel",name="lay_top",parName="default",childCount="7",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="true",backGroundImage="#v1_img_kelashen6.png",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="63",capInsetsY="65",height="130",width="532",x="14",y="260",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="47",anchorPointX="0",anchorPointY="0",},
lay_reduce={classname="Panel",name="lay_reduce",parName="default",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",backGroundImage="#v1_btn_reduce.png",height="34",width="34",x="19",y="32",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="744",anchorPointX="0",anchorPointY="0",},
lay_increase={classname="Panel",name="lay_increase",parName="default",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",backGroundImage="#v1_btn_increase.png",height="34",width="34",x="400",y="32",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="745",anchorPointX="0",anchorPointY="0",},
lay_bar_select={classname="Panel",name="lay_bar_select",parName="default",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="18",width="300",x="76",y="40",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="746",anchorPointX="0",anchorPointY="0",},
lay_num={classname="Panel",name="lay_num",parName="default",childCount="1",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="true",backGroundImage="#v1_img_kelashen9.png",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="15",capInsetsY="15",height="30",width="90",x="450",y="34",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="747",anchorPointX="0",anchorPointY="0",},
lay_goods_list={classname="Panel",name="lay_goods_list",parName="default",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="170",width="480",x="40",y="78",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="900",anchorPointX="0",anchorPointY="0",},
}
tTable["index_3"] = {
lb_name={classname="Label",name="lb_name",parName="lay_top",ZOrder="1",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="王宫",fontName="微软雅黑",fontSize="22",height="30",width="44",x="180",y="85",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="49",anchorPointX="0",anchorPointY="0.5",},
lb_lv={classname="Label",name="lb_lv",parName="lay_top",ZOrder="1",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Lv.6 - Lv.7",fontName="微软雅黑",fontSize="22",height="30",width="106",x="230",y="85",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="50",anchorPointX="0",anchorPointY="0.5",},
ly_btn={classname="Panel",name="ly_btn",parName="lay_top",ZOrder="1",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="50",width="130",x="387",y="20",visible="false",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="256",anchorPointX="0",anchorPointY="0",},
ly_bar={classname="Panel",name="ly_bar",parName="lay_top",ZOrder="1",useMergedTexture="false",clipAble="false",backGroundScale9Enable="true",backGroundImage="ui/bar/v1_bar_b1.png",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="45",capInsetsY="9",height="18",width="216",x="180",y="15",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="524",anchorPointX="0",anchorPointY="0",},
lb_time={classname="Label",name="lb_time",parName="lay_top",ZOrder="2",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="18",height="24",width="87",x="180",y="48",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="51",anchorPointX="0",anchorPointY="0.5",},
img_top_bg={classname="ImageView",name="img_top_bg",parName="lay_top",ZOrder="0",fileName="#v1_img_kelashen6_b.png",scale9Enable="true",scale9Height="130",scale9Width="350",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="175",capInsetsY="9",height="130",width="350",x="0",y="0",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="623",anchorPointX="0",anchorPointY="0",},
lay_tar_icon={classname="Panel",name="lay_tar_icon",parName="lay_top",ZOrder="10",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="108",width="108",x="37",y="13",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="824",anchorPointX="0",anchorPointY="0",},
lb_item_num={classname="Label",name="lb_item_num",parName="lay_num",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="45",y="15",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="748",anchorPointX="0.5",anchorPointY="0.5",},
}

return tTable