

################################################################################
# v1.0beta ( dhcp-client only, custom ddns script added ) Sun 24 Oct 2021
#                       _____  _____  __     _____  ____
#                      |  |  ||  _  ||  |   |   __||    \
#                      |     ||     ||  |__ |   __||  |  |
#                      |__|__||__|__||_____||__|   |____/
#                      high accuracy lose|failure detector
#
#                          -=[ Short description ]=-
#
# Wrote this script because ALOT of pain with bare netwatch.
# There also some weird things but we are just a script. You are warned.
#
# When netwatch rekt, we do some magic in "down" part:
#     Disable self for preventing rerun.
#     Than checks every iterate if there were ping losses and
#     act accordind getted result, if none we return back to netwatch.
#
#                 -=[ Main requirements and recomendations ]=-
#
# Need custom dhcp-client with comment "ISP1".
#
# Adjust "stockDistance" and "thresholdPercent" for your needs.
# "thresholdPercent" below 5 may cause inaccuracy and fail.
# "stockDistance" need to be less than your secondary ISP distance.
#
# Secondary ISP distance 25 is probably safe value.
# Don't change default-route-distance directly in dhcp-client!
# # you can set-up default-route-distance in netwatch and HLTCHKSCHD scripts
# # about default-route-distance read below
# #
# Add blackhole routes to monitored IPs to avoid checks through secondary ISP.
# # Obviously monitored IPs nailed to ISP1.
# # Currently hardcoded IPs is 8.8.4.4 and 1.0.0.1, feel free to change.
# Set ICMP packets to HIGHEST priority.
# For best results netwatch interval can be set to "00:00:01" or "00:00:05".
# !!! ALL connections on failover will reset. You can improve this.
#
################################################################################

#######################################TODO#####################################
#
# * chage ddns script to be optional (add more if's)
#
#
################################################################################




#
# postsetup ( part of failover script )
#

/system scheduler
add name=HLTCHKSCHD on-event=":delay 60s\r\
    \n# here we resetting failover scipts values to defaults \r\
    \n# (that if router failed due power outage or something) \r\
    \n:log info \"[ \? ] verifying netwatch HLTCHK script\"\r\
    \n#if ([/system script job find where owner~\"sys\"] = \"\") do={\r\
    \n\t# \r\
    \n\t/tool netwatch enable [ find comment=\"HLTCHK\" and status!=up ];\r\
    \n\t# check ddns\r\
    \n\t/system script run \"0DDNSHLPR\"\r\
    \n#};\r\
    \n# check route priority\r\
    \nif ([ /ip dhcp-client find where comment=\"ISP1\" and default-route-distance!=1 ]) do={\r\
    \n\t:log warning message=\"[ ! ] reverted to primary ISP\";\r\
    \n\t# setting distance back\r\
    \n\t/ip dhcp-client set [find where comment=\"ISP1\"] default-route-distance=1;\r\
    \n};" policy=reboot,read,write,test start-time=startup


#
/ip route add distance=250 dst-address=8.8.4.4 type=blackhole comment="ISP1DONOTDELETE"
/ip route add distance=250 dst-address=1.0.0.1 type=blackhole comment="ISP1DONOTDELETE"








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
# netwatch -> down ( part of failover script )
#

# should set comment="HLTCHK" otherwise script fail


/tool netwatch disable [ find comment="HLTCHK" ];
:log warning message=("[ ! ] netwatch host timeout");

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
:delay 5s;

# main loop
do {

	# if this script up that ambiguous
	if ([ /tool netwatch find where comment="HLTCHK" and status=up ]) do={
		:log error message="[ e ] netwatch already up ";
		:delay 5s;
		:return 0;
	};

	# no sense if dhcp-client disabled
	if ([/ip dhcp-client find where comment="ISP1" and disabled=yes]) do={
		:log error message="[ e ] dhcp-client disabled. ";
		:delay 1m;
		/tool netwatch enable [ find comment="HLTCHK" ];
		:return 0;
	};

	# no sense if interface fall
	if ([/interface ethernet get [/ip dhcp-client get [find where comment="ISP1"] interface ] running ] = false) do={
		:log error message="[ e ] interface not running. ";
		:delay 42s;
		/tool netwatch enable [ find comment="HLTCHK" ];
		:return 0;
	};

	# no sense if route to the checked host disappeared
	if ([/ip route find where comment="ISP1HEALTHDST"] = "") do={
		:log error message="[ e ] route to test hosts gone. ";
		:delay 1m;
		/tool netwatch enable [ find comment="HLTCHK" ];
		:return 0;
	};

	# somethimes ISP change their GW
	:set newgw [/ip dhcp-client get [find where comment="ISP1"] gateway];
	:set curgw [/ip route get [find where comment="ISP1HEALTHDST" and dst-address="1.0.0.1/32" ] gateway ];
	if ($newgw != $curgw) do={
		:log warning message="[ ! ] updating health hosts gw";
		/ip route set [find comment="ISP1HEALTHDST"] gateway=$newgw;
	};

	:set lossPercentage [:put [$lossPercentageFunc]];

	if ( [ $lossPercentage ] >=  $thresholdPercent  )  do={
			#
			if ([ /ip dhcp-client find where comment="ISP1" and default-route-distance!=25 ]) do={

				/ip dhcp-client set [find where comment="ISP1"] default-route-distance=25;
				:log warning message="[ ! ] fallback to secondary ISP";
				# resseting all connections. improve this
				:log warning message="[ ! ] resetting firewall connections.";
				/ip firewall connection remove [find];
				# updating ddns services
				/ip cloud force-update
				:log info message="[ ? ] updating ip-cloud.";
				/system script run "0DDNSHLPR";
			};

			:log info message=("[ * ] approx pkt loss: " . $lossPercentage . "%");

	} else={
		if ([ $lossPercentage ] <  $thresholdPercent) do={
			:log info message="[ * ] approx pkt loss below threshold ";
			#
			# check if we already have ISP1 with distance other than 1
			if ([ /ip dhcp-client find where comment="ISP1" and default-route-distance!=1 ]) do={
				:log warning message="[ ! ] reverted to primary ISP";
				# setting distance back
				/ip dhcp-client set [find where comment="ISP1"] default-route-distance=$stockDistance;
				# resseting all connections. improve this
				:log warning message="[ ! ] resetting firewall connections.";
				/ip firewall connection remove [find];
				# updating ddns services
				/ip cloud force-update
				:log warning message="[ ! ] updating ip-cloud.";
				#
				/system script run "0DDNSHLPR";
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

														:delay 10s

														#
														/tool netwatch enable [ find comment="HLTCHK" and status!=up ]
														# updating ddns services
														/ip cloud force-update
														:log warning message="[ ! ] updating ip-cloud."

														/system script run "0DDNSHLPR"

														:log error message="error in main loop"

														# quit script
														:error message="quit"
													};
#
#
# ISP failover script EOF





#
# script -> 0DDNSHLPR ( part of failover script )
#

# Name:
# 0DDNSHLPR
#
# policy=reboot,read,write,test

#
# Intended to use only with HLTCHK netwatch script
#


/ip cloud force-update
#  /ip cloud  cant be updated instantly, we need some delays
:delay delay-time=5s

# Set ddns here
:local name=ourDomainName value="<<<<<<<<<<<<<<<<<<<<<<<<<DDNS_NAME_HERE>>>>>>>>>>>>>>"
# Just for script scope, we update it in future
:local name=resolvedIP value="127.0.0.1"

# Then try resolve this ddns
:do {
	set name=resolvedIP value=[:resolve domain-name=$ourDomainName] ;
	:log warning message="[ ! ] 0DDNSHLPR: resolved $ourDomainName with IP $resolvedIP"
} on-error={ :log error message="[ e ] 0DDNSHLPR: error resolving $ourDomainName" };

# Then we call your ddns provider API or do some other automated stuff

:if ( $resolvedIP != [ /ip cloud get public-address ] ) do={
	# fetch and store status in 000ddnshlpr
	:local name=000ddnshlpr ([:tool fetch mode=https output=user url="<<<<<<<<<<<<<<<<<<<<<<<<<API_URL_HERE>>>>>>>>>>>>>>" as-value]->"status");
	#
	:log warning message="[ ! ] 0DDNSHLPR: ddns updated, HTTP status: $000ddnshlpr";
} else={
	:log warning message="[ ! ] 0DDNSHLPR: $resolvedIP same with  /ip cloud  public-address"
	# only HLTCHK can call this script, so something goes wrong
	# if netwatch HLTCHK script up we do nothing otherwise restarting self
	:log info message="[ ? ] 0DDNSHLPR: probably  /ip cloud  still needs to be updated and we restart ourselves if so"
	#
	if ([ /tool netwatch find where comment="HLTCHK" and status!=up ]) do={
		:log info message="[ ? ] 0DDNSHLPR: restarting script in 10 seconds..."
		:delay delay-time=10s
		/system script run "0DDNSHLPR"
	}
};





################################################################################
