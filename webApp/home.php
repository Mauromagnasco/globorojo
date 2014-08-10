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
<?php
	if(isset($_COOKIE['RB_USER'])){
		header("location: search.php");
	}else{
		header("location: login.php");
	}
	exit();
?>
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
    <script type="text/javascript" src="/js/home.js"></script>
</head>

<body>
	<div id="mainContainer" style="overflow:hidden;">
		<?php require_once("lightMenu.php"); ?>
		<div class="menuListBackground clone" onclick="onMenu()"></div>
		<div id="topBar" >
			<div id="homeNavigation" class="zIndex100">
				<div id="homeLeftNavIcon" class="pointer" onclick="onGoProfile();">
					<img src="/img/btnProfile.png" style="width: 100%; height: 100%;"/>
				</div>
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
			<div id="homeOrderMode" class="zIndex100">
				<div id="homeOrderModeItem" class="pointer">Date</div>
				<div id="homeOrderModeItem" class="pointer">Score</div>
				<div id="homeOrderModeItem" class="pointer">Meri.to</div>
				<div class="clearboth"></div>
			</div>
			<div id="homeVideoList">
				
			</div>
			<a id="btnAddVideo" href="addVideo.php">
				
			</a>
			
		</div>
	</div>
	<?php require_once("clone.php"); ?>
</body>
</html>