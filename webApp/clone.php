<div id="cloneVideoItem" class="clone">
	<input type="hidden" id="videoId">
	<input type="hidden" id="videoUserId">
	<input type="hidden" id="videoNo">
	<input type="hidden" id="videoType">
	<input type="hidden" id="videoScore">
	<div id="videoItemImage">
		<img id="photo" class="videoProfile"/>
		<img id="score" class="videoProfile" src="/img/pieWhite3.png" style="opacity:0.5; filter: alpha(opacity=50);"/>
	</div>
	<div id="videoItemInfo">
		<div id="videoItemTitle"></div>
		<div id="videoItemHashtag">#</div>
		<div id="videoItemUsername">@</div>
		<div id="videoItemTimeAgo"></div>
	</div>
	<div class="clearboth"></div>
	<div id="videoItemPlayer">
		<img src="img/btnPlay.png" class="videoItemBtnPlay"/>
		<div id="videoItemPlayerIframe"></div>
		<img id="videoItemThumb"/>
		<!-- div id="videoItemReport" class="pointer" onclick="onVideoReport(this)">
			<img src="/img/btnReport.png" style="width: 100%; height: 100%;">
		</div>
		<div id="videoItemShare" class="pointer" onclick="onVideoShare(this)">
			<img src="/img/btnShare.png" style="width: 100%; height: 100%;">
		</div -->
		
		<div id="videoItemScore"> 
			<img src="" width="290" height="290" usemap="#showScoreMap" />
			<map name="showScoreMap">
				<area id="areaShowScore" shape="poly" coords="148,7, 148,77, 184,90, 208,120, 275,99, 250,58, 204,20" title="1" alt="1" type="showScore" href="#"/>
				<area id="areaShowScore" shape="poly" coords="211,128, 209,167, 188,198, 228,253, 264,213, 281,161, 276,106" title="2" alt="2" type="showScore" href="#"/>
				<area id="areaShowScore" shape="poly" coords="109,202, 144,213, 181,202, 222,258, 170,280, 117,280, 68,258" title="3" alt="3" type="showScore" href="#"/>
				<area id="areaShowScore" shape="poly" coords="102,197, 81,167, 79,128, 13,106, 8,161, 26,214, 61,253" title="4" alt="4" type="showScore" href="#"/>
				<area id="areaShowScore" shape="poly" coords="141,7, 141,77, 104,90, 81,120, 15,99, 39,57, 82,21" title="5" alt="5" type="showScore" href="#"/>
				<area id="areaShowScore" shape="circle" coords="145,145,61" title="Play" alt="play" type="showScore" href="#"/>
			</map>
		</div>
	</div>
	<div id="videoItemCommentList">
																													
	</div>
	<div id="videoCommentArea">
		<div class="inputItem">
			<a class="btnClearTextarea" onclick="onClearTextarea(this)"><img style="width:100%;height:100%;" src="/img/btnDeleteText.png"/></a>
			<textarea id="videoItemCommentText" placeholder="Add Comment Here..." onkeyup="onKeyUpCommentText(this, event)"></textarea>
		</div>
		<a id="btnCommentSubmit" onclick="onCommentSubmit(this)" class="btnOk">
			<img src="/img/btnConfirm.png" style="width: 100%; height: 100%;"/>
		</a>
	</div>
	<div class="clearboth"></div>		
</div>
<div id="cloneVideoItemComment" class="clone">
	<input type="hidden" id="commentId"/>
	<input type="hidden" id="commentUserId"/>	
	<div id="videoItemCommentArea">

	</div>
	<div style="position:absolute; bottom: 2px; right: 0px; padding-left:15px; padding-right:10px;cursor: pointer;" onclick="onCommentReport( this )">
		<img src="/img/btnCommentShare.png" id="btnCommentShare"/>
	</div>
</div>

<div id="cloneProfileVideoItemByList" class="clone">
	<a>
	<input type="hidden" id="videoId"/>
	<img src="" id="profileVideoItemByListThumb"/>
	<div id="profileVideoItemByListBody">
		<div id="profileVideoItemByListUsername">Username</div>
		<div id="profileVideoItemByListContent">Content</div>
		<div id="profileVideoItemByListHashtag">Hashtag</div>
	</div>
	<div id="profileVideoItemByListScore"></div>
	</a>
	<div id="searchVideoItemSmall">
		<img src="img/btnSmallPlay.png" style="width:100%;cursor:pointer;" id="btnSmallPlay"/>
		<img src="img/btnSmallScore.png" style="width:100%;cursor:pointer;" id="btnSmallScore"/>
	</div>		
</div>

<div id="cloneSearchVideoItemByList" class="clone">
	<a>
	<input type="hidden" id="videoId"/>
	<input type="hidden" id="videoNo"/>
	<input type="hidden" id="videoType"/>
	<img src="" id="searchVideoItemByListThumb"/>
	<div id="searchVideoItemByListBody">
		<div id="searchVideoItemByListUsername">Username</div>
		<div id="searchVideoItemByListContent">Content</div>
		<div id="searchVideoItemByListHashtag">Hashtag</div>
	</div>
	<div id="searchVideoItemByListScore"></div>

	</a>
	<div id="searchVideoItemSmall">
		<img src="img/btnSmallPlay.png" style="width:100%;cursor:pointer;" id="btnSmallPlay"/>
		<img src="img/btnSmallScore.png" style="width:100%;cursor:pointer;" id="btnSmallScore"/>
	</div>	
</div>
<div id="cloneSearchVideoItemByMosaic" class="clone">
	<a>
	<input type="hidden" id="videoId"/>
	<img src="" id="searchVideoItemByMosaicThumb"/>
	</a>
</div>

<div id="cloneSearchUserItem" class="clone">
	<input type="hidden" id="userId"/>
	<img src="" id="searchUserItemPhoto"/>
	<div id="searchUserItemBody">
		<div id="searchUserItemUsername">Username</div>
		<div id="searchUserItemName">Name</div>
		<div id="searchUserItemCredTxt">Cred</div>
	</div>
	<div id="searchUserItemCredGraph"></div>
	<div id="searchUserItemFriendship">
		<img src="" id="btnSmallFollow"/>
		<img src="" id="btnSmallFollowing" onclick="onClickFollowingIcon(this)"/>
	</div>
</div>

<div id="cloneNotificationItem" class="clone">
	<div id="notificationGap">
		<div id="notificationItemPhoto">
			<img src="/img/profile/noPhoto.png" style="width:100%;height:100%;"/>
		</div>
		<div id="notificationItemContent">
			<div id="notificationItemTitle">Title</div>
			<div id="notificationItemDescription">
				Description
			</div>
			<div id="notificationItemTimeAgo">
				Ago
			</div>
		</div>
	</div>
</div>

<div id="videoScoreContainer" class="scorePanelHide">
	<div class="popupBtnPrev" onclick="onCloseVideoScoreContainer()">
		<img src="/img/btnPrev.png" style="height:100%;width:100%;"/>
	</div>
	<div class="popupBtnPlay" onclick="onShowVideoPlay()">
		<img src="/img/btnNext.png" style="height:100%;width:100%;"/>
	</div>
	<div class="popupBtnReport" onclick="onShowVideoReport(this)">
		<img src="/img/btnReportNew.png" style="height:100%;width:100%;"/>
	</div>
	<div class="popupBtnShare" onclick="onShowVideoShare(this)">
		<img src="/img/btnShareNew.png" style="height:100%;width:100%;"/>
	</div>			
	<div id="videoScoreMain">
		<input type="hidden" id="videoId">
		<input type="hidden" id="videoNo">
		<input type="hidden" id="videoType">
		<input type="hidden" id="videoScore">
		<input type="hidden" id="isScored">
		<input type="hidden" id="isGiven">
		<input type="hidden" id="givenScore">
		<div id="videoInfoArea">
			<p><a href="#"></a></p>
			<p><a href="#"></a></p>
		</div>
		<div id="videoScorePanel">
			<div id="videoScorePanelScore"></div>	
			<img src="/img/pieRed3_290.png" width="290" height="290" usemap="#giveScoreMap"/>
			<map name="giveScoreMap">
				<area shape="poly" coords="148,7, 148,77, 184,90, 208,120, 275,99, 250,58, 204,20" title="1" alt="1" type="giveScore" href="#"/>
				<area shape="poly" coords="211,128, 209,167, 188,198, 228,253, 264,213, 281,161, 276,106" title="2" alt="2" type="giveScore" href="#"/>
				<area shape="poly" coords="109,202, 144,213, 181,202, 222,258, 170,280, 117,280, 68,258" title="3" alt="3" type="giveScore" href="#"/>
				<area shape="poly" coords="102,197, 81,167, 79,128, 13,106, 8,161, 26,214, 61,253" title="4" alt="4" type="giveScore" href="#"/>
				<area shape="poly" coords="141,7, 141,77, 104,90, 81,120, 15,99, 39,57, 82,21" title="5" alt="5" type="giveScore" href="#"/>
				<area shape="circle" coords="145,145,61" alt="submitScore" type="giveScore" href="#">
			</map>
			
		</div>
		<div id="videoScoreAvg" class="hide">Avg. Score: </div>
		<div id="videoScoreInfoByMeArea">
			<p><a href="#"></a></p>
		</div>		
		<div id="videoScoreUserGaveScoreList">
			<div><a href="profile.php?id=a">@cacobelllo</a> : </div>
		</div>
	</div>
</div>
<div id="videoPlayerContainer" class="clone" >
	<input type="hidden" id="videoId">
	<input type="hidden" id="videoNo">
	<input type="hidden" id="videoType">
 	<div class="popupBtnPrev" onclick="onCloseVideoPlayerContainer()">
		<img src="/img/btnPrev.png" style="height:100%;width:100%;"/>
	</div>
	<div class="popupBtnPlay" onclick="onShowVideoScore()">
		<img src="/img/btnSmallScore.png" style="height:100%;width:100%;"/>
	</div>
	<div class="popupBtnReport" onclick="onShowVideoReport(this)">
		<img src="/img/btnReportNew.png" style="height:100%;width:100%;"/>
	</div>
	<div class="popupBtnShare" onclick="onShowVideoShare(this)">
		<img src="/img/btnShareNew.png" style="height:100%;width:100%;"/>
	</div>
	<div id="videoInfoArea1" style="text-align:center;margin-top:5px;">
		<p style="margin-bottom:1px;margin-top:1px;"><a href="#"></a></p>
		<p style="margin-bottom:1px;margin-top:1px;"><a href="#"></a></p>
	</div>
</div>
<div id="videoPlayerIframe" class="clone">
	<iframe style="width:100%; height: 100%;" src="" frameborder="0" allowfullscreen></iframe>
</div>
<div id="videoShareContainer">
 	<div class="popupBtnPrev" onclick="onCloseVideoShareContainer()" style="z-index: 50;">
		<img src="/img/btnPrev.png" style="height:100%;width:100%;"/>
	</div>
	<div id="videoShareBody">
		<input type="hidden" id="videoId"/>
		<a id="shareOnFB" onclick="fnVideoShare(this)" href="https://www.facebook.com/sharer/sharer.php?u=https%3A%2F%2Fparse.com" target="_blank"><img src="img/btnFBShare.png" id="btnFBShare" /></a>
		<a id="shareOnTW" onclick="fnVideoShare(this)" href="https://twitter.com/share?url=https%3A%2F%2Fdev.twitter.com%2Fpages%2Ftweet-button" target="_blank"><img src="img/btnTWShare.png" id="btnTWShare" /></a>
		<div style="position:relative;">
			<div class="inputItem">
				<input type="text" id="emailShare" class="form-control textCommon" placeholder="INPUT EMAIL ADDRESS"/>
				<a class="btnClearText" onclick="onClearText(this)"><img style="width:100%;height:100%;" src="/img/btnDeleteText.png"/></a>
			</div>
						
			<button onclick="fnVideoShareEmail(this)" class="form-control textCommon" style="background:#F0F0F0;margin-top:3px;">SHARE THIS VIDEO BY EMAIL</button>
		</div>
		<button data-clipboard-text="" id="reportCopyPostUrl" class="btn-clipboard form-control textCommon bordernone" style="background:#F0F0F0;">COPY POST URL</button>
		<br/>
		<br/>
		<br/>
	</div>
</div>

<div id="videoReportContainer" class="clone">
	 	<div class="popupBtnPrev" onclick="onCloseVideoReportContainer()">
			<img src="/img/btnPrev.png" style="height:100%;width:100%;"/>
		</div>	
	<div id="videoReportBody" class="videoReportBody">

		<input type="hidden" id="videoId" />
		
		<button id="reportToAdmin" class="form-control textCommon bordernone" style="background:#b3b3b3;margin-top:10px;">REPORT TO ADMIN</button>
		<div id="resetArea">
			<div class="inputItem">
				<input type="text" id="hashtag" class="form-control textCommon" placeholder="WRITE NEW HASHTAG HERE" onkeyup="onEnterHashtag()" onblur="hideCategoryMenu()" onfocus="onEnterHashtag()">
				<a class="btnClearText" onclick="onClearText(this)"><img style="width:100%;height:100%;" src="/img/btnDeleteText.png"/></a>
				<div class="textCommon1 hashtag1" id="defaultCategory" style="display:none;position:absolute;z-index: 100;background: #b3b3b3; color: #FFF;cursor: pointer;text-align:center;">USE "DEFAULT CAT" INSTEAD</div>
			</div>
			<br/>
			<button onclick="onResetHashtag(this)" id="resetHashtag" class="form-control textCommon bordernone" style="background:#b3b3b3;">RESET HASHTAG</button>		
			<div style="width:86%;margin-left:8%; color:#AAA; margin-top: 3px;position:absolute;color:#b3b3b3;text-align:left;">* All the scores on this video will be deleted.</div>
			<br/><br/><br/>
			<button onclick="onDeleteVideo(this)" id="reportDeleteVideo" class="form-control textCommon bordernone" style="background:#b3b3b3;">DELETE VIDEO</button>
		</div>		
	</div>
</div>

<div id="cloneUserItem" class="clone">
	<input type="hidden" id="userId"/>
	<img src="" id="userItemPhoto"/>
	<div id="userItemBody">
		<div id="userItemUsername">Username</div>
		<div id="userItemName">Name</div>
		<div id="userItemCredTxt">Cred</div>
	</div>
	<div id="userItemCredGraph"></div>
	<div id="searchUserItemFriendship">
		<img src="" id="btnSmallFollow"/>
		<img src="" id="btnSmallFollowing" onclick="onClickFollowingIcon(this)"/>
	</div>	
</div>

<div id="loadingContainer" style="display:none;">
	<img id="imgLoading" src="/img/loading.png"/>
</div>

<input type="hidden" id="isLogin" value="<?php echo $isLogin;?>"/>
<input type="hidden" id="hostServer" value="<?php echo HOST_SERVER;?>"/>
<?php
	$currentUserId = RB_getCookie("RB_USER");
	$sql = "select * from rb_user where rb_user = $currentUserId"; 
	$userInfo = $db->queryArray( $sql );
	$currentUsername = "";
	if( $userInfo != null ){
		$currentUsername = $userInfo[0]['rb_username'];
	}
?>
<input type="hidden" id="currentUsername" value="<?php echo $currentUsername;?>"/>
<?php
	$sql = "select now() currentTime";
	$dataTime = $db->queryArray( $sql );
	$currentTime = $dataTime[0]['currentTime'];
?>
<input type="hidden" id="currentTime" value="<?php echo $currentTime;?>"/>

<div id="cloneProfileHashtagItem" style="display:none;">
<a href="#" style="color:#FFF;"></a>
<span></span>
</div>