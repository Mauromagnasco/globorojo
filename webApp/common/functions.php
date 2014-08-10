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
	require_once dirname(__FILE__) . '/config.php';
	require_once dirname(__FILE__) . '/DB_Connection.php';
	require_once dirname(__FILE__) . '/class.phpmailer.php';	
	function logToFile($filename, $msg)
	{
		// open file
		$fd = fopen($filename, "a");
		// append date/time to message
		$str = "[" . date("Y/m/d h:i:s", time()) . "] " . $msg;
		// write string
		fwrite($fd, $str . "\n");
		// close file
		fclose($fd);
	}
	
	function RB_MkDir($path, $mode = 0777) {
		$dirs = explode(DIRECTORY_SEPARATOR , $path);
		$count = count($dirs);
		$path = '.';
		for ($i = 0; $i < $count; ++$i) {
			$path .= DIRECTORY_SEPARATOR . $dirs[$i];
			if (!is_dir($path) && !mkdir($path, $mode)) {
				return false;
			}
		}
		return true;
	}
	function RB_generateRandom( $len ){
		$strpattern = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
		$result = "";
		for( $i = 0 ; $i < $len; $i ++ ){
			$rand = rand( 0, strlen($strpattern) - 1 );
			$result = $result.$strpattern[$rand];
		}
		return $result;
	}
	function RB_isLogin(){
		if( isset($_COOKIE['RB_USER'])){
			return true;
		}else{
			return false;
		}
	}
	function RB_setCookie( $name, $value){
		setcookie( $name, $value, time() + ( 2 * 7 * 24 * 60 * 60) );
	}
	function RB_getCookie( $name ){
		return $_COOKIE[$name];
	}
	function RB_deleteCookie( $name ){
		setcookie($name, "", time() - 3600);
	}
	function RB_getVideoType( $url1 ){
		$url = strtolower( $url1 );
		if( strpos( $url, "kickstarter.com") > 0 ){
			$videoType = "K";
		}else if(( strpos( $url, "youtube.com") > 0 ) || ( strpos( $url, "youtu.be") > 0 )){
			$videoType = "Y";
		}else if( strpos( $url, "vimeo.com") > 0 ){
			$videoType = "V";
		}else if( strpos( $url, "ted.com") > 0 ){
			$videoType = "T";
		}else if( strpos( $url, "indiegogo.com") > 0 ){
			$videoType = "I";
		}else if( strpos( $url, "facebook.com") > 0 ){
			$videoType = "F";
		}else if( strpos( $url, "funnyordie.com") > 0 ){
			$videoType = "D";
		}else if( strpos( $url, "indiegogo.com") > 0 ){
			$videoType = "I";
		}else if( strpos( $url, "collegehumor.com") > 0 ){
			$videoType = "C";
		}else
			$videoType = "E";
		return $videoType;
	}
	function RB_getVimeoId( $url ){
		$arr = explode("?", $url);
		$arr = explode("/", $arr[0]);
		
		// $video_id = substr(parse_url($url, PHP_URL_PATH), 1);
		$video_id = $arr[ count($arr) - 1 ];
		return $video_id;
	}
	function RB_getYouTubeId( $url ){
/* 		preg_match("/^(?:http(?:s)?:\/\/)?(?:www\.)?(?:youtu\.be\/|youtube\.com\/(?:(?:watch)?\?(?:.*&)?v(?:i)?=|(?:embed|v|vi|user)\/))([^\?&\"'>]+)/", $url, $matches);
		return $matches[1]; */
		$video_id = false;
		$url = parse_url($url);
		if (strcasecmp($url['host'], 'youtu.be') === 0){
			#### (dontcare)://youtu.be/<video id>
			$video_id = substr($url['path'], 1);
		}else if (strcasecmp($url['host'], 'www.youtube.com') === 0 || strcasecmp($url['host'], 'm.youtube.com') === 0){
	    	if (isset($url['query'])){
	    		parse_str($url['query'], $url['query']);
	    		if (isset($url['query']['v'])){
	    			#### (dontcare)://www.youtube.com/(dontcare)?v=<video id>
	    			$video_id = $url['query']['v'];
	    		}
	        }
	        if ($video_id == false){
	        	$url['path'] = explode('/', substr($url['path'], 1));
	        	if (in_array($url['path'][0], array('e', 'embed', 'v'))){
	        		#### (dontcare)://www.youtube.com/(whitelist)/<video id>
	        		$video_id = $url['path'][1];
	        	}
	        }
		}
	    return $video_id;
	}
	function RB_photoURL( $photo ){
		if( substr( $photo, 0, 4 ) == "http" ){
			return $photo;
		}else if( substr( $photo, 0, 1 ) == "/" ){
			return "http://".HOST_SERVER.$photo;
		}else{
			return "http://".HOST_SERVER."/".$photo;
		}
	}
	
	function RB_getUserInfo( $userId ){
		global $db;
		$sql = "select * from rb_user where rb_user = $userId";
		$result = $db->queryArray( $sql );
		$result = $result[0];
		return $result;
	}
	
	function RB_emailNotiByUser( $receiverId, $message, $subject ,$type ){
		global $db;
		$sql = "select * from rb_user where rb_user = $receiverId";
		$dataUser = $db->queryArray( $sql );
		$dataUser = $dataUser[0];
		$email = $dataUser['rb_email'];
		$msgUnsubscribe = "Unsubscribe <a href='http://".HOST_SERVER."/emails.php'>here</a>";
		$msgImage = "<img src='http://".HOST_SERVER."/img/iconEmail.png'/>";
		$body ='
				<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
				<html xmlns="http://www.w3.org/1999/xhtml">
				<head>
				<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
				<meta name="viewport" content="initial-scale=1.0"/>
				<meta name="format-detection" content="telephone=no"/>
				</head>
				<body style="font-size:12px;">
					<table id="mainStructure" width="100%" border="0" cellspacing="0" cellpadding="0" style="background-color:#000000;">
						<tr height="30px">
							<td align="center" valign="top" style="background-color: #FFFFFF; ">'
							.$message	
							.'</td>
						</tr>
						<tr>
							<td align="center" valign="top" style="background-color: #FFFFFF; ">'
							.$msgImage	
							.'</td>
						</tr>
						<tr height="30px">
							<td align="center" valign="top" style="background-color: #FFFFFF; ">'
							.$msgUnsubscribe
							.'</td>
						</tr>								
					</table>  
				</body>
				</html>';
		
		if( $type == 1 && $dataUser['rb_email_comment_yn'] == "Y" ){
			RB_sendEmail( $email, $body, $subject, true);
		}else if( $type == 2 && $dataUser['rb_email_score_yn'] == "Y" ){
			RB_sendEmail( $email, $body, $subject, true);
		}else if( $type == 3 && $dataUser['rb_email_follow_yn'] == "Y" ){
			RB_sendEmail( $email, $body, $subject, true);
		}else if( $type == 4 && $dataUser['rb_email_mention_yn'] == "Y" ){
			RB_sendEmail( $email, $body, $subject, true);
		}else if( $type == 5 && $dataUser['rb_email_unfollow_yn'] == "Y" ){
			RB_sendEmail( $email, $body, $subject, true);
		}
		
	}
	function RB_sendEmail( $email, $message, $subject, $isHTML = false ){
		$mailer = new PHPMailer();
		$mailer->CharSet = 'utf-8';
		$mailer->IsMail();
		$mailer->Sender = NOREPLY_EMAIL;
		$mailer->From = NOREPLY_EMAIL;
		$mailer->FromName = "Globo Rojo";
		$mailer->AddAddress($email, SITE_NAME);
		$mailer->WordWrap = 70;
		$mailer->IsHTML($isHTML);
		$mailer->Subject = $subject;
		$mailer->Body = $message;
		return $mailer->Send();		
	}
	function RB_pushNotiByUser( $userId, $message, $type, $id ){
		global $db;
		$sql = "select * from rb_user_udid where rb_user = $userId";
		$result = $db->queryArray( $sql );
		for( $i = 0; $i < count( $result ); $i ++ ){
			RB_pushNotification( $result[$i]['rb_dev_token'], $message, $type, $id );
		}
	}
	
	function RB_videoUrl( $type, $url ){
		if( $type == "Y" ){
			return "http://www.youtube.com/embed/".RB_getYouTubeId( $url )."?autoplay=1";
		}else if( $type == "V" ){
			return "http://player.vimeo.com/video/".RB_getVimeoId( $url )."?autoplay=1";
		}else if( $type == "T" ){
			$videoUrl = $url;
			$videoUrl = str_replace( "www.ted.com", "embed.ted.com", $videoUrl );
			$videoUrl = str_replace( "https", "http", $videoUrl );
			$videoUrl = $videoUrl.".html";
			return $videoUrl;
		}else if( $type == "F" ){
	    	$parts = parse_url($url);
	    	parse_str($parts['query'], $v);
	    	$videoId = $v['v'];
			$videoUrl = "http://www.facebook.com/video/embed?video_id=".$videoId;
	    	// $videoUrl = "http://www.facebook.com/video/video.php?v=70409658791;
			return $videoUrl;
		}else if( $type == "D" ){
			$arr = explode( "/", $url);
			$videoId = $arr[4];
			$videoUrl = "http://www.funnyordie.com/embed/$videoId";
			return $videoUrl;
		}else if( $type == "C" ){
			$arr = explode( "/", $url);
			$videoId = $arr[4];
			$videoUrl = "http://www.collegehumor.com/e/$videoId";
			return $videoUrl;
		}else{
			return $url;
		}		
	}
	
	function RB_pushNotification( $deviceToken, $message, $type, $id ){				
		// Put your private key's passphrase here:
		$passphrase = 'pushchat';		
		
		$ctx = stream_context_create();
		stream_context_set_option($ctx, 'ssl', 'local_cert', 'rbpk.pem');
		stream_context_set_option($ctx, 'ssl', 'passphrase', 'counterstriker1');
		
		// Open a connection to the APNS server
		$fp = stream_socket_client(
				'ssl://gateway.push.apple.com:2195', $err,
				$errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);
		
		if (!$fp)
			exit("Failed to connect: $err $errstr" . PHP_EOL);
		
		// echo 'Connected to APNS' . PHP_EOL;
		
		global $db;
		
		$sql = "update rb_user_udid
				   set rb_badge_cnt = rb_badge_cnt + 1
				 where rb_dev_token = '$deviceToken'";
		$db->query( $sql );		
		
		$sql = "select * from rb_user_udid where rb_dev_token ='$deviceToken'";
		$badge = $db->queryArray( $sql );
		$badge = $badge[0]['rb_badge_cnt'];
		
		// Create the payload body
		$body['aps'] = array(
				'alert' => $message,
				'type' => $type,
				'id' => $id,				
				'sound' => 'default',
				'badge' => $badge * 1
		);
		
		// Encode the payload as JSON
		$payload = json_encode($body);
		
		// Build the binary notification
		$msg = chr(0) . pack('n', 32) . pack('H*', $deviceToken) . pack('n', strlen($payload)) . $payload;

		// Send it to the server
		$result = fwrite($fp, $msg, strlen($msg));
		/* 
		if (!$result)
			echo 'Message not delivered' . PHP_EOL;
		else
			echo 'Message successfully delivered' . PHP_EOL;
		 */
		// Close the connection to the server
		fclose($fp);
	}
	
	if(RB_isLogin()){
		$uId = RB_getCookie("RB_USER");
		$sql = "select * from rb_notification where rb_user = '$uId' and rb_read_yn = 'N'";
		$dataResult = $db->queryArray( $sql );
		if( $dataResult == null ){
			$isNotification = "N";
		}else{
			$isNotification = "Y";
		}
	}else{
		$isNotification = "N";
	}
	
	if (!function_exists('getallheaders'))
	{
		function getallheaders()
		{
			$headers = '';
			foreach ($_SERVER as $name => $value)
			{
				if (substr($name, 0, 5) == 'HTTP_')
				{
					$headers[str_replace(' ', '-', ucwords(str_replace('_', ' ', substr($name, 5))))] = $value;
				}
			}
			return $headers;
		}
	}
?>