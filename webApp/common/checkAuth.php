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
	$header = getallheaders();
	$clientMicrotime = mysql_escape_string( $header['X-MICROTIME'] );
	$clientHash = mysql_escape_string( $header['X-HASH'] );
	$serverMicrotime = microtime(true);
	$timeDiff = abs($serverMicrotime - $clientMicrotime);
	
	// logToFile("data.log", "C-TIME : $clientMicrotime");
	// logToFile("data.log", "C-HASH : $clientHash");
	// logToFile("data.log", "S-TIME : $serverMicrotime");
		
	// Check Timestamp
	if( $timeDiff > 60 * 60 * 24 ){
		$data = array();
		$data['result'] = "expired_request";
		header('Content-Type: application/json');
		echo json_encode($data);
		exit();
	}else{
		$serverHash = sha1( base64_encode( $clientMicrotime."-".APP_SECRET_KEY) );
		// logToFile("data.log", "S-HASH : $serverHash");
		if( $clientHash != $serverHash ){
			$data = array();
			$data['result'] = "expired_request";
			header('Content-Type: application/json');
			echo json_encode($data);
			exit();			
		}
	}
		
?>