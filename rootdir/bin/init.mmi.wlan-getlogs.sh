#!/vendor/bin/sh

wlan_log_path="/data/vendor/wifi/wlan_logs/"
wlan_log_dest_path="/data/vendor/bug2go/wlan_logs"
diag_log_path="/data/vendor/diag_mdlog/logs"
mdm2_log_path="/data/vendor/diag_mdlog/logs/mdm2"

cp -r $wlan_log_path $wlan_log_dest_path

if [ -d $mdm2_log_path ]
    then echo "Get diag logs"
    for f in $diag_log_path/*.qmdl{,2}
        do cp $f $wlan_log_dest_path
    done
        cp -r $mdm2_log_path $wlan_log_dest_path
fi

chown -R log:log $wlan_log_dest_path
