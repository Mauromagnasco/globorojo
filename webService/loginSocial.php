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
    
    $snsId = mysql_escape_string($_POST['snsId']);
    $snsType = mysql_escape_string($_POST['snsType']);
    
    $sql = "select * from rb_user_sns where rb_sns_type = '$snsType' and rb_sns_id = '$snsId' and rb_user is not null";
    $dataUser = $db->queryArray( $sql );
    if( $dataUser == null ){
    	$result = "failed";
    	$error = "This account is not registered.";
    }else{
    	$dataUser = $dataUser[0];
    	$userId = $dataUser["rb_user"];
    	$data['userId'] = $userId;
    }
    
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);
?>
