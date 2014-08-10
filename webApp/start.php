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
    <script type="text/javascript" src="/js/start.js"></script>
</head>
<body>
	<div id="mainContainer" class="start">
		<div id="mainBody">
			<br/>
			<br/>
			<br/>
			<br/>
			<div class="labelInfo">BETA TESTERS REQUIREMENT:</div>
			<div class="inputItem">
				<input type="text" id="referalCode" class="form-control textCommon" placeholder="REFERRAL CODE"/>
				<a class="btnClearText" onclick="onClearText(this)"><img style="width:100%;height:100%;" src="/img/btnDeleteText.png"/></a>
			</div>
			<div id="btnSignUp" class="btnStart pointer">SIGN UP</div>
			<br/>
			<img id="imgLogo" src="/img/logo.png"/>
			<br/><br/><br/>
			<div class="labelInfo">If you already have an account</div>
			<br/>
			<div id="btnLogin" class="btnStart pointer">LOGIN</div>
			<!-- div id="btnSearch" onclick="window.location.href='search.php';" class="btnStart pointer">SEARCH</div -->
			<br>
		</div>
		
	</div>
	
</body>
</html>