<!-- 
 * Globo Rojo open source application
 *
 *  Copyright © 2013, 2014 by Mauro Magnasco <mauro.magnasco@gmail.com>
 *
 *  Licensed under GNU General Public License 2.0 or later.
 *  Some rights reserved. See COPYING, AUTHORS.
 *
 * @license GPL-2.0+ <http://spdx.org/licenses/GPL-2.0+>
 -->
<!DOCTYPE html>
<!--[if IE 8]><html lang="en" id="ie8" class="lt-ie9 lt-ie10"> <![endif]-->
<!--[if IE 9]><html lang="en" id="ie9" class="gt-ie8 lt-ie10"> <![endif]-->
<!--[if gt IE 9]><!-->
<html lang="en"> <!--<![endif]-->
<head>
    <?php require_once("./common/config.php"); ?>
    <?php require_once("./common/DB_Connection.php"); ?>
    <?php require_once("./common/header.php"); ?>
    <?php require_once("./common/functions.php"); ?>
    <?php require_once("./common/asset.php"); ?>
    <script type="text/javascript" src="/js/search.js"></script>
    <script type="text/javascript" src="/js/jquery.cookie.js"></script>
    <?php
	    if( RB_isLogin() ){ $isLogin = "Y";	}
	    else{ $isLogin = "N"; }
	    if( isset( $_GET['h'] ) && $_GET['h'] != "" ){
			$hashtag = base64_decode( $_GET['h'] );
		}     
    ?>    
</head>
<body>
	<div id="mainContainer" style="overflow:hidden;">
		<div id="redTooltip" class="redSelected searchSearchMode" style="z-index: 1000;display:none;">
			<span></span>
			<img src="/img/btnRedClose.png" style="height:100%;right:0px;top:0px;position:absolute;cursor:pointer;" onclick="onHideTooltip()"/>
		</div>
		<?php require_once("lightMenu.php"); ?>
		<div class="menuListBackground clone" onclick="onMenu()"></div>	
		<div id="topBar">
			<div id="searchNavigation">
				<input type="hidden" id="watchMode" value="S"/>
				<a id="searchSearchLeftNavIcon" class="pointer" onclick="onClickWatch(this)">
					<img src="/img/btnSmallCircle.png" style="width: 100%; height: 100%;"/>
				</a>
				<div id="searchSearchBodyNavIcon">
					<input type="text" id="searchTxtKeyword" placeholder="Search #Category or @username" value="<?php echo $hashtag;?>" onkeyup="onEnterKeyword()" onblur="hideCategoryMenu()" onfocus="onEnterKeyword()"/>
					
				</div>
				<div id="searchSearchBodyBtnSearch" class="pointer" onclick="onClickSearch()">
					<i class="icon-search"></i>
				</div>
				<div id="searchSearchBodyBtnDelete" class="pointer" onclick="onClearSearchWord()">
					<img src="/img/iconDelete.png" style="width:100%;height:100%;"/>
				</div>				
				<div id="homeRightNavIcon" class="pointer" onclick="onMenu()">
					<img src="/img/btnMenu<?php if( $isNotification == "Y") echo 'Red';?>.png" style="width:100%;height:100%;"/>
				</div>				
			</div>
			<div id="searchPeriodModeList" style="display: none;">
				<div id="searchPeriodModeItem">
				Day
				</div>
				<div id="searchPeriodModeItem">
				Week
				</div>
				<div id="searchPeriodModeItem" class="searchPeriodModeItemSelected">
				Always
				</div>											
			</div>
			<div class="periodListBackground clone" id="periodListBackground" onclick="onHidePeriodListBackground()"></div>
			<div id="searchSearchMode">
				<div style="position:absolute; left:0px; right:50%; top: 0px; height: 40px;">
					<div id="searchModeHashtag" class="pointer searchModeItem greySelected" onclick="onClickSearchMode(this)">#Hashtag</div>
					<!-- id="searchModeHashtagList" class="pointer searchModeItem" onclick="onClickSearchMode(this)"></div -->
				</div>
				<div style="position:absolute; left:50%; right:0; top: 0px; height: 40px;">
					<!-- div id="searchModeHashtagMosaic" class="pointer searchModeItem greySelected" onclick="onClickSearchMode(this)"></div -->
					<div id="searchModeUsername" class="pointer searchModeItem" onclick="onClickSearchMode(this)">@Username</div>				
				</div>
				<div id="searchModeVideo" class="pointer searchModeItem" onclick="onChangeSearchMode( this )"></div>
				<div class="clearboth"></div>
			</div>
			<div id="searchOrderMode">
				<div id="searchOrderModeItem" class="pointer" style="position:relative;">Date<div style="position:absolute; right: 20px; bottom: 0px;" sort="1" onclick="onClickUserSort(this)">&#9660;</div></div>
				<div id="searchOrderModeItem" class="pointer" style="position:relative;">Score<div style="position:absolute; right: 20px; bottom: 0px;" sort="1" onclick="onShowScoreMode(this)">&#9660;</div></div>
				<div id="searchOrderModeItem" class="pointer" style="position:relative;">Meri.to<div style="position:absolute; right: 20px; bottom: 0px;" sort="1" onclick="onClickUserSort(this)">&#9660;</div></div>
				<div class="clearboth"></div>
			</div>
			<div id="searchUserOrderMode">
				<div id="searchUserOrderModeItem" class="pointer" style="position:relative;">Date<div style="position:absolute; right: 20px; bottom: 0px;" sort="1" onclick="onClickUserSort(this)">&#9660;</div></div>
				<div id="searchUserOrderModeItem" class="pointer" style="position:relative;">A - Z<div style="position:absolute; right: 20px; bottom: 0px;" sort="2" onclick="onClickUserSort(this)">&#9650;</div></div>
				<div id="searchUserOrderModeItem" class="pointer" style="position:relative;">Meri.to<div style="position:absolute; right: 20px; bottom: 0px;" sort="1" onclick="onClickUserSort(this)">&#9660;</div></div>
				<div class="clearboth"></div>
			</div>			
			<div id="searchVideoList">

			</div>
			<div id="searchUserList" style="display:none;">
			
			</div>
			<div id="loadingContainer" style="display:none;">
				<img id="imgLoading" src="/img/loading.png"/>
			</div>
			<a id="btnAddVideo" href="addVideo.php">
				
			</a>									
		</div>
		<div class="textCommon1 hashtag2" id="defaultCategory1" style="display:none;position:absolute;z-index: 100;background: #b3b3b3; color: #FFF;cursor: pointer;margin-left:0px;text-align:center;">USE "DEFAULT CAT" INSTEAD</div>
		
		<div id="searchBackground"></div> 
	</div>
	<?php require_once("clone.php"); ?>
</body>
</html>