#!/bin/bash
#####################################################
# LANDesk Agent framework uninstaller
# Description: script to remove landesk agent
# components.
#
# Note: do not use 'rm -rf' on  directories.  Use the
# remove_landesk_dir or one of the other remove_dir
# functions.  They are safer and will protect you
# from making silly mistakes.
#####################################################
REMOVED=0
CLEAN=0
PKGUTIL=
SCRIPT=`/usr/bin/basename $0`
[ -x /usr/sbin/pkgutil ] && PKGUTIL=/usr/sbin/pkgutil

if [ `/usr/bin/id -u` -ne 0 ]; then
	echo "Uninstalling the LANDesk agent requires administrative priveleges."
	echo "Please enter your password to continue or press CTRL-C to cancel."
	sudo "$0" "$@"
	exit 0
fi


function show_help()
{
	echo "LANDesk agent uninstaller"
	echo "Usage: $SCRIPT [ -h | -c ]"
	echo "  options: "
	echo "     -h			Show this help message"
	echo "     -c           Force the uninstall and completely remove the install directories."
	echo "                  The default is to only remove empty directories."
	echo ""
}

function remove_flat_receipt( )
{
	RDIR=$1
	[ -z "$RDIR" ] && fatal "remove_flat_receipt(${RDIR}) must be passed a valid application name"
	# remove the receipt file
	if [ -d /Library/Receipts/$RDIR ]; then
		echo "removing receipt for: $RDIR "
		rm -rf /Library/Receipts/$RDIR
		[ "$?" != "0" ] && ( echo "ERROR: failed to remove receipt: $RDIR. \n\t$!"; exit 1 )
		((REMOVED++))
	fi
}

function remove_database_receipt( )
{
	OBJ=$1
	[ -z "$OBJ" ] && fatal "remove_database_receipt(${OBJ}) must be passed a valid application name"
	if [ -n "$PKGUTIL" ]; then
		RES=`$PKGUTIL --pkgs | grep $OBJ`
		if [ -n "$RES" ]; then
			echo "Removing receipt database entry for: $OBJ "
			$PKGUTIL --forget $OBJ
		fi
	fi

}

function remove_framework_dir()
{
	FDIR=$1
	echo "Checking $FDIR"
	[ -z "$FDIR" ] && fatal "remove_framework_dir(${FDIR}) must be passed a valid directory"
	# remove the framework directory
	if [ -d /System/Library/Frameworks/${FDIR} ]; then
		echo "removing framework installation: $FDIR"
		rm -rf /System/Library/Frameworks/${FDIR}
		[ "$?" != "0" ] && ( echo "ERROR: failed to remove framework: ${FDIR}  \n\t$!"; exit 1 )
		((REMOVED++))
	fi
}

function remove_LaunchDaemon()
{
	FNAME=$1
	[ -z "$FNAME" ] && fatal "remove_LaunchDaemon(${FNAME}) must be passed a valid file name"
	# remove the framework directory
	if [ -e /Library/LaunchDaemons/${FNAME} ]; then
		echo "removing LaunchDaemon: $FNAME"
		rm -f /Library/LaunchDaemons/${FNAME}
		[ "$?" != "0" ] && ( echo "ERROR: failed to remove file: ${FNAME}  \n\t$!"; exit 1 )
		((REMOVED++))
	fi

}

function unload_LaunchAgent()
{
    FNAME=$1
    [ -z "$FNAME" ] && fatal "remove_LaunchAgent(${FNAME}) must be passed a valid file name"

    # unload launch agent
    if [ -f /Library/Application\ Support/LANDesk/bin/launchInContext.sh ]  && [ -e /Library/LaunchAgents/${FNAME} ]; then
        echo "unloading LaunchAgent: $FNAME"
        /Library/Application\ Support/LANDesk/bin/launchInContext.sh console /bin/launchctl unload -S Aqua /Library/LaunchAgents/${FNAME}
        [ "$?" != "0" ] && ( echo "ERROR: failed to unload file: ${FNAME}  \n\t$!"; exit 1 )
    fi
}

function remove_LaunchAgent()
{
	FNAME=$1
	[ -z "$FNAME" ] && fatal "remove_LaunchAgent(${FNAME}) must be passed a valid file name"
	# remove the framework directory
	if [ -e /Library/LaunchAgents/${FNAME} ]; then
		echo "removing LaunchAgent: $FNAME"
		rm -f /Library/LaunchAgents/${FNAME}
		[ "$?" != "0" ] && ( echo "ERROR: failed to remove file: ${FNAME}  \n\t$!"; exit 1 )
		((REMOVED++))
	fi

}

function remove_startup()
{
	FNAME=$1
	[ -z "$FNAME" ] && fatal "remove_startup(${FDIR}) must be passed a valid file name"
	# remove the startup item
	if [ -d "/Library/StartupItems/${FNAME}" ]; then
		echo "removing launch daemon: $FDIR"
		rm -rf "/Library/StartupItems/${FNAME}"
		[ "$?" != "0" ] && ( echo "ERROR: failed to remove file: ${FNAME}  \n\t$!"; exit 1 )
		((REMOVED++))
	fi

}

function remove_Preferences()
{
	FNAME=$1
	[ -z "$FNAME" ] && fatal "remove_Preferences(${FNAME}) must be passed a valid file name"
	# remove the preferences file
	if [ -e "/Library/Preferences/${FNAME}" ]; then
		echo "removing Preference: ${FNAME}"
		defaults delete "/Library/Preferences/${FNAME}"
		[ "$?" != "0" ] && ( echo "ERROR: failed to remove file: ${FNAME}  \n\t$!"; exit 1 )
		((REMOVED++))
	fi
}


function remove_PreferencePane()
{
	FNAME="$@"
	[ -z "$FNAME" ] && fatal "remove_PreferencePane(${FNAME}) must be passed a valid dir name"
	# remove the preference pane directory
	if [ -d "/Library/PreferencePanes/${FNAME}.prefPane" ]; then
		echo "removing Preference: $FNAME"
		rm -rf "/Library/PreferencePanes/${FNAME}.prefPane"
		[ "$?" != "0" ] && ( echo "ERROR: failed to remove file: ${FNAME}  \n\t$!"; exit 1 )
		((REMOVED++))
	fi
}

function remove_application_support_application()
{
	FNAME=$1
	[ -z "$FNAME" ] && fatal "remove_application_support_application(${FDIR}) must be passed a valid dir name"
	# remove the preference pane directory
	if [ -d "/Library/Application Support/${FNAME}" ]; then
		echo "removing Application Support directory: $FNAME"
		rm -rf "/Library/Application Support/${FNAME}"
		[ "$?" != "0" ] && ( echo "ERROR: failed to remove file: ${FNAME}  \n\t$!"; exit 1 )
		((REMOVED++))
	fi
}

function remove_landesk_dir()
{
	DNAME=$1
	[ -z "$DNAME" ] && fatal "remove_landesk_dir(${DNAME}) must be passed a valid dir name"
	# remove the landesk directory named:
	if [ -d "/usr/local/LANDesk/${DNAME}" ]; then
		echo "removing LANDesk directory: $DNAME"
		rm -rf "/usr/local/LANDesk/${DNAME}"
		[ "$?" != "0" ] && ( echo "ERROR: failed to remove file: ${DNAME}  \n\t$!"; exit 1 )
		((REMOVED++))
	fi
	if [ -d "/usr/LANDesk/${DNAME}" ]; then
		echo "removing LANDesk directory: $DNAME"
		rm -rf "/usr/LANDesk/${DNAME}"
		[ "$?" != "0" ] && ( echo "ERROR: failed to remove file: ${DNAME}  \n\t$!"; exit 1 )
		((REMOVED++))
	fi
	if [ -d "/opt/landesk/${DNAME}" ]; then
		echo "removing LANDesk directory: $DNAME"
		rm -rf "/opt/landesk/${DNAME}"
		[ "$?" != "0" ] && ( echo "ERROR: failed to remove file: ${DNAME}  \n\t$!"; exit 1 )
		((REMOVED++))
	fi
}

function remove_landesk_files()
{
	for DNAME in "$@"; do
		[ -z "$DNAME" ] && fatal "remove_landesk_file(${DNAME}) must be passed a valid filek name"
		# remove the landesk directory named:
		if [ -f "/usr/local/LANDesk/${DNAME}" ]; then
			echo "removing LANDesk file: $DNAME"
			rm -f "/usr/local/LANDesk/${DNAME}"
			[ "$?" != "0" ] && ( echo "ERROR: failed to remove file: ${DNAME}  \n\t$!"; exit 1 )
			((REMOVED++))
		fi
		if [ -f "/usr/LANDesk/${DNAME}" ]; then
			echo "removing LANDesk file: $DNAME"
			rm -f "/usr/LANDesk/${DNAME}"
			[ "$?" != "0" ] && ( echo "ERROR: failed to remove file: ${DNAME}  \n\t$!"; exit 1 )
			((REMOVED++))
		fi
		if [ -f "/opt/landesk/${DNAME}" ]; then
			echo "removing LANDesk file: $DNAME"
			rm -f "/opt/landesk/${DNAME}"
			[ "$?" != "0" ] && ( echo "ERROR: failed to remove file: ${DNAME}  \n\t$!"; exit 1 )
			((REMOVED++))
		fi
	done
}

function remove_landesk_links()
{
	for DNAME in "$@"; do
		[ -z "$DNAME" ] && fatal "remove_landesk_link(${DNAME}) must be passed a valid symlink name"
		# remove the landesk directory named:
		if [ -h "/usr/local/LANDesk/${DNAME}" ]; then
			echo "removing LANDesk link: $DNAME"
			rm -f "/usr/local/LANDesk/${DNAME}"
			[ "$?" != "0" ] && ( echo "ERROR: failed to remove link: ${DNAME}  \n\t$!"; exit 1 )
			((REMOVED++))
		fi
		if [ -h "/usr/LANDesk/${DNAME}" ]; then
			echo "removing LANDesk link: $DNAME"
			rm -f "/usr/LANDesk/${DNAME}"
			[ "$?" != "0" ] && ( echo "ERROR: failed to remove link: ${DNAME}  \n\t$!"; exit 1 )
			((REMOVED++))
		fi
		if [ -h "/opt/landesk/${DNAME}" ]; then
			echo "removing LANDesk link: $DNAME"
			rm -f "/opt/landesk/${DNAME}"
			[ "$?" != "0" ] && ( echo "ERROR: failed to remove link: ${DNAME}  \n\t$!"; exit 1 )
			((REMOVED++))
		fi
	done
}


function remove_sharedtech()
{
	remove_Preferences com.landesk.cba8.plist
	remove_Preferences com.landesk.msgsys.plist
	remove_Preferences com.landesk.broker.plist

	if [ -e /Library/StartupItems/cba8/cba8 ]; then
		/Library/StartupItems/cba8/cba8 stop
	fi
	remove_startup cba8

	remove_LaunchDaemon com.landesk.pds.plist
	remove_LaunchDaemon com.landesk.pds1.plist
	remove_LaunchDaemon com.landesk.pds2.plist
	remove_LaunchDaemon com.landesk.msgsys.plist
	remove_LaunchDaemon com.landesk.cba8.plist
	remove_LaunchDaemon com.landesk.broker.plist
	remove_LaunchDaemon com.landesk.rotatelog.plist
	remove_LaunchDaemon com.landesk.reboot.plist
	remove_LaunchDaemon com.landesk.vulscan.plist
	remove_LaunchDaemon com.landesk.dispatch.plist
	remove_LaunchDaemon com.landesk.ldlaunch_daemon.plist
	remove_LaunchDaemon com.landesk.scheduler.plist
	remove_LaunchDaemon com.landesk.ldwatch.plist
	remove_LaunchAgent com.landesk.ldusermenu.plist
	remove_LaunchAgent com.landesk.hideScreen.plist
	remove_LaunchAgent com.landesk.ldswprogress.plist
	remove_LaunchAgent com.landesk.remotelaunch.plist
	remove_LaunchAgent com.landesk.dispatch.pl.plist
	remove_LaunchAgent com.landesk.dispatch.ui.plist
	remove_LaunchAgent com.landesk.dispatch.sui.plist
	remove_LaunchAgent com.landesk.ldlaunch_daemon.plist
	remove_LaunchAgent com.landesk.ldNotificationMonitor.plist
	remove_LaunchAgent com.landesk.logged_in.plist
	remove_LaunchAgent com.landesk.logged_out.plist
	remove_LaunchAgent com.landesk.ldwatch.plist
    remove_LaunchAgent com.landesk.ldNotificationMonitor.plist
    remove_LaunchAgent com.landesk.lockscreen.plist

	echo "removing SharedTech: "

	remove_landesk_files  common/{addhandler,makekey,sha1tool,shutdownhandler.sh}
	remove_landesk_files  common/{reboothandler.sh,cba8_uninstall.sh,alert}
	remove_landesk_files  common/{resetguard,cba,proxyhost,ldpgp}
	remove_landesk_files  common/{alertrender,postbsa,ldnacgi,httpclient,ldpds1}
	remove_landesk_files  common/{brokerconfig,pds2_uninstall.sh,pds2d,pds2dis,poweroff.exe,uniqueid}
	remove_landesk_files  common/cbaroot/certs/064eb6a5.0
	remove_landesk_files  common/cbaroot/allowed/{cba8.crt,logodk.gif,hdr_lsdk.gif,ldping,index.tmpl}
	remove_landesk_files  common/cbaroot/services/{filexfer,exec}
	remove_landesk_files  common/cbaroot/alert/alert.xml
	remove_landesk_files  common/stop.time
	remove_landesk_files  common/start.time
	remove_landesk_links /bin/{addhandler,alert,cba,alertrender,makekey,httpclient,ldpgp,ldping,proxyhost}
	remove_landesk_links /bin/{resetguard,sha1tool,shutdownhandler.sh,reboothandler.sh,postbsa,ldnacgi,httpclient}


	cd /opt/landesk/
	STRING_FILES=`ls common/*strings.xml`
	for FILENAME in $STRING_FILES; do
		remove_landesk_files  ${FILENAME}
	done


	#rm -f /opt/landesk/bin/{addhandler,makekey,sha1tool,shutdownhandler.sh,reboothandler.sh,cba8_uninstall.sh}
	#rm -f /opt/landesk/bin/{aler,resetguard,cba,proxyhost,ldpgp,alertrender,postbsa,ldnacgi,httpclient}
	#rm -f /opt/landesk/etc/cbaroot/certs/064eb6a5.0
	#rm -f /opt/landesk/etc/cbaroot/allowed/{cba8.crt,logodk.gif,hdr_lsdk.gif,ldping,index.tmpl}
	#rm -f /opt/landesk/etc/cbaroot/services/{filexfer,exec}
	#rm -f /opt/landesk/etc/cbaroot/alert/alert.xml
	#rm -f /opt/landesk/bin/{addhandler,alert,cba,alertrender,makekey,httpclient,ldpgp,ldping,proxyhost}
	#rm -f /opt/landesk/bin/{resetguard,sha1tool,shutdownhandler.sh,reboothandler.sh,postbsa,ldnacgi,httpclient}
	[ -e /etc/pam.d/cba8 ] && rm -f /etc/pam.d/cba8
	[ -e /etc/xinetd.d/cba8 ] && rm -f /etc/xinetd.d/cba8

	remove_landesk_dir common/cbaroot
	remove_landesk_dir Resources
	remove_landesk_dir common

	/usr/bin/killall -HUP xinetd
}

function remove_crontab()
{
	# remove the crontab
	local crontabTag="# ldms"									# used to determine if the crontab file has already setup
	local installed=`sudo crontab -l -u root | grep -c '# ldms'`
	if [ $installed -gt 0 ]; then
		sudo crontab -l | sed '/ldms/d' | sudo crontab -
	fi
}

function remove_firewall()
{
	# remove the port exceptions we put in the firewall at installation
	if [ -e "/Library/Preferences/com.apple.sharing.firewall.plist" ]; then
		local saveDir=`pwd`
		cd /Library/Application\ Support/LANDesk/bin/
		echo `pwd`
		echo "Removing LANDesk Remote Control port exceptions"
		sudo ./ldxmlutil -d -f /Library/Preferences/com.apple.sharing.firewall.plist -k "/firewall/LANDesk Remote Control"
		echo "Removing LANDesk Trageted Multicast port exceptions"
		sudo ./ldxmlutil -d -f /Library/Preferences/com.apple.sharing.firewall.plist -k "/firewall/LANDesk Targeted Multicast"
		echo "Removing LANDesk CBA8 port exceptions"
		sudo ./ldxmlutil -d -f /Library/Preferences/com.apple.sharing.firewall.plist -k "/firewall/LANDesk CBA8"
		cd $saveDir
		echo `pwd`
	fi
	if [ -e "/System/Library/PrivateFrameworks/NetworkConfig.framework/Versions/Current/Resources/firewalltool" ]; then
		sudo /System/Library/PrivateFrameworks/NetworkConfig.framework/Versions/Current/Resources/firewalltool
	else
		echo "Warning the firewall must be restarted"
	fi
}

function remove_framework()
{
	# remove agent framework
	echo "Removing agent framework"
	remove_flat_receipt "LANDeskAgentFramework.pkg"
	remove_database_receipt "LANDeskAgent.framework"
	remove_framework_dir "LANDeskAgent.framework"
}

function remove_pkg_receipts()
{
	remove_flat_receipt "ldslm.pkg"
	remove_flat_receipt "agentconfig.pkg"
	remove_flat_receipt "brokerconfig.pkg"
	remove_flat_receipt "vulscan.pkg"
	remove_flat_receipt "swd.pkg"
	remove_flat_receipt "stuffitutility9.pkg"
	remove_flat_receipt "stuffitutility10.pkg"
	remove_flat_receipt "sharedtech.pkg"
	remove_flat_receipt "remotecontrol.pkg"
	remove_flat_receipt "ldusermenu.pkg"

	remove_database_receipt "com.landesk.agent.sharedtech"
	remove_database_receipt "com.landesk.stuffitutility9"
	remove_database_receipt "com.landesk.stuffitutility10"
	remove_database_receipt "com.landesk.agent.configui"
	remove_database_receipt "com.landesk.agent.ldslm"
	remove_database_receipt "com.landesk.agent.remotecontrol"
	remove_database_receipt "com.landesk.agent.swd"
	remove_database_receipt "com.landesk.agent.vulscan"
	remove_database_receipt "com.landesk.agent.brokerconfig"
	remove_database_receipt "com.landesk.agent.ldusermenu"

}

function remove_config_app()
{
	DNAME=$1
	[ -z "$DNAME" ] && fatal "remove_config_apps(${DNAME}) must be passed a valid dir name"
	# remove the landesk directory named:
	if [ -d "/Applications/Utilities/${DNAME}" ]; then
		echo "removing LANDesk application: $DNAME"
		rm -rf "/Applications/Utilities/${DNAME}"
		[ "$?" != "0" ] && ( echo "ERROR: failed to remove file: ${DNAME}  \n\t$!"; exit 1 )
		((REMOVED++))
	fi
}

function remove_Fuze()
{
	DNAME=$1
	[ -z "$DNAME" ] && fatal "remove_config_apps(${DNAME}) must be passed a valid dir name"
	# remove the landesk directory named:
	if [ -d "/Applications/${DNAME}" ]; then
		echo "removing LANDESK: $DNAME"
		rm -rf "/Applications/${DNAME}"
		[ "$?" != "0" ] && ( echo "ERROR: failed to remove file: ${DNAME}  \n\t$!"; exit 1 )
		((REMOVED++))
	fi
}


function remove_baseagent()
{
	#remove baseagent
	remove_flat_receipt "baseagent.pkg"
	remove_database_receipt "baseagent"

	remove_landesk_files common/{sendstatus,alertsync,ldcron,lddaemon,ldwatch,ldiscan,ldxmlutil}
	remove_landesk_files common/{ldpds1,brokerconfig,pds2_uninstall.sh,pds2d,pds2dis,poweroff.exe,uniqueid}

	remove_landesk_links bin/{sendstatus,alertsync,ldcron,lddaemon,ldwatch,ldiscan,ldxmlutil}

	remove_LaunchDaemon com.landesk.ldwatch.plist
	remove_Preferences com.landesk.ldms.plist
	# remove preference panes
	remove_PreferencePane "LANDesk Agent"
	remove_PreferencePane "LANDesk Client"
	remove_startup LANDesk
	remove_application_support_application LANDesk

	remove_config_app "LANDesk Agent.app"

	remove_landesk_dir data common
}

function remove_gateway()
{
	remove_config_app "LANDesk Management Gateway.app"
}

function remove_tmc()
{
	remove_LaunchDaemon com.landesk.ldtmc.plist
}

function remove_swd()
{
	remove_LaunchDaemon com.landesk.remote.plist
	remove_landesk_links common/{ldgidget,ldkahuna,sdclient}
}

function remove_rc()
{
	echo "removing rc files"

}

function remove_ldav()
{
# only remove if we installed application
# check /Library/LaunchDaemons/com.landesk.ldav.plist for Disabled
# this will only be set to false if Kaspersky was installed by ldinstallav

	output=""

	if [ -e /Library/LaunchDaemons/com.landesk.ldav.plist ]; then
		output=`/usr/libexec/PlistBuddy -c "print Disabled" /Library/LaunchDaemons/com.landesk.ldav.plist`
		if [ "$?" -eq "0" ] && [ "$output" == "false" ]; then
			echo "detected /Library/LaunchDaemons/com.landesk.ldav.com:Disabled  = ${output}"
			echo "Uninstall Kaspersky AV"
			if [ -e '/Library/Application Support/LANDesk/bin/ldinstallav' ]; then
				/Library/Application\ Support/LANDesk/bin/ldinstallav /uninstall
			fi
			if [ -e '/Library/Application Support/Kaspersky Lab' ]; then
				rm -rf '/Library/Application Support/Kaspersky Lab'
			fi
		fi
	fi

	remove_LaunchDaemon com.landesk.ldav.plist
    remove_LaunchAgent com.landesk.ldav.agent.plist
}

function cleanup_directories()
{
	echo "Attempting to remove directory structure..."
	ECNT=0

	if [ -d "/usr/local/LANDesk" ]; then
		if [ $CLEAN -ne 0 ]; then
			rm -rf "/usr/local/LANDesk"
			return;
		fi
		if [ -d "/usr/local/LANDesk/common" ]; then
			rmdir "/usr/local/LANDesk/common"
			[ $? -eq 0 ] && ((ECNT++))
		fi
		if [ -d "/usr/local/LANDesk/bin" ]; then
			rmdir "/usr/local/LANDesk/bin"
			[ $? -eq 0 ] && ((ECNT++))
		fi

		if [ $ECNT -eq 0 ]; then
			rmdir "/usr/local/LANDesk";
		fi
	fi
	if [ -d "/usr/LANDesk" ]; then
		if [ $CLEAN -ne 0 ]; then
			rm -rf "/usr/LANDesk"
			return;
		fi
		if [ -d "/usr/LANDesk/common" ]; then
			rmdir "/usr/LANDesk/common"
			[ $? -eq 0 ] && ((ECNT++))
		fi
		if [ -d "/usr/LANDesk/bin" ]; then
			rmdir "/usr/LANDesk/bin"
			[ $? -eq 0 ] && ((ECNT++))
		fi

		if [ $ECNT -eq 0 ]; then
			rmdir "/usr/LANDesk";
		fi
	fi
	if [ -d "/opt/landesk" ]; then
		if [ $CLEAN -ne 0 ]; then
			rm -rf "/opt/landesk"
			return;
		fi
		if [ -d "/opt/landesk/common" ]; then
			rmdir "/usr/local/LANDesk/common"
			[ $? -eq 0 ] && ((ECNT++))
		fi
		if [ -d "/opt/landesk/bin" ]; then
			rmdir "/usr/local/LANDesk/bin"
			[ $? -eq 0 ] && ((ECNT++))
		fi

		if [ $ECNT -eq 0 ]; then
			rmdir "/opt/landesk";
		fi
	fi
	[ -e /tmp/postinstaller ] && rm -f /tmp/postinstaller
	[ -e /tmp/LDMSClient.mpkg.zip ] && rm -f /tmp/LDMSClient.mkpg.zip
	[ -e /tmp/LDMSClient.mpkg ] && rm -f /tmp/LDMSClient.mkpg
}

function killAllProcs(  )
{
	sudo /usr/bin/killall $1
	/bin/ps ax | /usr/bin/grep $1 | grep -v grep | /usr/bin/awk '{print $1}' | /usr/bin/xargs sudo kill -9
}

function stop_processes()
{
	# stop our processes

	if [ -e "/Library/LaunchDaemons" ]; then
		[ -f /bin/launchctl ] && /bin/launchctl unload /Library/LaunchDaemons/com.landesk.*
		[ -f /bin/launchctl ] && /bin/launchctl unload /Library/LaunchAgents/com.landesk.*
		killAllProcs "ldslm"
		killAllProcs "ldtmc"
		killAllProcs "ldcron"
		killAllProcs "lddaemon"
		killAllProcs "LDUserMenu"
		killAllProcs "ldremotelaunch"
		killAllProcs "ldNotificationMonitor"
		killAllProcs "LANDesk Agent"
		killAllProcs "ldav"
	else
		killAllProcs "ldwatch"
		killAllProcs "ldcba"
		killAllProcs "ldslm"
		killAllProcs "ldremote"
		killAllProcs "ldtmc"
		killAllProcs "ldcron"
		killAllProcs "lddaemon"
	fi
}

function remove_crashlogs()
{
	# remove user crash logs
	local loglist="ldcba ldremote ldscan ldwatch ldorwell ldobserve ldremotemenu"

	for app in $loglist
	do
		if [ -e "~/Library/Logs/CrashReporter/$app.crash.log" ]; then
			echo " removing user $app.crash.log"
			sudo rm "~/Library/Logs/CrashReporter/$app.crash.log"
			((REMOVED++))
		fi

		if [ -e "/Library/Logs/CrashReporter/$app.crash.log" ]; then
			echo " removing system $app.crash.log"
			sudo rm "/Library/Logs/CrashReporter/$app.crash.log"
			((REMOVED++))
		fi
	done
}

function remove_pidfiles()
{
	if [ -e "/var/run/landesk" ]; then
		echo " removing pid files"
		sudo rm -r "/var/run/landesk"
		((REMOVED++))
	fi
}

function remove_xinetd_files
{
	# remove Xinet files
	local doomedFiles="LANDeskCBA ldpds1 ldpds2 cba8 pds2"
	for target in $doomedFiles; do

		if [ -e "/etc/xinetd.d/$target" ]; then
			echo " removing $target xinet files"
			sudo rm "/etc/xinetd.d/$target"
			((REMOVED++))
		fi
	done
}

function remove_netinfo_entries()
{
	# get our system version
	local sysVersion=$(uname -r)
	local sysMajorVersion=${sysVersion%%.*}
	local tempMinorVersion=${sysVersion#*.}
	local sysMinorVersion=${tempMinorVersion%%.*}

	if [ $sysMajorVersion -lt 8 ] ; then
		echo "Uninstaller: Uninstalling Jaguar and Panther items"
		sudo nicl . -delete /services/pds
		sudo nicl . -delete /services/pds1
		sudo nicl . -delete /services/pds2
		sudo nicl . -delete /services/cba8
		sudo nicl . -delete /services/msgsys
	else
		echo "Uninstaller: Uninstalling Tiger or later items"
		sudo dscl . -delete /services/pds
		sudo dscl . -delete /services/pds1
		sudo dscl . -delete /services/pds2
		sudo dscl . -delete /services/cba8
		sudo dscl . -delete /services/msgsys
	fi
}

function remove_service_entries()
{
	echo " removing services entries"
	sudo cp -f /etc/services /etc/services.bak
	sudo /bin/sh -c 'sed -e /cba8/d -e /pds/d -e /pds1/d -e /pds2/d -e /msgsys/d /etc/services.bak > /etc/services'
	sudo rm /etc/services.bak
}

function remove_inet_entries()
{
	echo " removing inet entries"
	sudo cp -f /etc/inetd.conf /etc/inetd.conf.bak
	sudo /bin/sh -c 'sed -e /cba8/d -e /pds/d -e /pds1/d -e /pds2/d -e /msgsys/d /etc/inetd.conf.bak > /etc/inetd.conf'
	sudo rm /etc/inetd.conf.bak
}

function update_xinetd()
{
	if [ -e "/var/run/xinetd.pid" ]; then
		echo " hupping xinetd"
		sudo /usr/bin/killall -HUP xinetd
		sudo /bin/sleep 5
	fi
	if [ ! -e "/var/run/xinetd.pid" ]; then
		# If not Xinet, restart it. (The HUP might kill it if there are no services.)
		echo " restarting xinetd"
		sudo xinetd -pidfile /var/run/xinetd.pid
	fi
}

### main ###

for arg in "$@"; do
	case "$arg" in
		-c)
			CLEAN=1
			;;
		-h)
			show_help
			exit 1
			;;
	esac
done

#uninstall ldav to ensure Kaspersky gets uninstalled and agents unloaded properly
remove_ldav

#unload launch agents to ensure are stopped in the proper context
unload_LaunchAgent com.landesk.remotelaunch.plist
unload_LaunchAgent com.landesk.usermenu.plist
unload_LaunchAgent com.landesk.ldNotificationMonitor.plist
unload_LaunchAgent com.landesk.ldusermenu.plist
unload_LaunchAgent com.landesk.dispatch.ui.plist
unload_LaunchAgent com.landesk.dispatch.sui.plist
unload_LaunchAgent com.landesk.ldlaunch_daemon.plist
unload_LaunchAgent com.landesk.ldwatch.plist
unload_LaunchAgent com.landesk.lockscreen.plist
unload_LaunchAgent com.landesk.ldlogged_in.plist
unload_LaunchAgent com.landesk.ldlogged_out.plist
unload_LaunchAgent com.landesk.usermenu.plist

stop_processes

remove_crontab

remove_firewall

remove_tmc

remove_rc

remove_swd

remove_baseagent

remove_framework

remove_gateway

remove_sharedtech

remove_pkg_receipts

remove_crontab

remove_firewall

cleanup_directories

remove_crashlogs

remove_pidfiles

remove_xinetd_files

remove_netinfo_entries

remove_service_entries

remove_inet_entries

remove_Fuze "LANDESK Fuse.app"

remove_Fuze "BridgeIT.app"

update_xinetd

defaults delete /Library/Preferences/com.apple.SoftwareUpdate CatalogURL

echo "Cleanup complete: $REMOVED elements were removed."


# vim:ts=4:sw=4
