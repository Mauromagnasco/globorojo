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
    
    $email = mysql_escape_string($_POST['email']);
    $sql = "select * from rb_user where rb_email = '$email'";
    $dataResult = $db->queryArray( $sql );
    if( $dataResult == null ){
    	$result = "failed";
    	$error = "This Email Address is not exist.";
    }else{
	    $password = RB_generateRandom( 8 );
	    
	    $subject = "Forgot your password?";
	    $message = "Your password has been reset.\n\r";
	    $message.= "This is your new password : $password";
	    RB_sendEmail( $email, $message, $subject );
	
	    $sql = "update rb_user
	    		   set rb_password = md5('$password')
	      		 where rb_email = '$email'";
	    $db->query( $sql );
	}
    
    
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);
    exit();    
?>
