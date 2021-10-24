#----------------------------------DESC----------------------------------------#
# 1.0.0-beta                                                    Sun 24 Oct 2021
#                       _____  _____  __     _____  ____
#                      |  |  ||  _  ||  |   |   __||    \
#                      |     ||     ||  |__ |   __||  |  |
#                      |__|__||__|__||_____||__|   |____/
#                      high accuracy lose|failure detector
#
#                          -=[ Short description ]=-
#
# _=[ Wrote this script because ALOT of pain with bare netwatch.
#     There also some weird things but we are just a script. You are warned. ]=_
#
# _=[ When ISP rekt, we do some magic in netwatch "down" part:
#     First disable ourself for preventing rerun.
#     Then collect ping samples in loop to public hosts.
#     Just checks every iterate if there were ping losses more than should it be
#     If so we switch route distance to higher value and reset connections. ]=_
#
#  _=[ Currently works only with "primary" and "secondary" ISP, there no
#      options to add more than 2. But planned. ]=_
#
#                 -=[ Main requirements and recommendations ]=-
#
# _=[ Required custom dhcp-client with comment "ISP1". See example below. ]=_
#
# _=[ Adjust "stockDistance" and "thresholdPercent" for our needs.
#    "thresholdPercent" below 5 may cause inaccuracy.
#    "stockDistance" required to be less than our secondary ISP distance. ]=_
#
# _=[ Secondary ISP distance 25 is probably safe value.
#     Don't change "default-route-distance" directly in dhcp-client!
#     "default-route-distance" can be changed directly in scripts.
#     More about default-route-distance see below.  ]=_
#
# _=[ Blackhole routes should exist to avoid checks through secondary ISP.
#     Obviously monitored IPs nailed to ISP1.
#     Currently hard-coded IPs is 8.8.4.4 and 1.0.0.1 - feel free to change.
#     Set ICMP packets to HIGHEST priority. ]=_
#
# _=[ Netwatch interval can be set to "00:00:01" or "00:00:05". ]=_
# _=[ Obviously connections will be reseted when ISP gone. ]=_
#
#------------------------------------------------------------------------------#

#-----------------------------------TODO---------------------------------------#
#
# * chage DDNS script to be optional (add more if's)
#
#
#------------------------------------------------------------------------------#


#
# post-setup ( part of failover script )
#

/system scheduler
add name=HLTCHKSCHD on-event="#\r\
    \n# scheduler -> HLTCHKSCHD ( part of failover script )\r\
    \n#\r\
    \n# Here we fixing some stuff if router failed due power outage or something.\r\
    \n/log info \"[ \? ] HLTCHKSCHD: running.\"\r\
    \n/ip cloud force-update\r\
    \n/delay 10s\r\
    \n/ip cloud force-update\r\
    \n/delay 45s\r\
    \n#\r\
    \n/log info \"[ \? ] HLTCHKSCHD: verifying netwatch HLTCHK script\"\r\
    \n/tool netwatch enable [ find comment=\"HLTCHK\" and status!=up ];\r\
    \n/ip cloud force-update\r\
    \n# Delay if ISP still failing\r\
    \n/delay 15s\r\
    \nif ([ /tool netwatch find where comment=\"HLTCHK\" and status=up ]) do={\r\
    \n\tif ([ /ip dhcp-client find where comment=\"ISP1\" and default-route-distance!=1 ]) do={\r\
    \n\t\t/log warning message=\"[ ! ] HLTCHKSCHD: reverted to primary ISP\";\r\
    \n\t\t# Set distance back\r\
    \n\t\t/ip dhcp-client set [find where comment=\"ISP1\"] default-route-distance=1\r\
    \n\t}\r\
    \n\t#\r\
    \n\t/log info message=\"[ \? ] HLTCHKSCHD: restarting ddns script in 10 seconds...\"\r\
    \n\t/delay delay-time=10s\r\
    \n\t/system script run \"DDNSHLPR\"\r\
    \n}\r\
    \n" policy=reboot,read,write,test start-time=startup


#
# blackholing is important!
#
/ip route add distance=250 dst-address=8.8.4.4 type=blackhole comment="ISP1DONOTDELETE"
/ip route add distance=250 dst-address=1.0.0.1 type=blackhole comment="ISP1DONOTDELETE"

#
# post-setup ( part of failover script )                                      EOF
#

################################################################################

#
# dhcp-client -> advanced ( part of failover script )
#
:local defDistance [/ip dhcp-client get [find where comment="ISP1"] default-route-distance];
if ($bound=1) do={
	if ( [/ip route find where comment="ISP1HEALTHDST"] = "") do={
	 	/ip route add dst-address=1.0.0.1 gateway=$"gateway-address" scope=10 comment="ISP1HEALTHDST" distance=$defDistance;
		/ip route add dst-address=8.8.4.4 gateway=$"gateway-address" scope=10 comment="ISP1HEALTHDST" distance=$defDistance;
	};
} else={
	/ip route remove [find comment="ISP1HEALTHDST"];
};

#
# dhcp-client -> advanced ( part of failover script )                        EOF
#

################################################################################

#
# netwatch -> down ( part of failover script )
#

# should set comment="HLTCHK" otherwise script fail


/tool netwatch disable [ find comment="HLTCHK" ];
/log warning message=("[ ! ] HLTCHK: netwatch host timeout");

# accuracy threshold ( lower = better )
:local thresholdPercent 5;
# must be equal to default-route-distance ( on dhcp-client )
# and also check scheduler script "HLTCHKSCHD" there  default-route-distance is hardcoded to 1
:local stockDistance 1;

#
:local lossPercentage;
:local lossPercentageFunc do={:return  (100 - [ /ping count=100 interval=100ms size=28 8.8.4.4 ])};
:local newgw;
:local curgw;

# delay execution (avoid most link flaps)
/delay 3s;

# main loop
do {
	# If this script already up that ambiguous
	if ([ /tool netwatch find where comment="HLTCHK" and status=up ]) do={
		/log error message="[ e ] HLTCHK: netwatch already up ";
		/delay 5s;
		:return 0;
	};

	# No sense if dhcp-client disabled
	if ([/ip dhcp-client find where comment="ISP1" and disabled=yes]) do={
		/log error message="[ e ] HLTCHK: dhcp-client disabled. ";
		/delay 1m;
		/tool netwatch enable [ find comment="HLTCHK" ];
		:return 0;
	};

	# No sense if interface fall
	if ([/interface ethernet get [/ip dhcp-client get [find where comment="ISP1"] interface ] running ] = false) do={
		/log error message="[ e ] HLTCHK: interface not running. ";
		/delay 42s;
		/tool netwatch enable [ find comment="HLTCHK" ];
		:return 0;
	};

	# No sense if route to the checked host disappeared
	if ([/ip route find where comment="ISP1HEALTHDST"] = "") do={
		/log error message="[ e ] HLTCHK: route to test hosts gone. ";
		/delay 1m;
		/tool netwatch enable [ find comment="HLTCHK" ];
		:return 0;
	};

	# Somethimes ISP change their GW
	:set newgw [/ip dhcp-client get [find where comment="ISP1"] gateway];
	:set curgw [/ip route get [find where comment="ISP1HEALTHDST" and dst-address="1.0.0.1/32" ] gateway ];
	if ($newgw != $curgw) do={
		/log warning message="[ ! ] HLTCHK: updating health hosts GW";
		/ip route set [find comment="ISP1HEALTHDST"] gateway=$newgw;
	};

	:set lossPercentage [:put [$lossPercentageFunc]];

	if ( [ $lossPercentage ] >=  $thresholdPercent  )  do={
			#
			if ([ /ip dhcp-client find where comment="ISP1" and default-route-distance!=25 ]) do={
								/log warning message="[ ! ] HLTCHK: fallback to secondary ISP";
				/ip dhcp-client set [find where comment="ISP1"] default-route-distance=25;

				# resseting connections. improve this
				/log warning message="[ ! ] HLTCHK: resetting firewall connections.";
				/ip firewall connection remove [ find where src-address!=[:ip cloud get public-address ] or dst-address!=[:ip cloud get public-address ] or src-address!="127.0.0.1" ]

				# updating DDNS services
				/ip cloud force-update
				/log info message="[ ? ] HLTCHK: updating ip-cloud";
				/system script run "DDNSHLPR";
			};

			/log info message=("[ * ] HLTCHK: approx pkt loss: " . $lossPercentage . "%");

	} else={

		if ([ $lossPercentage ] <  $thresholdPercent) do={
			/log info message="[ * ] HLTCHK: approx pkt loss below threshold value";
			#
			# check if we already have ISP1 with distance other than 1
			if ([ /ip dhcp-client find where comment="ISP1" and default-route-distance!=1 ]) do={
				/log warning message="[ ! ] reverted to primary ISP";

				# setting distance back
				/ip dhcp-client set [find where comment="ISP1"] default-route-distance=$stockDistance;

				# resseting connections. improve this
				/log warning message="[ ! ] resetting firewall connections";
				/ip firewall connection remove [ find where src-address!=[:ip cloud get public-address ] or dst-address!=[:ip cloud get public-address ] or src-address!="127.0.0.1" ]

				# updating DDNS services
				/ip cloud force-update
				/log warning message="[ ! ] updating ip-cloud";
				#
				/system script run "DDNSHLPR";
			};

			# and enable self
			/tool netwatch enable number=[find comment="HLTCHK"];
		};
	};
} while=( $lossPercentage  >= $thresholdPercent  ) on-error={
														# reverting back distance param
														if ([ /ip dhcp-client find where comment="ISP1" and default-route-distance!=1 ]) do={
															/ip dhcp-client set [find where comment="ISP1"] default-route-distance=$stockDistance;
														}
														/delay 5s
														#
														/tool netwatch enable [ find comment="HLTCHK" and status!=up ]
														# updating DDNS services
														/ip cloud force-update
														/log warning message="[ ! ] updating ip-cloud"
														/system script run "DDNSHLPR"
														/log error message="[ e ] main loop failed"
														# quit script
														:error message="quit"
													};
#
# netwatch -> down ( part of failover script )                               EOF
#

################################################################################

#
# script -> DDNSHLPR ( part of failover script )
#



# Name:
# DDNSHLPR
#
# policy=reboot,read,write,test

#
# Intended to use only with HLTCHK netwatch script
#


/ip cloud force-update
#  /ip cloud  cant be updated instantly, required some delays
/delay delay-time=5s

# Set DDNS here
:local name=ourDomainName value="<<<<<<<<<<<<<<<<<<<<<<<<<DDNS_NAME_HERE>>>>>>>>>>>>>>"
# Just for script scope, we update it in future
:local name=resolvedIP value="127.0.0.1"

# Then try resolve this DDNS
:do {
	set name=resolvedIP value=[:resolve domain-name=$ourDomainName] ;
	#/log warning message="[ ! ] DDNSHLPR: resolved $ourDomainName with IP $resolvedIP"
} on-error={ /log error message="[ e ] DDNSHLPR: error resolving $ourDomainName" };

# Then we call our DDNS provider API or do some other automated stuff

:if ( $resolvedIP != [ /ip cloud get public-address ] ) do={
	# fetch and store status in 00DDNSHLPR
	:local name=00DDNSHLPR ([:tool fetch mode=https output=user url="<<<<<<<<<<<<<<<<<<<<<<<<<API_URL_HERE>>>>>>>>>>>>>>" as-value]->"status");
	#
	/log warning message="[ ! ] DDNSHLPR: DDNS updated, HTTP status: $00DDNSHLPR";
} else={
	/log warning message="[ ! ] DDNSHLPR: $resolvedIP same with  /ip cloud  public-address"
	# Only HLTCHK can call this script, so something goes wrong
	# if netwatch HLTCHK script up we do nothing otherwise restarting self
	#/log info message="[ ? ] DDNSHLPR: --------------------------"
	#
	if ([ /tool netwatch find where comment="HLTCHK" and status!=up ]) do={
		/log info message="[ ? ] DDNSHLPR: restarting script in 10 seconds..."
		/delay delay-time=10s
		/system script run "DDNSHLPR"
	}
};


#
# script -> DDNSHLPR ( part of failover script )                             EOF
#

################################################################################
