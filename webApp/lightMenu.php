		<div id="menuList" class="menuList">
			<!-- div class="menuItem menuItemLight" onclick="window.location.href = 'home.php';">
				HOME
				<img src="img/iconHome.png" class="menuItemImg"/>
			</div -->
			<div class="menuItem menuItemDark" onclick="window.location.href = 'search.php';">
				WATCH
				<img src="img/iconSearch.png" class="menuItemImg"/>
			</div>
			<div class="menuItem menuItemLight <?php if( $isNotification == "Y") echo 'menuItemRed';?>" onclick="window.location.href = 'notification.php';">
				NOTIFICATIONS
				<img src="img/icon<?php if( $isNotification == "Y") echo 'Red';?>Notification.png" class="menuItemImg"/>
			</div>
			<div class="menuItem menuItemDark"  onclick="window.location.href = 'addVideo.php';">
				SHARE
				<img src="img/iconCreate.png" class="menuItemImg"/>
			</div>
			<div class="menuItem menuItemLight"  onclick="window.location.href = 'profile.php';">
				PROFILE
				<img src="img/iconProfile.png" class="menuItemImg"/>
			</div>
			<?php if( $isProfileMenu == "Y" ){?>
			<div class="menuItem menuItemDark"  onclick="onProfileLogOut()">
				LOG OUT
				<img src="img/iconLogout.png" class="menuItemImg"/>
			</div>
			<?php } ?>
		</div>