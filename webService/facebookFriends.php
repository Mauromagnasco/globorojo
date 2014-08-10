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
    require_once("../common/checkAuth.php");
    
    function curl_get_file_contents($URL) {
    	$c = curl_init();
    	curl_setopt($c, CURLOPT_RETURNTRANSFER, 1);
    	curl_setopt($c, CURLOPT_URL, $URL);
    	$contents = curl_exec($c);
    	$err  = curl_getinfo($c,CURLINFO_HTTP_CODE);
    	curl_close($c);
    	if ($contents) return $contents;
    	else return FALSE;
    }    

    $result = "success";
    $error = "";
    $data = array();    
    $userId = mysql_escape_string($_POST['userId']);
    $sql = "select * from rb_user_sns where rb_user = $userId and rb_sns_type = 1";
    $dataSnsUser = $db->queryArray( $sql );
    if( $dataSnsUser == null ){
    	$result = "failed";
    }else{
    	$strSnsIds = "";
    	$token = $dataSnsUser[0]['rb_token'];
    	$snsUserId = $dataSnsUser[0]['rb_sns_id'];
    	
    	$graph_url = "https://graph.facebook.com/me?access_token=".$token;
    	$response = curl_get_file_contents($graph_url);
    	$decoded_response = json_decode($response);
    	if( $decoded_response->error ){
    		$oldToken = $token;
    		$url = "https://graph.facebook.com/oauth/access_token?client_id=".FACEBOOK_APP_ID."&client_secret=".FACEBOOK_APP_SECRET."&grant_type=fb_exchange_token&fb_exchange_token=$oldToken";
    		$result = file_get_contents($url);
    		parse_str( $result, $get_array);
    		$newToken = $get_array["access_token"];
    		$sql = "update rb_user_sns
    				   set rb_token = '$newToken'
    				 where rb_user_sns = $snsUserId";
    		$db->query( $sql );
    		$token = $newToken;
    	}
    	
    	$url = "https://graph.facebook.com/$snsUserId/friends?access_token=$token";
    	$json = file_get_contents( $url );
    	$jsonUserList = json_decode( $json, true );
    	for( $i = 0 ; $i < count( $jsonUserList['data']); $i++ ){
    		$strSnsIds.="'".$jsonUserList['data'][$i]['id']."'";
    		if( $i != count( $jsonUserList['data']) - 1 )
    			$strSnsIds = $strSnsIds.",";
    	}
    	$sql = "select t2.* 
    			  from rb_user_sns t1, rb_user t2
    			 where t1.rb_sns_type = 1
    			   and t1.rb_sns_id in ( $strSnsIds )
    			   and t1.rb_user = t2.rb_user";
    	$friendList = $db->queryArray( $sql );
    	if( $friendList == null )
    		$friendList = array( );
    	for( $i = 0; $i < count( $friendList ); $i ++ ){
    		$friendList[$i]['rb_photo'] = RB_photoURL( $friendList[$i]['rb_photo'] ); 
    	}
    	$data['userList'] = $friendList;
    }
	
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>