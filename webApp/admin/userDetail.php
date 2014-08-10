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
<?php session_start(); ?>
<!DOCTYPE html>
<!--[if IE 8]><html lang="en" id="ie8" class="lt-ie9 lt-ie10"> <![endif]-->
<!--[if IE 9]><html lang="en" id="ie9" class="gt-ie8 lt-ie10"> <![endif]-->
<!--[if gt IE 9]><!-->
<html lang="en"> <!--<![endif]-->
<head>
    <title>Red Balloon</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">
       
	<?php 
		require("asset.php");
		require("../common/config.php");
		require("../common/DB_Connection.php");		
		require("../common/functions.php");
    	if( isset($_GET['id']) && $_GET['id'] != "" ){
			$userId = $_GET['id'];
			$sql = "select * from rb_user where rb_user = $userId";
			$dataUser = $db->queryArray( $sql );
			$dataUser = $dataUser[0];
			$type = "Edit";
		}else{
			$type = "Add";
		}    	
    	$pageNo = 1; 
	?>
	<link rel="stylesheet" type="text/css" href="http://www.datatables.net/media/blog/bootstrap_2/DT_bootstrap.css">
	
	<script type="text/javascript" src="js/jquery.dataTables.js"></script>
	<script type="text/javascript" src="js/DT_bootstrap.js"></script>
	<script type="text/javascript" src="js/userDetail.js"></script>		
</head>
<body>
<?php require_once("top.php"); ?>
<div class="container" style="min-height: 530px;">     
    <div class="row">
	    <?php require_once("leftMenu.php"); ?>
	   	 <div class="col-md-9">
			<div class="panel panel-green margin-bottom-40">
                <div class="panel-heading">
                    <h3 class="panel-title"><i class="icon-user"></i> User <?php echo $type;?></h3>
                </div>
                <div class="panel-body">
                	<div class="form-horizontal">
                		<input type="hidden" id="type" value="<?php echo $type;?>"/>
                		<input type="hidden" id="userId" value="<?php echo $userId?>"/>
                        <div class="form-group">
                            <label class="col-lg-2 control-label">Username</label>
                            <div class="col-lg-10">
                                <input type="text" value="<?php echo $dataUser['rb_username']?>" class="form-control" id="username" placeholder="Username">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-lg-2 control-label">Password</label>
                            <div class="col-lg-10">
                                <input type="password" class="form-control" id="password" placeholder="Password">
                                <?php if( $type == "Edit" ){?>
                                <span style="color:#777;font-size:12px;font-style:italic;">If you would like to change the password type a new one.Otherwise leave this blank.</span>
                                <?php } ?>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-lg-2 control-label">Name</label>
                            <div class="col-lg-10">
                                <input type="text" value="<?php echo $dataUser['rb_name']?>" class="form-control" id="name" placeholder="Name">
                            </div>
                        </div>  
                                              
                        <div class="form-group">
                            <label class="col-lg-2 control-label">Email Address</label>
                            <div class="col-lg-10">
                                <input type="text" value="<?php echo $dataUser['rb_email']?>" class="form-control" id="email" placeholder="Email Address">
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-lg-2 control-label">Photo</label>
                            <div class="col-lg-10">
								<form id="imageForm" method="post" enctype="multipart/form-data" action='/async-uploadImage.php' style="margin-bottom:0px;">
									<input type="file" name="imageUpload" id="imageUpload" class="form-control" style="width: 85%;float:left;"/>						
									<input type="hidden" name="uploadType" value="admin">
									<input type="hidden" id="imagePrevDiv" value="previewImage">
									<div id="previewImage" class="previewImage floatleft">
										<?php if( $type == "Edit" ){?>
										<img src="../<?php echo $dataUser['rb_photo'];?>" style="width:100%;height: 100%;"/>
										<?php }else{?>
										<img src="../<?php echo NO_PROFILE_PHOTO;?>" style="width:100%;height: 100%;"/>
										<?php } ?>
									</div>
									<div class="clearboth"></div>
								</form>
                            </div>
                        </div>                            
                        
                        <div class="form-group">
                            <label class="col-lg-2 control-label">Meri.to</label>
                            <div class="col-lg-10">
                            	<?php if( $type == "Edit" ){?>
                                	<input type="text" value="<?php echo $dataUser['rb_cred']?>" class="form-control" id="cred" placeholder="Merit">
                                <?php }else{ ?>
                                	<input type="text" value="0" class="form-control" id="cred" placeholder="Merit">
                                <?php } ?>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-lg-2 control-label">Admin Y/N</label>
                            <div class="col-lg-10">
                            	<select class="form-control" id="adminYn">
                            		<option value="Y" <?php if( $dataUser['rb_admin_yn'] == "Y" ) echo "selected"; ?>>Yes</option>
                            		<option value="N" <?php if( $dataUser['rb_admin_yn'] == "N" ) echo "selected"; ?>>No</option>
                            	</select>
                            </div>
                        </div>
                        <?php if( $type == "Edit" ){?>
	                        <div class="form-group">
	                            <label class="col-lg-2 control-label">Created Time</label>
	                            <div class="col-lg-10">
	                                <input type="text" value="<?php echo $dataUser['rb_created_time']?>" class="form-control" readonly style="background:#FEFEFE; cursor: pointer;" >
	                            </div>
	                        </div>
                        <?php }?>                        
                                                
                        <div class="form-group">
                            <div class="col-lg-offset-2 col-lg-10" style="text-align:center;">
                                <button class="btn-u btn-u-green" style="margin-right: 20px;width:90px;" onclick="onUserSave()"><i class="icon-edit"></i> Save</button>
                                <button class="btn-u btn-u-red" style="width:90px;" onclick="window.location.href='userList.php'"><i class="icon-list"></i> List</button>
                            </div>
                        </div>                                                                        
					</div>
				</div>
			</div>
		</div>
    </div>
</div>
</body>
</html>