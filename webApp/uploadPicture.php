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
	<link rel="stylesheet" href="/css/jquery.Jcrop.min.css" type="text/css" />
	<script type="text/javascript" src="/js/jquery.Jcrop.min.js"></script>	    
    <script type="text/javascript" src="/js/uploadPicture.js"></script>
</head>
<body>	
	<div id="mainContainer" class="findFriends">
		<?php require_once("lightMenu.php"); ?>
		<div class="menuListBackground clone" onclick="onMenu()"></div>			
		<div id="topBar">
			<div id="navigationBar">
				<a id="navBtnPrev" class="pointer" href="profile.php">
					<img src="/img/btnPrev.png" style="width: 100%; height: 100%;"/>
				</a>
				<div id="navPageTitle">UPLOAD PICTURE</div>
				<div id="homeRightNavIcon" class="pointer" onclick="onMenu()">
					<img src="/img/btnMenu<?php if( $isNotification == "Y") echo 'Red';?>.png" style="width:100%;height:100%;"/>
				</div>				
			</div>
		</div>
		<div id="mainBody">
			<button onclick="onProfileUploadPicture()" id="profileUploadPicture" class="form-control textCommon greySelected bordernone" style="margin-top:0px;">UPLOAD PICTURE</button>
			<form id="imageForm" method="post" enctype="multipart/form-data" action='async-uploadImage.php'>
				<input type="file" name="imageUpload" id="imageUpload" style="display:none;visibility:hidden;"/>
				<input type="hidden" name="uploadType" value="location">
				<input type="hidden" id="imagePrevDiv" value="previewPhotoImage1">
				<div id="previewPhotoImage1" class="previewImage" style="width:82%; margin: 0px auto; margin-top: 20px;">
					<img src="<?php echo NO_PROFILE_PHOTO;?>" style="width:100%;"/>
				</div>
			</form>
			
			<a onclick="onSavePicture()" class="btnOk">
				<img src="/img/btnConfirm.png" style="width: 100%; height: 100%;"/>
			</a>			
		</div>		
	</div>
	<?php require_once("clone.php"); ?>
</body>
</html>