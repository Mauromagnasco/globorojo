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
    <script type="text/javascript" src="/js/video.js"></script>
    <?php
    	$id = $_GET['id'];
    	$id = base64_decode( $id );    
	    if( RB_isLogin() ){ $isLogin = "Y";	}
	    else{ $isLogin = "N"; }     
    ?>
</head>
<body>
	<input type="hidden" id="currentVideoId" value="<?php echo $id;?>"/>
	<div id="mainContainer">
		<?php require_once("lightMenu.php"); ?>
		<div class="menuListBackground clone" onclick="onMenu()"></div>	
		<div id="topBar">
			<div id="homeNavigation" class="zIndex100">
				<a id="navBtnPrev" class="pointer" onclick="onBack();">
					<img src="/img/btnPrev.png" style="width: 100%; height: 100%;"/>
				</a>
				<div id="homeBodyNavIcon" class="pointer" onclick="window.location.href='search.php';">
					Search #tag or @username
				</div>
				<div id="homeBodyBtnSearch" class="pointer" onclick="window.location.href='search.php';">
					<i class="icon-search"></i>
				</div>
				<div id="homeRightNavIcon" class="pointer" onclick="onMenu()">
					<img src="/img/btnMenu<?php if( $isNotification == "Y") echo 'Red';?>.png" style="width:100%;height:100%;"/>
				</div>
			</div>
			<div id="videoVideoList">
				
			</div>			
		</div>
	</div>
	<?php require_once("clone.php"); ?>
</body>
</html>