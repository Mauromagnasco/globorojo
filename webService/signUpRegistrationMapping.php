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

    $result = "success";
    $error = "";
    $data = array();
    
    $userSnsId = mysql_escape_string($_POST['userSnsId']);
    $userId = mysql_escape_string($_POST['userId']);
    
    $sql = "select * from rb_user_sns where rb_user_sns = $userSnsId";
    $dataUserSns = $db->queryArray( $sql );
    $dataUserSns = $dataUserSns[0];
    $snsType = $dataUserSns['rb_sns_type'];
    
    $sql = "select * from rb_user_sns where rb_user = $userId and rb_sns_type = $snsType";
    $dataUserSns = $db->queryArray( $sql );
    if( $dataUserSns == null ){
    	$sql = "update rb_user_sns
    			   set rb_user = $userId
    			     , rb_valid_yn = 'Y'
    			 where rb_user_sns = $userSnsId";
    	$db->query( $sql );    	
    }else{
    	$result = "failed";
    	$error = $snsType;
    }

    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
