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
    <script type="text/javascript" src="/js/forgotPassword.js"></script>
</head>
<body>
	<div id="mainContainer" class="addVideo">
		<div id="topBar">
			<div id="navigationBar">
				<a id="navBtnPrev" class="pointer" href="login.php">
					<img src="/img/btnPrev.png" style="width: 100%; height: 100%;"/>
				</a>
				<div id="navPageTitle2">FORGOT PASSWORD</div>
			</div>
		</div>
		<div id="mainBody">
			<input type="text" placeholder="EMAIL ADDRESS" id="email" class="form-control textCommon" style="margin-top: 100px;">
			<a id="btnResetPassword" onclick="onResetPassword()" class="btnOk">
				<img src="/img/btnConfirm.png" style="width: 100%; height: 100%;"/>
			</a>
			<div class="clearboth"></div>
		</div>
	</div>
	
</body>
</html>