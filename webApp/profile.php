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
    <script type="text/javascript" src="/js/profile.js"></script>
    <?php
    	if( isset( $_GET['id'] ) ){
			$userId = $_GET['id'];
			$userId = base64_decode( $userId );
		}else{
			$userId = RB_getCookie("RB_USER");
		}
    ?>
</head>
<body>
	<input type="hidden" id="userId" value="<?php echo $userId?>"/>
	<div onclick="onHideEnlargePhoto()" id="divProfileEnlargePhoto" style="position:absolute;left: 0px; right:0px; bottom: 0px; top: 0px;background:#000;opacity:0.7;display:none;z-index:2500;"></div>
	<img onclick="onHideEnlargePhoto()" id="profileEnlargePhoto" style="display:none;" src="<?php echo NO_PROFILE_PHOTO;?>">	
	<div id="mainContainer" style="overflow:hidden;">
		<?php $isProfileMenu = "Y"; ?>
		<?php require_once("lightMenu.php"); ?>
		<div class="menuListBackground clone" onclick="onMenu()"></div>	
		<div id="topBar">
			<div id="navigationBar" style="position:relative;" class="zIndex100">
				<div id="navPageTitle1">PROFILE</div>
				<a id="navBtnPrev" class="pointer" onclick="onBack();">
					<img src="/img/btnPrev.png" style="width: 100%; height: 100%;"/>
				</a>
				<div id="homeRightNavIcon" class="pointer" onclick="onMenu()">
					<img src="/img/btnMenu<?php if( $isNotification == "Y") echo 'Red';?>.png" style="width:100%;height:100%;"/>
				</div>				
			</div>
			<div id="profileInfo"  class="zIndex100">
				<input type="hidden" id="userId" value="<?php echo $userId; ?>">
				<img id="profilePhoto" src="<?php echo NO_PROFILE_PHOTO;?>" onclick="onShowEnlargePhoto()">
				<div id="profileInfoArea">
					<div id="profileInfoNumber">
						<div class="profileInfoNumberItem pointer" id="followingStatus">
							<p style="display:none;"><img src="img/btnGreyLeft.png"/></p>
							<p style="display:none;"><img src="img/btnGreyRight.png"/></p>
						</div>
						<div class="profileInfoNumberItem greySelected pointer" onclick="window.location.href = 'followerList.php?id=<?php echo base64_encode($userId);?>'">						
							<div id="profileInfoFollowersNumber">0</div>
							<div id="profileInfoFollowersLabel">Followers</div>						
						</div>
						<div class="profileInfoNumberItem pointer" onclick="window.location.href = 'followingList.php?id=<?php echo base64_encode($userId);?>'">
							<div id="profileInfoFollowingNumber">0</div>
							<div id="profileInfoFollowingLabel">Following</div>						
						</div>
						
						<div class="clearboth"></div>
					</div>
						<div id="profileBtnSetting" class="pointer" onclick="onProfileSetting()" style="display:none;">
							SETTINGS
						</div>
						<div id="profileBtnFollow" class="pointer" onclick="onProfileFollowing( this )"></div>					
				</div>
				<div id="profileMenu">
					<div id="profileMenuPart1">
						<div id="profileMenuVideo" class="profileMenuItem pointer greySelected">Videos</div>
						<!-- div id="profileMenuListView1" class="profileMenuItem pointer"></div -->
					</div>
					<div id="profileMenuPart2">
						<!-- div id="profileMenuListView2" class="profileMenuItem pointer"></div -->
						<div id="profileMenuCredibility" class="profileMenuItem pointer greySelected">Meri.to</div>
					</div>
					<div id="profileMenuListMode" class="profileMenuItem pointer"></div>
				</div>
			</div>
			<div id="profileSetting">
				<div class="inputItem">
					<input type="text" id="profileName" class="form-control textCommon" placeholder="NAME"/>
					<a class="btnClearText" onclick="onClearText(this)"><img style="width:100%;height:100%;" src="/img/btnDeleteText.png"/></a>
				</div>
				<div class="inputItem">
					<input type="text" id="profileUsername" class="form-control textCommon" placeholder="USERNAME"/>
					<a class="btnClearText" onclick="onClearText(this)"><img style="width:100%;height:100%;" src="/img/btnDeleteText.png"/></a>
				</div>			
					
				<div class="inputItem">
					<input type="password" id="profilePassword" class="form-control textCommon" placeholder="PASSWORD"/>
					<a class="btnClearText" onclick="onClearText(this)"><img style="width:100%;height:100%;" src="/img/btnDeleteText.png"/></a>
				</div>				
				<div class="inputItem">
					<input type="text" id="profileEmail" class="form-control textCommon" placeholder="EMAIL"/>
					<a class="btnClearText" onclick="onClearText(this)"><img style="width:100%;height:100%;" src="/img/btnDeleteText.png"/></a>
				</div>				
				
				<textarea id="profileBio" class="form-control textCommon" rows="3" placeholder="BIO(140 CHARACTERS)" style="display:none;"></textarea>
				<button onclick="onProfilePhotoUpload()" id="profileUploadPicture" class="form-control textCommon greySelected bordernone">UPLOAD PICTURE</button>						
				<button onclick="onProfileDeletePicture()" id="profileDeletePicture" class="form-control textCommon greySelected bordernone">DELETE PICTURE</button>
				<button onclick="onProfileApplication()" id="profileApplications" class="form-control textCommon greySelected bordernone">APPLICATIONS</button>
				<button onclick="onProfileEmail()" id="profileEmail" class="form-control textCommon greySelected bordernone">EMAILS</button>
				<button onclick="onProfileFindFriends()" id="profileFindFriends" class="form-control textCommon greySelected bordernone">FIND FRIENDS</button>
				<button onclick="onProfileDeleteAccount()" id="profileDeleteAccount" class="form-control textCommon greySelected bordernone">DELETE ACCOUNT</button>
				<button onclick="onProfileLogOut()" id="profileLogOut" class="form-control textCommon greySelected bordernone">LOG OUT</button>
				<button id="profileSaveSettings" class="form-control textCommon greyHighlightSelected bordernone" onclick="onSaveProfileSetting( )">
					SAVE SETTINGS<i class="icon-ok icon-white" ></i>
				</button>
				<div>&nbsp;</div>
			</div>
			<div id="profileVideoList">
				Video List
			</div>
			<div id="profileCredibility">
				<div style='margin-top: 20px;' id="name"></div>
				<div><a style='color:#FFF;' class='js-link' href='#' id="username"></a></div>
				<div id="profileCredibilityGraph" class="pieRed0">
				</div>
				<div id="profileHashtagArea">
					<div>Category:</div>
					<br>
					<div id="profileHashtagList">
					</div>
					<br>
				</div>
				<br/>
			</div>
			<div id="loadingContainer" style="display:none;">
				<img id="imgLoading" src="/img/loading.png"/>
			</div>						
		</div>
	</div>
	<?php require_once("clone.php"); ?>
</body>
</html>