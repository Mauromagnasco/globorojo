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
<!--[if IE 8]> <html lang="en" class="ie8"> <![endif]-->  
<!--[if IE 9]> <html lang="en" class="ie9"> <![endif]-->  
<!--[if !IE]><!--> <html lang="en"> <!--<![endif]-->  
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
		$pageNo = 1;
	?>
	<link rel="stylesheet" type="text/css" href="http://www.datatables.net/media/blog/bootstrap_2/DT_bootstrap.css">
	
	<script type="text/javascript" src="js/jquery.dataTables.js"></script>
	<script type="text/javascript" src="js/DT_bootstrap.js"></script>
	<script type="text/javascript" src="js/userList.js"></script>		
</head>

<body>

<?php require_once("top.php"); ?>

<div class="container" style="min-height: 530px;">     
    <div class="row">
		<?php require_once("leftMenu.php"); ?>
        <div class="col-md-9">
			<div class="panel panel-sea margin-bottom-40">
				<div class="panel-heading">
					<h3 class="panel-title floatleft" style="line-height:30px;"><i class="icon-user"></i> User List</h3>
					<button class="floatright btn-u btn-u-red" onclick="onDeleteUser()" style="width: 90px;"><i class="icon-trash"></i> Delete</button>
					<button class="floatright btn-u btn-u-blue" onclick="onAddUser()" style="margin-right:10px;width: 90px;"><i class="icon-plus"></i> Add</button>
					<div class="clearboth"></div>
				</div>
				<?php
					$sql = "select * 
							  from rb_user";
					$dataUser = $db->queryArray( $sql ); 
				?>
				<table class="table table-striped" id="example">
					<thead>
						<tr>
							<th style="width:60px;"><input type="checkbox" id="checkAll" onclick="onCheckAll( this )"/></th>
							<th style="width:60px;">No</th>
							<th>Username</th>
							<th>Email</th>
							<th>Name</th>
							<th>Photo</th>
							<th>Meri.to</th>
							<th>Created Time</th>
						</tr>
					</thead>
					<tbody>
						<?php for($i = 0 ; $i < count( $dataUser); $i ++ ){?>
						<tr>
							<td><input type="checkbox" id="chkUserId" value="<?php echo $dataUser[$i]['rb_user']; ?>"/></td>
							<td><?php echo $i + 1; ?></td>
							<td><a href="userDetail.php?id=<?php echo $dataUser[$i]['rb_user']; ?>"/><?php echo $dataUser[$i]['rb_username']; ?></a></td>
							<td><a href="userDetail.php?id=<?php echo $dataUser[$i]['rb_user']; ?>"/><?php echo $dataUser[$i]['rb_email']; ?></a></td>
							<td><a href="userDetail.php?id=<?php echo $dataUser[$i]['rb_user']; ?>"/><?php echo $dataUser[$i]['rb_name']; ?></a></td>
							<td><img src="<?php echo $dataUser[$i]['rb_photo']; ?>" style="width:32px;height:32px;"/></td>
							<td><a href="userDetail.php?id=<?php echo $dataUser[$i]['rb_cred']; ?>"/><?php echo $dataUser[$i]['rb_cred']; ?></a></td>
							<td><a href="userDetail.php?id=<?php echo $dataUser[$i]['rb_cred']; ?>"/><?php echo $dataUser[$i]['rb_created_time']; ?></a></td>														
						</tr>
						<?php } ?>
					</tbody>
				</table>
			</div>        			       
        </div>
    </div>          
</div>     
<?php require_once("footer.php"); ?>
</body>
</html> 