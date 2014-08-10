<?php
/**
 * Globo Rojo open source application
 *
 *  Copyright © 2013, 2014 by Mauro Magnasco <mauro.magnasco@gmail.com>
 *
 *  Licensed under GNU General Public License 2.0 or later.
 *  Some rights reserved. See COPYING, AUTHORS.
 *
 * @license GPL-2.0+ <http://spdx.org/licenses/GPL-2.0+>
 */
	require_once("../common/DB_Connection.php");	
    require_once("../common/functions.php");
    require_once ("../simple_html_dom.php");
    require_once("../facebook/facebook.php");
    require_once("../twitteroauth/twitteroauth.php");    
    require_once("../common/checkAuth.php");
    
    $result = "success";
    $error = "";
    $data = array();
    
    $userId = mysql_escape_string($_POST['userId']);
    $videoUrl = mysql_escape_string($_POST['videoUrl']);
    $description = mysql_escape_string($_POST['description']);
    $hashtag = mysql_escape_string($_POST['category']);
    
    $shareFacebook = mysql_escape_string($_POST['shareFacebook']);
    $shareTwitter = mysql_escape_string($_POST['shareTwitter']);
    
    if( substr($hashtag, 0, 1) == "#" )
    	$hashtag = substr( $hashtag, 1 );
    
    $videoType = RB_getVideoType( $videoUrl );
	
    if( $videoType == "Y" ){   	
    	$youTubeId = RB_getYouTubeId( $videoUrl );
    	$url = "https://gdata.youtube.com/feeds/api/videos/".$youTubeId."?v=2&alt=jsonc";
    	$json = file_get_contents( $url );
    	$youTubeInfo = json_decode( $json, true );
    	$videoThumbLarge = $youTubeInfo["data"]["thumbnail"]["hqDefault"];
    	$videoThumbSmall = $youTubeInfo["data"]["thumbnail"]["sqDefault"];
    	$videoTitle = $youTubeInfo["data"]["title"];
    }else if( $videoType == "V" ){
    	$vimeoId = RB_getVimeoId( $videoUrl );
    	$url = "http://vimeo.com/api/v2/video/".$vimeoId.".json";
    	$json = file_get_contents( $url );
    	$vimeoInfo = json_decode( $json, true );
    	$videoThumbLarge = $vimeoInfo[0]["thumbnail_large"];
    	$videoThumbSmall = $vimeoInfo[0]["thumbnail_small"];
    	$videoTitle = $vimeoInfo[0]["title"];
    }else if( $videoType == "K" ){
    	$arr = explode("?", $videoUrl);
    	$videoUrl = $arr[0]."/widget/video.html";
    	$html = file_get_html( $videoUrl );
    	$videoTitle = $html->find("title", 0)->innertext;
    	$videoThumbLarge = $html->find("video", 0)->poster;
    	$videoThumbSmall = str_replace( "photo-main", "photo-little", $videoThumbLarge );
    }else if( $videoType == "T" ){
    	$url = "http://www.ted.com/talks/oembed.xml?url=".$videoUrl.".html";
    	$json = file_get_contents( $url );
    	$tedInfo = simplexml_load_string( $json );
    	$videoThumbLarge = $tedInfo->thumbnail_url;
    	$videoThumbSmall = $tedInfo->thumbnail_url;
    	$videoTitle = $tedInfo->title;
    }else if( $videoType == "F" ){
    	$parts = parse_url($videoUrl);
    	parse_str($parts['query'], $url);
    	$videoId = $url['v'];
    	$videoThumbLarge = "https://graph.facebook.com/".$videoId."/picture";
    	$videoThumbSmall = $videoThumbLarge;
    	$videoTitle = "Facebook Video";
    }else if( $videoType == "D" ){
    	$arr = explode( "/", $videoUrl);
    	$videoId = $arr[4];
    	
    	$parseUrl = "http://www.funnyordie.com/videos/$videoId";
    	$parseUrl = urlencode( $parseUrl );
    	$url = "http://www.funnyordie.com/oembed.json?url=$parseUrl";
    	$json = file_get_contents( $url );
    	$videoInfo = json_decode( $json, true );
    	$videoThumbLarge = $videoInfo["thumbnail_url"];
    	$videoThumbSmall = $videoInfo["thumbnail_url"];
    	$videoTitle = $videoInfo["title"];
    }else if( $videoType == "C" ){
    	$arr = explode( "/", $videoUrl);
    	$videoId = $arr[4];
    	
    	$parseUrl = "http://www.collegehumor.com/video/$videoId";
    	$parseUrl = urlencode( $parseUrl );
    	
    	$url = "http://www.collegehumor.com/oembed.json?url=$parseUrl";
    	$json = file_get_contents( $url );
    	$videoInfo = json_decode( $json, true );
    	$videoThumbLarge = $videoInfo["thumbnail_url"];
    	$videoThumbSmall = $videoInfo["thumbnail_url"];    	
    	$videoTitle = $videoInfo["title"];
    }else{
    	$result = "failed";
    	$error = "In the moment we can attach videos from Youtube, Vimeo, KickStarter and Ted only, sorry.";
    }
     
    if( $result == "success" ){
    	$sql = "insert into rb_video( rb_user, rb_video_url, rb_content, rb_hashtag, rb_video_thumb_large, rb_video_thumb_small, rb_video_score, rb_video_type, rb_created_time, rb_updated_time )
    			value( $userId, '$videoUrl', '".addslashes($videoTitle)."', '$hashtag', '$videoThumbLarge', '$videoThumbSmall', ".INITIAL_SCORE.", '$videoType', now(), now())";
    	$db->queryInsert( $sql );
    	$videoId = $db->getPrevInsertId();
    	
    	$new_str = str_replace(' ', '', $description);
    	if( $new_str != "" ){
	    	$sql = "insert into rb_user_video_comment( rb_user, rb_video, rb_content, rb_created_time, rb_updated_time )
	    			value( $userId, $videoId, '".addslashes($description)."', now(), now())";
	    	$db->queryInsert( $sql );
    	}
    }
	
    $sql = "select * from rb_user_sns where rb_user = $userId and rb_sns_type = 1";
    $dataResult = $db->queryArray( $sql );
    if( $dataResult == null){
    	$fbId = "";
    }else{
    	$fbId = $dataResult[0]['rb_sns_id'];
    	$fbToken = $dataResult[0]['rb_token'];
    }
    
    $data['videoId'] = $videoId;
    $data['image'] = $videoThumbLarge;
    $data['title'] = $videoTitle;
    
    $shareFacebook = $_POST['shareFacebook'];
    $shareTwitter = $_POST['shareTwitter'];
    $shareLink = "http://".HOST_SERVER."/video.php?id=".base64_encode($videoId);

    if( $shareFacebook == "Y" ){
    	$config = array();
    	$config['appId'] = FACEBOOK_APP_ID;
    	$config['secret'] = FACEBOOK_APP_SECRET;
    	$config['fileUpload'] = false;
    	 
    	$fb = new Facebook($config);
    	 
    	$params = array(
    			"access_token" => $fbToken,
    			"link" => $shareLink,
    			"picture" => $videoThumbLarge,
    			"name" => SITE_NAME,
    			"caption" => $videoTitle,
    			"description" => $description
    	);

    	try {
    		$ret = $fb->api('/'.$fbId.'/feed', 'POST', $params);
    	} catch(Exception $e) {
    		$error = $e->getMessage();
    		
    		$oldToken = $fbToken;
    		$url = "https://graph.facebook.com/oauth/access_token?client_id=".FACEBOOK_APP_ID."&client_secret=".FACEBOOK_APP_SECRET."&grant_type=fb_exchange_token&fb_exchange_token=$oldToken";
    		$result = file_get_contents($url);
    		parse_str( $result, $get_array);
    		$newToken = $get_array["access_token"];
    		$sql = "update rb_user_sns
    				   set rb_token = '$newToken'
    				 where rb_user = $userId
    				   and rb_sns_type = 1";
    		$db->query( $sql );
    		
    		$params = array(
    				"access_token" => $fbToken,
    				"link" => $shareLink,
    				"picture" => $videoThumbLarge,
    				"name" => SITE_NAME,
    				"caption" => $videoTitle,
    				"description" => $description
    		);    		
    		$ret = $fb->api('/'.$fbId.'/feed', 'POST', $params);
    	}
    }
    if( $shareTwitter == "Y" ){
    	$sql = "select * from rb_user_sns where rb_user = $userId and rb_sns_type = 2";
    	$dataSnsUser = $db->queryArray( $sql );
    	 
    	$sql = "select rb_username from rb_user where rb_user = $userId";
    	$dataUser = $db->queryArray( $sql );
    	$username = $dataUser[0]['rb_username'];
    
    	$txt = $videoTitle." via @".$username." #"."$hashtag $shareLink";
    	$token1 = $dataSnsUser[0]['rb_token'];
    	$token2 = $dataSnsUser[0]['rb_token2'];
    
    	/* Create a TwitterOauth object with consumer/user tokens. */
    	$connection = new TwitterOAuth(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET, $token1, $token2);
    
    	$connection->post('statuses/update', array('status' => $txt));
    }    
    
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
