local tTable = {}

tTable["texturesPng"] = {"ui/update_bin/v1_upd_blackjianbian.png","ui/update_bin/v1_bar_loading1_lau.png","ui/update_bin/v1_ball.png","ui/update_bin/v1_bar_loading2_lau.png","ui/update_bin/v1_upd_yellow.png","ui/update_bin/v1_bg_tanc_lau.png"}
tTable["index_1"] = {
layout_bin={classname="Panel",name="layout_bin@fill_layout",parName="root",childCount="2",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="1138",width="640",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="7",anchorPointX="0",anchorPointY="0",},
}
tTable["index_2"] = {
lay_bottom={classname="Panel",name="lay_bottom",parName="layout_bin",childCount="2",ZOrder="1",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="305",width="640",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="8",anchorPointX="0",anchorPointY="0",},
lay_tmp={classname="Panel",name="lay_tmp@fill_layout",parName="layout_bin",childCount="3",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="835",width="640",x="0",y="305",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="13",anchorPointX="0",anchorPointY="0",},
}
tTable["index_3"] = {
lay_game_tips={classname="Panel",name="lay_game_tips",parName="lay_bottom",childCount="2",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="true",backGroundImage="ui/update_bin/v1_upd_blackjianbian.png",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="133",capInsetsY="32",height="115",width="640",x="0",y="190",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="71",anchorPointX="0",anchorPointY="0",},
lay_btn_upd={classname="Panel",name="lay_btn_upd",parName="lay_bottom",childCount="1",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="true",backGroundImage="ui/update_bin/v1_upd_yellow.png",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="30",capInsetsY="30",height="50",width="130",x="255",y="130",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="19",anchorPointX="0",anchorPointY="0",},
lay_temp1={classname="Panel",name="lay_temp1",parName="lay_tmp",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="50",width="640",x="0",y="788",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="14",anchorPointX="0",anchorPointY="0",},
lay_update_tips={classname="Panel",name="lay_update_tips@fill_layout",parName="lay_tmp",childCount="3",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="true",backGroundImage="ui/update_bin/v1_bg_tanc_lau.png",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="100",capInsetsY="160",height="500",width="560",x="39",y="50",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="15",anchorPointX="0",anchorPointY="0",},
lay_temp2={classname="Panel",name="lay_temp2",parName="lay_tmp",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="50",width="640",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="39",anchorPointX="0",anchorPointY="0",},
}
tTable["index_4"] = {
slider={classname="Slider",name="slider",parName="lay_game_tips",ZOrder="1",percent="50",ballNormal="ui/update_bin/v1_ball.png",barFileName="ui/update_bin/v1_bar_loading1_lau.png",progressBar="ui/update_bin/v1_bar_loading2_lau.png",scale9Enable="false",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="26",width="581",x="320",y="60",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="10",anchorPointX="0.5",anchorPointY="0.5",},
lb_tips={classname="Label",name="lb_tips",parName="lay_game_tips",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="320",y="25",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="12",anchorPointX="0.5",anchorPointY="0.5",},
lb_upd={classname="Label",name="lb_upd",parName="lay_btn_upd",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="65",y="25",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="21",anchorPointX="0.5",anchorPointY="0.5",},
lay_update_top={classname="Panel",name="lay_update_top",parName="lay_update_tips",childCount="1",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="true",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="83",capInsetsY="0",height="59",width="560",x="0",y="441",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="16",anchorPointX="0",anchorPointY="0",},
lay_sv={classname="Panel",name="lay_sv@fill_layout",parName="lay_update_tips",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="420",width="522",x="19",y="20",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="18",anchorPointX="0",anchorPointY="0",},
lay_temp3={classname="Panel",name="lay_temp3",parName="lay_update_tips",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="20",width="560",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="40",anchorPointX="0",anchorPointY="0",},
}
tTable["index_5"] = {
lb_title={classname="Label",name="lb_title",parName="lay_update_top",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="280",y="30",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="17",anchorPointX="0.5",anchorPointY="0.5",},
}

return tTable