<?php
/* Start session and load lib */
session_start();
require_once('twitteroauth/twitteroauth.php');
require_once("./common/DB_Connection.php");
require_once("./common/functions.php");

/* If the oauth_token is old redirect to the connect page. */
if (isset($_REQUEST['oauth_token']) && $_SESSION['oauth_token'] !== $_REQUEST['oauth_token']) {
  $_SESSION['oauth_status'] = 'oldtoken';
  header('Location: ./twitter_clearsessions.php');
}

/* Create TwitteroAuth object with app key/secret and token key/secret from default phase */
$connection = new TwitterOAuth(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET, $_SESSION['oauth_token'], $_SESSION['oauth_token_secret']);

/* Request access tokens from twitter */
$access_token = $connection->getAccessToken($_REQUEST['oauth_verifier']);

/* Save the access tokens. Normally these would be saved in a database for future use. */
$_SESSION['access_token'] = $access_token;

$content = $connection->get('account/verify_credentials');

/* Remove no longer needed request tokens */
unset($_SESSION['oauth_token']);
unset($_SESSION['oauth_token_secret']);

/* If HTTP response is 200 continue otherwise send to connect page to retry */
if (200 == $connection->http_code) {
  /* The user has been verified and the access tokens can be saved for future use */
	$_SESSION['status'] = 'verified';
	
	$twitterId = $content->id_str;
	$twitterName = $content->screen_name;
	$twitterEmail = '';
	$twitterUsername = $content->screen_name;
	$twitterImage = $content->profile_image_url;
	$accessToken1 = $access_token['oauth_token'];
	$accessToken2 = $access_token['oauth_token_secret'];
	
	if( $_SESSION['type'] == "signup" ){
		$sql = "select * from rb_user_sns where rb_sns_type = 2 and rb_sns_id = '$twitterId'";
		$row = $db->queryArray( $sql );
		$firstYn = "Y";
		if( $row == null ){
			// Insert into RB_USER_SNS
			$sql = "insert into rb_user_sns( rb_sns_type, rb_sns_id, rb_nickname, rb_email, rb_photo, rb_token, rb_token2, rb_created_time, rb_updated_time )
			values ( 2, '$twitterId', '$twitterName', '$twitterEmail', '$twitterImage', '$accessToken1', '$accessToken2', now(), now())";
			$db->queryInsert( $sql );
			$userSnsId = $db->getPrevInsertId();
		}else{
			$userSnsId = $row[0]['rb_user_sns'];
			if( $row[0]['rb_valid_yn'] == "Y" ){
				$firstYn = "N";
			}
		}
		$_SESSION['type'] = "";
		if( $firstYn == "Y" )
			header("location: /signUpRegistration.php?id=".base64_encode($userSnsId) );
		else
			header("location: /signup.php?firstYn=N");
	}else if( $_SESSION['type'] == "login" ){
		$sql = "select * from rb_user_sns where rb_sns_type = 2 and rb_sns_id = '$twitterId' and rb_valid_yn = 'Y'";
		$row = $db->queryArray( $sql );
		if( $row == null ){
			$result = "failed";
		}else{
			// Already Registered
			$userId = $row[0]['rb_user'];
			RB_setCookie("RB_USER", $userId);
		}
		
		$_SESSION['type'] = "";
		if( $result == "failed" ){
			header("location: /login.php?type=twLoginFailed");
		}else{
			header("location: /index.php");
		}
	}else if( $_SESSION['type'] == "connect" ){
		$userId = RB_getCookie("RB_USER");
		// logToFile("data.log", "USER ID : ".$userId);
		$sql = "select * from rb_user_sns where rb_sns_type = 2 and rb_sns_id = '$twitterId'";
		// logToFile("data.log", "SQL : ".$sql);
		$row = $db->queryArray( $sql );
		if( $row == null ){
			// Insert into RB_USER_SNS
			$sql = "insert into rb_user_sns( rb_user, rb_sns_type, rb_sns_id, rb_nickname, rb_email, rb_photo, rb_token, rb_token2, rb_valid_yn, rb_created_time, rb_updated_time )
			values ( $userId, 2, '$twitterId', '$twitterName', '$twitterEmail', '$twitterImage', '$accessToken1', '$accessToken2', 'Y', now(), now())";			
			$db->queryInsert( $sql );
		}else{
			if( $row[0]['rb_valid_yn'] == "N" ){
				$sql = "update rb_user_sns
						   set rb_user = $userId
							 , rb_valid_yn = 'Y'
						 where rb_user_sns = ".$row[0]['rb_user_sns'];
				$db->query( $sql );
			}else{
				$result = "failed";
			}			
		}
		if( $result == "failed" ){
			header("location: /application.php?type=failed");
		}else{
			if( $_SESSION['vid'] == "" ){
				header( "location: /application.php" );
			}else{
				$vid = $_SESSION['vid'];
				header( "location: /addVideo.php?vid=".$vid );
			}
			
		}				
	}
}else{
	header("location: /start.php");	
}